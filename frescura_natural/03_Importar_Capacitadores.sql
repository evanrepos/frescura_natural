USE FrescuraNatural
GO

SELECT TOP 20 * FROM sucursales.capacitador
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_capacitadores 
    @path VARCHAR(100),
    @row_terminator CHAR(2) = '\n',
    @field_terminator CHAR(1) = ','
AS
BEGIN
    SET NOCOUNT ON 

    DELETE FROM sucursales.capacitador
    DBCC CHECKIDENT ('sucursales.capacitador', RESEED, 0);

    CREATE TABLE #capacitadores(
        numero_registro VARCHAR(31),
        nombre_completo VARCHAR(50),
        telefono VARCHAR(12),
        mail VARCHAR(40)
        );

    DECLARE @bulk_insert NVARCHAR(MAX);

    SET @bulk_insert = '
    BULK INSERT #capacitadores
    FROM ''' + @path + '''
    WITH (
        FIRSTROW = 2,
        ROWTERMINATOR = ''' + @row_terminator +''',
        FIELDTERMINATOR = ''' + @field_terminator + ''',
        TABLOCK
    );';
    EXEC (@bulk_insert);
    
    

    INSERT INTO sucursales.capacitador (numero_registro, nombre, telefono, mail)
    SELECT * FROM #capacitadores;
END
GO

EXEC sucursales.sp_ingresar_capacitadores 'E:\frescura_natural\fuente\03.capacitadores\capacitadores-de-manipuladores-de-alimentos.csv'
SELECT TOP 20 * FROM sucursales.capacitador

