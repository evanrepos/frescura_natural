USE FrescuraNatural
GO

DELETE FROM proveedores.precio
DBCC CHECKIDENT ('proveedores.precio', RESEED, 0);
GO

CREATE OR ALTER PROCEDURE proveedores.sp_generar_precios (@cant_intentos INT = 1000)
AS
	DECLARE @randomQTY INT = CAST(RAND() * 10 AS INT);
	DECLARE @loop INT;
	DECLARE @id_producto INT;
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
BEGIN
	SET NOCOUNT ON

	--PASO 0. Inicializar precios del proveedor mercado central.
	INSERT INTO proveedores.precio (id_producto, id_proveedor, monto, mpk)
		EXEC ('
		DECLARE @id_mercado_central INT;
		SELECT @id_mercado_central = id FROM proveedores.proveedor WHERE nombre = ''Mercado Central'';
		SELECT TOP ' + @randomQTY + ' id, @id_mercado_central, modal, mopk 
		FROM datos.precios 
		WHERE procedencia = ''Mercado Central''');
		--Se utiliza SQL dinámico para elegir una cantidad aleatoria de precios.

	--POR CADA PROVEEDOR
	SET @loop = 1;
	WHILE @loop <= @cant_intentos
	BEGIN
		--PASO 1. Elegir un PRODUCTO aleatorio.
		SELECT TOP 1
			@id_producto = id,
				   @pais = procedencia,
				 @maximo = maximo,
				  @monto = modal,
				 @minimo = minimo,
				   @mapk = mapk,
					@mpk = mopk,
				   @mipk = mipk
		FROM datos.precios
		WHERE modal > 0 AND mopk > 0 AND procedencia <> 'Mercado Central' 
		ORDER BY NEWID();

		--PASO 2. Elegir un PROVEEDOR aleatorio, cuya PROCEDENCIA coincida con el PRODUCTO ELEGIDO.
		SELECT @id_proveedor = id FROM proveedores.proveedor WHERE pais = @pais
		ORDER BY NEWID();

		--PASO 3. Definir los MONTOS para la dupla (PRODUCTO, PROVEEDOR)
			--Configurar variables de incremento, decremento y bit de decisión.
		SET @incremento = CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2));
		SET @decremento = CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2));
		SET @bit_decision = CAST(RAND(CHECKSUM(NEWID())) * 2 AS TINYINT);

		--Calcular el MONTO por bulto y por kilo/unidad.
		SET @monto = @monto + CAST((@incremento * (@maximo - @monto) - @decremento * (@monto - @minimo)) * @bit_decision AS INT);
		SET   @mpk = CAST(
			@mpk + 
			(@incremento * (@mapk - @mpk) - @decremento * (@mpk - @mipk)) * 
			@bit_decision 
			AS DECIMAL(7, 2));
		
		--PASO 4. Insertar el PRODUCTO, PROVEEDOR y MONTOs en la tabla de precios.
		INSERT INTO proveedores.precio (id_producto, id_proveedor, monto, mpk) VALUES
			(@id_producto, @id_proveedor, @monto, @mpk);
			
		SET @loop = @loop + 1;
	END
END
GO

EXEC proveedores.sp_generar_precios 1000
GO

SELECT TOP 50 id_producto, especie, procedencia, id_proveedor, nombre, pais, 
	minimo, monto, modal, CAST(CAST((monto - modal) * 100 AS FLOAT) / CAST(modal AS FLOAT) AS DECIMAL(3, 2)) AS 'diferencia (%)', maximo
FROM proveedores.precio pprecio INNER JOIN 
		datos.precios dprecio ON pprecio.id_producto = dprecio.id INNER JOIN 
		proveedores.proveedor pprov ON pprecio.id_proveedor = pprov.id
ORDER BY id_producto, monto DESC