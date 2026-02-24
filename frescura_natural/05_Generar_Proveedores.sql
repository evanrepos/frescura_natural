--GENERAR PROVEEDORES

----------------------------------------------------------------
-- ESQUEMA: auxiliar (precio)
----------------------------------------------------------------
--SELECT CAST(RAND() * 2 AS INT) --BIT PALANCA

USE FrescuraNatural
GO

CREATE FUNCTION json_to_function (@json NVARCHAR(MAX), @tag VARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro,
        value AS nombre
    FROM OPENJSON(@json, '$.' + @tag)
);

CREATE OR ALTER PROCEDURE proveedores.sp_generar_proveedores (@path NVARCHAR(MAX))
AS
    DECLARE @json NVARCHAR(MAX);
    DECLARE @sql VARCHAR(MAX);
    DECLARE @cantidad INT;
    DECLARE @nombre VARCHAR(MAX);
    DECLARE @apellido VARCHAR(MAX);
BEGIN
    -- Solo dinámico para leer archivo
    SET @sql = '
        SELECT @json_out = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @path + ''',
            SINGLE_CLOB
        ) AS j;
    ';

    EXEC sp_executesql 
        @sql,
        N'@json_out NVARCHAR(MAX) OUTPUT',
        @json_out = @json OUTPUT;

	--2. GENERAR PROVEEDORES
    --Elige nombre de hombre o mujer.
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

END

EXEC proveedores.sp_generar_proveedores 'E:\frescura_natural\fuente\05.nombres\data.json'

WHILE 