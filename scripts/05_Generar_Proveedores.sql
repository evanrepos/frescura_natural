USE FrescuraNatural
GO

SELECT TOP 20 * FROM proveedores.proveedor
GO

DELETE FROM proveedores.proveedor
DBCC CHECKIDENT('proveedores.proveedor', RESEED, 0)
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
    DECLARE @nombre VARCHAR(MAX);
    DECLARE @apellido VARCHAR(MAX);
    DECLARE @procedencia VARCHAR(MAX);
BEGIN
    --0. CONFIGURACIÓN PREVIA
	SET NOCOUNT ON

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
            SELECT TOP 1 @nombre = nombre FROM json_to_function(@json, 'femalename')
            ORDER BY NEWID()
        END
        ELSE
        BEGIN
            SELECT TOP 1 @nombre = nombre FROM json_to_function(@json, 'malename')
            ORDER BY NEWID()
        END

        --Elige apellido.
        SELECT TOP 1 @apellido = nombre FROM json_to_function(@json, 'lastname')
        ORDER BY NEWID()

        --Elige procedencia
        SELECT TOP 1 @procedencia = procedencia FROM datos.precios
        WHERE procedencia <> 'Mercado Central'
        ORDER BY NEWID()

    --3. INSERCIÓN DE DATOS.
        INSERT INTO proveedores.proveedor (nombre, pais) VALUES
            (@nombre + ' ' + @apellido, @procedencia);
        SET @i = @i + 1;
    END

    IF NOT EXISTS (SELECT nombre FROM proveedores.proveedor WHERE nombre = 'Mercado Central')
    BEGIN
        INSERT INTO proveedores.proveedor (nombre, pais) VALUES
            ('Mercado Central', 'Mercado Central');
    END
END
GO

EXEC proveedores.sp_generar_proveedores 'E:\frescura_natural\fuente\05.nombres\data.json', 50
GO

SELECT * FROM proveedores.proveedor