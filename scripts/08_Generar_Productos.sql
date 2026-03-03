USE FrescuraNatural
GO

SELECT * FROM productos.producto
GO
--SELECT TOP 20 * FROM productos.producto
--ORDER BY NEWID()
--GO

CREATE OR ALTER PROCEDURE productos.sp_agregar_productos
AS
	DECLARE @id_categoria INT;
BEGIN
	SELECT @id_categoria = (SELECT id FROM productos.categoria WHERE descripcion = 'Otros');
	INSERT INTO productos.producto (id_categoria, orden_pop, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso, precioXKg)
		SELECT @id_categoria, 6, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso, mopk FROM datos.precios
		WHERE id NOT IN (SELECT id FROM productos.producto)
END
GO

CREATE OR ALTER PROCEDURE productos.sp_categorizar_productos
AS
	DECLARE @id_categoria INT;
	DECLARE @margen DECIMAL(7, 2);
BEGIN
	SET NOCOUNT ON
	--ACTUALIZAR CATEGORIA
	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Verduras de hoja';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('ACELGA', 'ACHICORIA', 'ACUSAY', 'BERRO', 'ENDIBIA', 'ESCAROLA', 'ESPINACA', 'KALE', 'LECHUGA', 'PACK CHOY', 'RADICCHIO', 'RADICHETA', 'REPOLLO', 'REP.BRUSEL', 'RUCULA')
	
	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Tuberculos';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('BATATA', 'MANDIOCA', 'NABO', 'PAPA', 'RABANITO', 'REMOLACHA', 'ZANAHORIA')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Bulbos y tallos';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('AJO', 'APIO', 'CEB.VERDEO', 'CEBOLLA', 'CIBOULLE', 'ESPARRAGO', 'HINOJO', 'PUERRO')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Verduras de fruto';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('ARVEJA', 'BERENJENA', 'BROCOLI', 'CHAUCHA','CHOCLO', 'COLIFLOR', 'HABA', 'HONGOS', 'PEPINO','PIMIENTO','POROTO','TOMATE','ZAPALLITO')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Cucurbitaceas';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('MELON', 'SANDIA', 'ZAPALLO')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Citricos';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('LIMA', 'LIMON', 'MANDARINA', 'NARANJA', 'POMELO')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Frutas de pepita';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('GRANADA', 'KIWI', 'MANZANA', 'MEMBRILLO', 'PERA')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Frutos Secos';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('NUEZ', 'MANI')
	
	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Frutas de carozo';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('CEREZA', 'CIRUELA', 'DAMASCO', 'DURAZNO', 'PELON')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Frutas pequenas';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('ARANDANO', 'FRAMBUESA', 'FRUTILLA', 'HIGO', 'UVA')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Frutas tropicales';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('ANANA', 'BANANA', 'CARAMBOLA', 'COCO', 'GUAYABA', 'MAMON', 'MANGO', 'MBURUCUYA', 'PALTA', 'PITAHAYA', 'PLATANO', 'TUNA')

	SELECT @id_categoria = id, @margen = CAST(margen AS DECIMAL(7, 2)) FROM productos.categoria WHERE descripcion = 'Hierbas y aromaticas';
	UPDATE productos.producto SET id_categoria = @id_categoria, precioXKg = CAST(precioXKg + (precioXKg * @margen) / 100 AS DECIMAL(7, 2))
		WHERE especie IN ('ALBAHACA', 'BROTE ALFA', 'BROTE SOJA', 'CILANDRO', 'CURCUMA', 'JENGIBRE', 'MENTA', 'OREGANO', 'PEREJIL', 'ROMERO', 'SALVIA', 'TOMILLO')

	--ACTUALIZAR NIVEL DE POPULARIDAD
	UPDATE productos.producto SET orden_pop = 1 WHERE especie IN
        ('PAPA', 'CEBOLLA', 'ZANAHORIA', 'TOMATE', 'LECHUGA', 'BANANA', 'MANZANA', 'NARANJA', 'AJO', 'MANDARINA', 'PEPINO', 'REPOLLO');
    
	UPDATE productos.producto SET orden_pop = 2 WHERE especie IN
		('ACELGA', 'ALBAHACA', 'APIO', 'ARVEJA', 'BATATA', 'BERENJENA', 'BROCOLI', 'CHAUCHA', 'CHOCLO', 'DURAZNO', 'LIMON', 'OREGANO', 'PERA', 'PEREJIL', 'UVA');
    
	UPDATE productos.producto SET orden_pop = 3 WHERE especie IN
		('CEB.VERDEO', 'CILANDRO', 'CIRUELA', 'COLIFLOR', 'ESPARRAGO', 'ESPINACA', 'FRUTILLA', 'HONGOS', 'LIMA', 'MELON', 'PALTA', 'PELON', 'POMELO', 'REMOLACHA');
    
	UPDATE productos.producto SET orden_pop = 4 WHERE especie IN
		('ANANA', 'ACUSAY', 'CEREZA', 'COCO', 'GUAYABA', 'GRANADA', 'HINOJO', 'JENGIBRE', 'KIWI', 'MANDIOCA', 'MANGO', 'TOMILLO', 'PUERRO', 'ROMERO', 'SANDIA');
    
	UPDATE productos.producto SET orden_pop = 5 WHERE especie IN
		('ACHICORIA', 'BERRO', 'BROTE ALFA', 'BROTE SOJA', 'CARAMBOLA', 'CURCUMA', 'DAMASCO', 'ENDIBIA', 'FRAMBUESA', 'MENTA', 'RADICHETA', 'RUCULA');
    
END
GO

EXEC productos.sp_agregar_productos
GO
SELECT TOP 20 * FROM productos.producto
GO
EXEC productos.sp_categorizar_productos
GO
SELECT TOP 20 * FROM productos.producto
GO

--SELECT TOP 20 pprod.id, especie, descripcion FROM productos.producto pprod INNER JOIN productos.categoria pcat ON pprod.id_categoria = pcat.id
--ORDER BY NEWID()
