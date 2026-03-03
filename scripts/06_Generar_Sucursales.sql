/*
------------------------------------------------------------
Universidad Nacional de La Matanza
Trabajo Práctico Integrador - Bases de Datos Aplicadas
Integrantes: 
Apellido y Nombre						
Gonzáles Fernándes Iván Alejandro						
Mamani Estrada Lucas Gabriel			
------------------------------------------------------------
*/
----IMPORTACIÓN DE SUCURSALES

--TODO: cambiar nombre del archivo a por ejemplo 01_Importar_Sucursales para ejecion en orden
USE FrescuraNatural
GO

SELECT * FROM sucursales.sucursal
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_sucursales 
	@path VARCHAR(MAX),
    @page_name VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON 

	CREATE TABLE #sucursales (
        sucursal VARCHAR(100) NULL
    );

	DECLARE @openrowset VARCHAR(MAX);
	SET @openrowset = 'INSERT INTO #sucursales
        SELECT CAST([sucursal] AS VARCHAR(100)) 
		FROM OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +''',
			''SELECT [sucursal] FROM [' + @page_name + '$]''
		);';
	
	BEGIN TRY
		EXEC (@openrowset);
	END TRY 
	BEGIN CATCH
		THROW; -- deja que el error salga claro
	END CATCH; 

	WITH sucursales_limpias AS ( -- limpieza de datos
		SELECT localidad = UPPER(LTRIM(RTRIM(sucursal)))
		FROM #sucursales
		WHERE sucursal IS NOT NULL AND LTRIM(RTRIM(sucursal)) <> ''
	)
	INSERT INTO sucursales.sucursal (localidad)
	SELECT DISTINCT sl.localidad --  evita insertar la misma localidad varias veces en una misma ejecución si aparece repetida en el Excel.
	FROM sucursales_limpias sl
	LEFT JOIN sucursales.sucursal s --evita insertar registros que ya existen en la tabla sucursal
		ON s.localidad = sl.localidad
	WHERE s.id IS NULL;	
END
GO

CREATE OR ALTER PROCEDURE sucursales.sp_generar_vendedores (@path NVARCHAR(MAX))
AS
    DECLARE @json NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @control_bit BIT = 0;
    DECLARE @id_sucursal INT;
    DECLARE @id_capacitador INT;
    DECLARE @nombre VARCHAR(MAX);
    DECLARE @apellido VARCHAR(MAX);
    DECLARE @date DATE;
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

	--2. GENERAR VENDEDORES
    WHILE @control_bit = 0
    BEGIN
        --Elige capacitador
        SELECT TOP 1 @id_capacitador = id FROM sucursales.capacitador
        ORDER BY NEWID()

        --Elige sucursal
        SELECT TOP 1 @id_sucursal = id FROM sucursales.sucursal
        ORDER BY NEWID()

        --Elige nombre de hombre o mujer.
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

        SELECT @date = CAST(CAST(RAND(CHECKSUM(NEWID())) * 3000 + 42500 AS DATETIME) AS DATE)

    --3. INSERCIÓN DE DATOS.
        INSERT INTO sucursales.vendedor (id_capacitador, id_sucursal, nombre, fecha_capacitacion) VALUES
            (@id_capacitador, @id_sucursal, @nombre + ' ' + @apellido, @date);
        IF NOT EXISTS (SELECT id FROM sucursales.sucursal WHERE id NOT IN (SELECT id_sucursal FROM sucursales.vendedor))
            SET @control_bit = 1;
    END
 
END
GO

EXEC sucursales.sp_ingresar_sucursales 'E:\frescura_natural\fuente\01.mermas\desperdicios.xlsx', 'desperdicios'
GO

--- CONSULTAS PARA PONER EN EL TESTING 
--SELECT COUNT(*) FROM sucursales.sucursal; --deben salir 20 sucursales
SELECT * FROM sucursales.sucursal

EXEC sucursales.sp_generar_vendedores 'E:\frescura_natural\fuente\05.nombres\data.json'
GO

SELECT * FROM sucursales.vendedor
GO

--si lo ejecuto devuelta deben seguir saliendo 20 sucursales
--EXEC sucursales.sp_ingresar_sucursales 'C:\fuente\mermas\desperdicios.xlsx', 'desperdicios'
--SELECT COUNT(*) FROM sucursales.sucursal;
