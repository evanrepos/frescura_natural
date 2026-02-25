USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE proveedores.sp_generar_precios (@cant_reg INT = 1000)
AS
	DECLARE @loop INT;
	DECLARE @intentos TINYINT;
	DECLARE @id_producto INT;
	DECLARE @id_proveedor INT;
	DECLARE @cant_prov INT;
	DECLARE @pais VARCHAR(MAX);
	DECLARE @cant_precios INT = (SELECT COUNT(1) FROM datos.precios);
	DECLARE @monto DECIMAL(8, 2);
BEGIN
	SET NOCOUNT ON
	
	--Configurar variables iterativas, y límite de iteración por cantidad de proveedores.
	SET @loop = 1;
	--Por cada proveedor
	WHILE @loop <= @cant_reg
	BEGIN
		--Elegir el precio a asignar.
		SELECT @id_producto = CAST(RAND(CHECKSUM(NEWID())) * @cant_precios AS INT) + 1;
		SELECT TOP 1
			@id_producto = id,
			@pais = procedencia,
			@monto = modal + (CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2)) * (maximo - modal) 
						    - CAST(RAND(CHECKSUM(NEWID())) AS DECIMAL(2, 2)) * (modal - minimo)) * 
							CAST(RAND(CHECKSUM(NEWID())) * 2 AS INT)
		FROM datos.precios
		ORDER BY NEWID();
		
		--ELEGIR EL PROVEEDOR CON LA PROCEDENCIA COINCIDENTE.
		--Elige un número de orden de la lista de proveedores.
		SELECT @cant_prov = (SELECT COUNT(1) FROM proveedores.proveedor WHERE pais = @pais);
		SELECT @id_proveedor = CAST(RAND(CHECKSUM(NEWID())) * @cant_prov AS INT) + 1;
		--Toma el identificador del proveedor en la fila encontrada.
		WITH proveedores AS (
			SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS fila, * FROM proveedores.proveedor WHERE pais = @pais
		)
		SELECT @id_proveedor = id FROM proveedores WHERE fila = @id_proveedor 
		
		--Insertar el producto, proveedor y monto en la tabla de precios.
		INSERT INTO proveedores.precio (id_producto, id_proveedor, monto) VALUES
			(@id_producto, @id_proveedor, @monto);

		SET @loop = @loop + 1;
	END
END
GO

EXEC proveedores.sp_generar_precios 1000
GO
