USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_productos
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO productos.producto (especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		ORDER BY especie, procedencia, variedad
END
GO
EXEC productos.sp_generar_productos

