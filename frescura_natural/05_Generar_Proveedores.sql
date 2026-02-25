USE FrescuraNatural
GO

CREATE OR ALTER FUNCTION json_to_function (@json NVARCHAR(MAX), @tag VARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro,
        value AS nombre
    FROM OPENJSON(@json, '$.' + @tag)
);
GO

CREATE OR ALTER PROCEDURE proveedores.sp_generar_proveedores (@path NVARCHAR(MAX), @max INT)
AS
    DECLARE @json NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @i INT;
    DECLARE @cantidad INT;
    DECLARE @nombre VARCHAR(MAX);
    DECLARE @apellido VARCHAR(MAX);
    DECLARE @procedencia VARCHAR(MAX);
BEGIN
    --0. CONFIGURACIÓN PREVIA
	SET NOCOUNT ON
    CREATE TABLE #procedencia
    (   
        id INT IDENTITY(1, 1),
        nombre VARCHAR(MAX)
    );
    SET @sql = '
        SELECT @json_out = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @path + ''',
            SINGLE_CLOB
        ) AS j;
    ';

    --1. IMPORTACIÓN DE NOMBRES
    EXEC sp_executesql 
        @sql,
        N'@json_out NVARCHAR(MAX) OUTPUT',
        @json_out = @json OUTPUT;

	--2. GENERAR PROVEEDORES
    --Elige nombre de hombre o mujer.
    SET @i = 1;
    WHILE @i < @max
    BEGIN
        IF (SELECT CAST(RAND() * 2 AS INT)) = 1
        BEGIN
            SET @cantidad = (SELECT COUNT(1) FROM json_to_function(@json, 'femalename'));
            SET @nombre = (SELECT nombre FROM json_to_function(@json, 'femalename') 
                WHERE nro = (SELECT CAST((RAND() * @cantidad) + 1 AS INT)));
        END
        ELSE
        BEGIN
            SET @cantidad = (SELECT COUNT(1) FROM json_to_function(@json, 'malename'));
            SET @nombre = (SELECT nombre FROM json_to_function(@json, 'malename') 
                WHERE nro = (SELECT CAST((RAND() * @cantidad) + 1 AS INT)));
        END

        --Elige apellido.
        SET @cantidad = (SELECT COUNT(1) FROM json_to_function(@json, 'lastname'));
        SET @apellido = (SELECT nombre FROM json_to_function(@json, 'lastname') 
            WHERE nro = (SELECT CAST((RAND() * @cantidad) + 1 AS INT)) );

        --Elige procedencia
        INSERT INTO #procedencia
            SELECT DISTINCT procedencia FROM datos.precios
            WHERE procedencia <> 'Mercado Central'
            ORDER BY procedencia ASC
        SET @cantidad = (SELECT COUNT(1) FROM #procedencia);
        SET @procedencia = (SELECT nombre FROM #procedencia 
            WHERE id = (SELECT CAST((RAND() * @cantidad) + 1 AS INT)) );

    --3. INSERCIÓN DE DATOS.
        INSERT INTO proveedores.proveedor (nombre, pais) VALUES
            (@nombre + ' ' + @apellido, @procedencia);
        SET @i = @i + 1;
    END
    INSERT INTO proveedores.proveedor (nombre, pais) VALUES
        ('Mercado Central', 'Mercado Central');
END
GO

EXEC proveedores.sp_generar_proveedores 'E:\frescura_natural\fuente\05.nombres\data.json', 1000
GO
