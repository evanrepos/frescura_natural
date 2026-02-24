USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_sucursales 
AS
BEGIN
    SET NOCOUNT ON 
    INSERT INTO sucursales.sucursal (localidad)
        SELECT DISTINCT sucursal FROM datos.mermas
END
GO

  --REEMPLAZAR EL CAMPO <ruta> POR EL PATH DEL ARCHIVO.
EXEC sucursales.sp_ingresar_sucursales
GO
