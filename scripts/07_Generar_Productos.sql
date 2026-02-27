USE FrescuraNatural
GO

SELECT TOP 20 * FROM productos.producto
ORDER BY NEWID()
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_productos
AS
	DECLARE @id_categoria INT;
BEGIN
	SET NOCOUNT ON
	DELETE FROM productos.producto
    DBCC CHECKIDENT ('productos.producto', RESEED, 0);

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Verduras de hoja');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('ACELGA', 'ACHICORIA', 'ACUSAY','BERRO','ENDIBIA','ESCAROLA','ESPINACA','KALE','LECHUGA','PACK CHOY','RADICCHIO','RADICHETA','RUCULA')
	
	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Tuberculos');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('BATATA', 'MANDIOCA', 'NABO', 'PAPA', 'RABANITO', 'REMOLACHA', 'ZANAHORIA')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Bulbos y tallos');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('AJO', 'APIO', 'CEB.VERDEO', 'CEBOLLA', 'CIBOULLE', 'HINOJO', 'PUERRO')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Verduras de fruto');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('BERENJENA', 'CHAUCHA','CHOCLO','PEPINO','PIMIENTO','POROTO','TOMATE','ZAPALLITO')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Cucurbitaceas');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('MELON', 'SANDIA', 'ZAPALLO')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Citricos');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('LIMA', 'LIMON', 'MANDARINA', 'NARANJA', 'POMELO')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Frutas de pepita');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('GRANADA', 'KIWI', 'MANZANA', 'MEMBRILLO', 'PERA')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Frutas de carozo');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('CEREZA', 'CIRUELA', 'DAMASCO', 'DURAZNO', 'PELON')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Frutas pequenas');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('ARANDANO', 'FRAMBUESA', 'FRUTILLA', 'HIGO', 'UVA')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Frutas tropicales');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('ANANA', 'BANANA', 'CARAMBOLA', 'COCO', 'GUAYABA', 'MAMON', 'MANGO', 'MBURUCUYA', 'PALTA', 'PLATANO', 'TUNA')

	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Hierbas y aromaticas');
	INSERT INTO productos.producto (id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso)
		SELECT @id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso FROM datos.precios
		WHERE especie IN ('ALBAHACA', 'BROTE ALFA', 'BROTE SOJA', 'CILANDRO', 'CURCUMA', 'JENGIBRE', 'MENTA', 'OREGANO', 'PEREJIL', 'ROMERO', 'SALVIA', 'TOMILLO')

END
GO
EXEC productos.sp_generar_productos

SELECT TOP 20 pprod.id, especie, descripcion FROM productos.producto pprod INNER JOIN productos.categoria pcat ON pprod.id_categoria = pcat.id
ORDER BY NEWID()
