USE FrescuraNatural
GO

--CICLO ITERATIVO, POR CADA PROVEEDOR GUARDAR EL PAIS, CONSULTAR EL PAIS EN LA LISTA DE PRECIOS, CONTARLOS, ELEGIR CANTIDAD DE PRODUCTOS A VENDER,
--QUE DICHOS PRODUCTOS NO SE REPITAN EN ESPECIE
CREATE OR ALTER PROCEDURE proveedores.sp_generar_precios
AS
	DECLARE @i INT;
	DECLARE @j INT;
	DECLARE @cant_prov INT;
	DECLARE @pais VARCHAR(MAX);
	DECLARE @cant_registros INT;
	DECLARE @cant_precios INT;
	DECLARE @idx_precio INT;
	DECLARE @monto DECIMAL(8, 2);
BEGIN
	SET NOCOUNT ON
	--TABLA TEMPORAL (Referencia)
	CREATE TABLE #precios
	(
		id INT IDENTITY(1, 1),
		id_precio INT NOT NULL,
		especie VARCHAR(MAX),
		variedad VARCHAR(MAX),
		procedencia VARCHAR(MAX),
		maximo DECIMAL(8, 2),
		modal DECIMAL(8, 2),
		minimo DECIMAL(8, 2),
	);
	--Configurar variables iterativas, y límite de iteración por cantidad de proveedores.
	SET @i = 1;
	SET @cant_prov = (SELECT COUNT(1) FROM proveedores.proveedor);
	WHILE @i <= @cant_prov
	BEGIN
		--Guardar país.
		SET @pais = (SELECT pais FROM proveedores.proveedor
			WHERE id_proveedor = @i);

		--SELECT @pais

		DELETE FROM #precios
		DBCC CHECKIDENT ('#precios', RESEED, 0);

		--Consultar precios por el país del proveedor.
		INSERT INTO #precios (id_precio, especie, variedad, procedencia, maximo, modal, minimo)
			SELECT id, especie, variedad, procedencia, maximo, modal, minimo
			FROM datos.precios 
			WHERE procedencia = @pais 
			ORDER BY especie, variedad

		--SELECT * FROM #precios
		--Guardar cantidad de registros encontrados con ese país.
		SET @cant_registros = (SELECT COUNT(1) FROM #precios);

		--Elegir cantidad de precios a guardar para el proveedor.
		SET @j = 1;
		SET @cant_precios = (SELECT CAST(RAND() * @cant_registros AS INT) + 1);
		SELECT @i AS proveedor, @cant_precios as Cantidad_Precios

		--Generar N precios para el proveedor
		WHILE @j <= @cant_precios
		BEGIN
			--Elegir el precio de la tabla temporal a guardar.
			SET @idx_precio = (SELECT CAST(RAND() * @cant_registros + 1 AS INT));
			--SELECT @idx_precio AS id

			--Tomar el id original del producto
			SET @idx_precio = (SELECT id_precio FROM #precios WHERE id = @idx_precio);
			--SELECT @idx_precio AS id_precio

			IF (SELECT COUNT(1) FROM proveedores.precio WHERE id_producto = @idx_precio) = 0
			BEGIN
				--Elegir un monto dentro de la brecha de precios
				SET @monto = (SELECT modal + 
					CAST(RAND() * (maximo - minimo) AS DECIMAL(8, 2)) * 
					CAST(RAND() * 3 AS INT) - 1 
					FROM #precios
					WHERE id_precio = @idx_precio);
				--SELECT @monto AS monto

				--Guardar datos en la tabla
				INSERT INTO proveedores.precio (id_producto, id_proveedor, monto) VALUES
					(@idx_precio, @i, @monto);
				--SELECT * FROM proveedores.precio
			END
			SET @j = @j + 1;
		END
	SET @i = @i + 1;
	END
END
GO

EXEC proveedores.sp_generar_precios
GO