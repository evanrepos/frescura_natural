USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE proveedores.sp_generar_precios
AS
	DECLARE @id_mercado_central INT = (SELECT id FROM proveedores.proveedor WHERE nombre = 'Mercado Central');
	DECLARE @loop INT;
	DECLARE @id_producto INT;
	DECLARE @cant_prods INT;
	DECLARE @pais VARCHAR(50);
	DECLARE @maximo INT;
	DECLARE @monto INT;
	DECLARE @minimo INT;
	DECLARE @mapk DECIMAL(7, 2);
	DECLARE @mpk DECIMAL(7, 2);
	DECLARE @mipk DECIMAL(7, 2);
	DECLARE @id_proveedor INT;
	DECLARE @incremento DECIMAL(2, 2);
	DECLARE @decremento DECIMAL(2, 2);
	DECLARE @bit_decision TINYINT;
	DECLARE @prods_random TABLE (id INT, maximo INT, minimo INT, modal INT, mapk DECIMAL(7, 2), mipk DECIMAL(7, 2), mopk DECIMAL(7, 2));
BEGIN
	SET NOCOUNT ON

	--PASO 0. Inicializar precios del proveedor mercado central.
	INSERT INTO proveedores.precio (id_producto, id_proveedor, monto, mpk)
		SELECT id, @id_mercado_central, modal, mopk FROM datos.precios 
		WHERE procedencia = 'Mercado Central' AND modal <> 0 AND mopk <> 0

	--POR CADA PROVEEDOR
	SET @loop = 1;
	WHILE @loop < (SELECT COUNT(1) FROM proveedores.proveedor)
	BEGIN
		--PASO 0. Inicializar la tabla de productos aleatorios.
		DELETE FROM @prods_random

		SELECT @pais = pais FROM proveedores.proveedor WHERE id = @loop;

		--PASO 2. Definir los MONTOS para las duplas (PRODUCTO, PROVEEDOR)
			--Configurar variables de incremento, decremento y bit de decisión. Esto ayudará a reflejar la identidad del proveedor en el precio final.
		SET @incremento = CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2));
		SET @decremento = CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2));
		SET @bit_decision = CAST(RAND(CHECKSUM(NEWID())) * 2 AS TINYINT);

		--PASO 3. Elegir una cantidad ALEATORIA de PRODUCTOS para el proveedor, cuya procedencia coincida con su país. Los precios no pueden ser nulos.
		SELECT @cant_prods = CAST(RAND() * COUNT(1) AS INT) + 1 FROM datos.precios WHERE procedencia = @pais AND modal <> 0 AND mopk <> 0;

		--PASO 4. Insertar el id de producto, máximo, mínimo, modal, mapk, mipk y mopk en una tabla temporal
		INSERT INTO @prods_random (id, maximo, minimo, modal, mapk, mipk, mopk)
			SELECT TOP (@cant_prods) id, maximo, minimo, 
				modal + CAST((@incremento * (maximo - modal) - @decremento * (modal - minimo)) * @bit_decision AS INT) AS modal,
				mapk, mipk, 
				mopk + CAST((@incremento * (mapk - mopk) - @decremento * (mopk - mipk)) * @bit_decision AS DECIMAL(7, 2)) AS mopk
			FROM datos.precios
			WHERE modal > 0 AND mopk > 0 AND procedencia = @pais 
			ORDER BY NEWID();

		--PASO 5. Insertar el PRODUCTO, PROVEEDOR y MONTOs en la tabla de precios.
		INSERT INTO proveedores.precio (id_producto, id_proveedor, monto, mpk)
			SELECT id, @loop, modal, mopk FROM @prods_random

		SET @loop = @loop + 1;
	END
END
GO

EXEC proveedores.sp_generar_precios
GO
SELECT * FROM proveedores.precio
ORDER BY id_producto, mpk

SELECT TOP 50 id_producto, especie, procedencia, id_proveedor, nombre, pais, 
	minimo, monto, modal, CAST(CAST((monto - modal) * 100 AS FLOAT) / CAST(modal AS FLOAT) AS DECIMAL(4, 2)) AS 'diferencia (%)', maximo
FROM proveedores.precio pprecio INNER JOIN 
		datos.precios dprecio ON pprecio.id_producto = dprecio.id INNER JOIN 
		proveedores.proveedor pprov ON pprecio.id_proveedor = pprov.id
ORDER BY id_producto, monto DESC