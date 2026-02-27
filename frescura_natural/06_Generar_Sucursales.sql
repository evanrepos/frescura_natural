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

--TODO: cambiar nombre del archivo a 01 por ejemplo para ejecion en orden
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

EXEC sucursales.sp_ingresar_sucursales 'C:\fuente\mermas\desperdicios.xlsx', 'desperdicios'
GO

SELECT COUNT(*) FROM sucursales.sucursal; --deben salir 20 columnas
SELECT * FROM sucursales.sucursal