USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_sucursales 
    @path VARCHAR(100),
    @page_name VARCHAR(30),
    @row_terminator CHAR(2) = '\n',
    @field_terminator CHAR(1) = ','
AS
BEGIN
    SET NOCOUNT ON 
    CREATE TABLE #merma(
        fecha DATETIME,
        producto VARCHAR(20),
        cantidad TINYINT,
        sucursal VARCHAR(15)
    );
    
    DECLARE @openrowset VARCHAR(MAX);
    SET @openrowset = 'INSERT INTO #merma
        SELECT * FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.16.0'',
    ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +''',
    ''SELECT * FROM [' + @page_name +'$]''
    );';
    EXEC (@openrowset);
    
    INSERT INTO sucursales.sucursal (nombre, direccion, localidad)
        SELECT DISTINCT 'nombre', 'direccion', sucursal FROM #merma;
END
GO

  --REEMPLAZAR EL CAMPO <ruta> POR EL PATH DEL ARCHIVO.
EXEC sucursales.sp_ingresar_sucursales <ruta>, 'desperdicios'
GO
SELECT * FROM sucursales.sucursal
