USE FrescuraNatural
GO

SELECT TOP 20 * FROM productos.producto
ORDER BY NEWID()
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_productos
AS
BEGIN
	SET NOCOUNT ON
	DELETE FROM productos.producto
    DBCC CHECKIDENT ('productos.producto', RESEED, 0);

	INSERT INTO productos.producto (especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
END
GO
EXEC productos.sp_generar_productos

SELECT TOP 20 * FROM productos.producto
ORDER BY NEWID()
