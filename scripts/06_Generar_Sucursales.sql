USE FrescuraNatural
GO

SELECT * FROM sucursales.sucursal
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_sucursales 
AS
BEGIN
    SET NOCOUNT ON 
    DELETE FROM sucursales.sucursal
    DBCC CHECKIDENT ('sucursales.sucursal', RESEED, 0);

    INSERT INTO sucursales.sucursal (localidad)
        SELECT DISTINCT sucursal FROM datos.mermas
END
GO

EXEC sucursales.sp_ingresar_sucursales
GO

SELECT * FROM sucursales.sucursal