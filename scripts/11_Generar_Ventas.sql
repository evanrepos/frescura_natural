USE FrescuraNatural
GO

/*
DELETE FROM ventas.lineaVenta;
DBCC CHECKIDENT ('ventas.lineaVenta', RESEED, 0);
GO
DELETE FROM ventas.venta;
DBCC CHECKIDENT ('ventas.venta', RESEED, 0);
GO
DELETE FROM ventas.cliente;
DBCC CHECKIDENT ('ventas.cliente', RESEED, 0);
GO
*/

CREATE OR ALTER PROCEDURE ventas.generar_clientes (@path NVARCHAR(MAX), @cant_clientes INT)
AS
    DECLARE @json NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);
	DECLARE @i INT = 1;
    --DECLARE @control_bit BIT = 0;
	DECLARE @prefijo TINYINT;
	DECLARE @CUIL CHAR(13);
    DECLARE @id_sucursal INT;
    DECLARE @id_capacitador INT;
    DECLARE @nombre VARCHAR(MAX);
    DECLARE @apellido VARCHAR(MAX);
    DECLARE @date DATE;
BEGIN
	SET NOCOUNT ON
    --1. Convertir archivo a json.
    SET @sql = '
        SELECT @json_out = BulkColumn
        FROM OPENROWSET(
            BULK ''' + @path + ''',
            SINGLE_CLOB
        ) AS j;
    ';

    EXEC sp_executesql 
        @sql,
        N'@json_out NVARCHAR(MAX) OUTPUT',
        @json_out = @json OUTPUT;

	--2. GENERAR CLIENTES
    WHILE @i <= @cant_clientes
    BEGIN
        --Elige nombre de hombre o mujer.
        IF (SELECT CAST(RAND(CHECKSUM(NEWID())) * 2 AS INT)) = 1
        BEGIN
            SELECT TOP 1 @nombre = nombre, @prefijo = 27 FROM json_to_function(@json, 'femalename')
            ORDER BY NEWID()
        END
        ELSE
        BEGIN
            SELECT TOP 1 @nombre = nombre, @prefijo = 20 FROM json_to_function(@json, 'malename')
            ORDER BY NEWID()
        END

        --Elige apellido.
        SELECT TOP 1 @apellido = nombre FROM json_to_function(@json, 'lastname')
        ORDER BY NEWID()

		--Genera el CUIL
		SELECT @CUIL = CAST(20 AS CHAR(2)) + '-' + CAST(CAST(RAND(CHECKSUM(NEWID())) * 25000000 + 10000000 AS INT) AS CHAR(8)) + '-' + CAST(CAST(RAND(CHECKSUM(NEWID())) * 10 AS INT) AS CHAR(1));

    --3. INSERCIÓN DE DATOS.
		IF NOT EXISTS (SELECT id FROM ventas.cliente WHERE cuit_cuil = @CUIL)
		BEGIN
			INSERT INTO ventas.cliente (nombre, cuit_cuil) VALUES
				(@nombre + ' ' + @apellido, @CUIL);
		END

		SET @i = @i + 1;
    END
	RETURN
END
GO

EXEC ventas.generar_clientes 'E:\frescura_natural\fuente\05.nombres\data.json', 50
GO
--SELECT TOP 20 * FROM ventas.cliente
--GO

CREATE OR ALTER PROCEDURE ventas.sp_simular_movimientos (@fecha_limite DATETIME)
AS
	DECLARE @sucursal INT;
	DECLARE @cant_ventas INT;
	DECLARE @cant_sucursales INT = (SELECT COUNT(1) FROM sucursales.sucursal);
	DECLARE @peso_total DECIMAL(6, 3);
	DECLARE @j INT = 1;
	DECLARE @cant_prods INT;
	DECLARE @peso DECIMAL(6, 3);
	DECLARE @precio DECIMAL(10, 2);
	DECLARE @importe_total DECIMAL(10, 2);
	DECLARE @nro_lote INT;
	DECLARE @especie INT;
	DECLARE @cliente INT;
	DECLARE @vendedor INT;
	DECLARE @fecha_movil DATETIME = GETDATE();
	DECLARE @id_venta INT;
BEGIN
	SET NOCOUNT ON
	CREATE TABLE #carrito (
		id INT IDENTITY(1, 1),
		id_producto INT,
		cantidad INT,
		peso DECIMAL(6, 3),
		subtotal DECIMAL(10, 2)
	);

	--Por CADA SUCURSAL, dentro de la fecha límite.
	WHILE @fecha_movil < @fecha_limite
	BEGIN
		--Elegir sucursal
		SELECT @sucursal = CAST(RAND(CHECKSUM(NEWID())) * COUNT(1) AS INT) + 1 FROM sucursales.sucursal
		
		--Guarda todos los datos de productos en stock de una sucursal dada en una tabla temporal #stock.
		SELECT nro AS nro, id_ingreso,id_producto, especie, pprod.cantidad, pprod.precioXKg, fecha_hora, fecha_vencimiento, peso_total INTO #stock
			FROM sucursales.lote slote 
				INNER JOIN sucursales.ingreso sIng ON slote.id_ingreso = sIng.id
					INNER JOIN productos.producto pprod ON slote.id_producto = pprod.id 
			WHERE (peso_total > 0 /*OR pprod.cantidad > 0*/) AND id_sucursal = @sucursal AND pprod.precioXKg > 0 AND @fecha_movil < fecha_vencimiento
			ORDER BY fecha_vencimiento;

		--Guarda las distintas especies en una tabla temporal #especies.
		SELECT DISTINCT pprod.id, especie INTO #especies
			FROM sucursales.lote slote 
				INNER JOIN sucursales.ingreso sIng ON slote.id_ingreso = sIng.id
					INNER JOIN productos.producto pprod ON slote.id_producto = pprod.id 
			WHERE (peso_total > 0 /*OR pprod.cantidad > 0*/) AND id_sucursal = @sucursal AND pprod.precioXKg > 0 AND @fecha_movil < fecha_vencimiento

		---------------------------------------------------------------------------------------------------------------------------------------------------
		--LA TRANSACCIÓN DEBERÍA EMPEZAR DONDE EMPIEZA LA VENTA, LA SELECCIÓN DEL PRODUCTO, LA CANTIDAD, EL COBRO...
		BEGIN TRAN
			--Elegir el vendedor y el cliente.
			SELECT TOP 1 @vendedor = id FROM sucursales.vendedor
			ORDER BY NEWID()

			SELECT TOP 1 @cliente = id FROM ventas.cliente
			ORDER BY NEWID()

			--Determinar cantidad de productos
			SET @j = 1;
			SET @cant_prods = (SELECT CAST(RAND() * COUNT(1) * 0.125 AS INT) + 1 FROM #especies);
			WHILE @j < @cant_prods
			BEGIN
				--Elegir un producto
				SELECT TOP 1 @nro_lote = nro, @especie = id_producto FROM #stock ORDER BY NEWID()

				--Elegir el peso
				SELECT @peso = CAST(RAND() * peso_total AS DECIMAL(6, 3)) FROM #stock WHERE nro = @nro_lote

				--Si hay suficiente peso, se agrega al carrito.
				IF @peso < (SELECT peso_total FROM #stock WHERE nro = @nro_lote)
				BEGIN
					SELECT @precio = CAST(precioXKg * @peso AS DECIMAL(10, 2)) FROM #stock WHERE nro = @nro_lote
					INSERT INTO #carrito VALUES
						(@especie, 1, @peso, @precio)
				END
				--Si no hay stock, que importe mas lotes. En tanto, el peso 
				ELSE
				BEGIN
					SELECT @peso = peso_total FROM #stock WHERE nro = @nro_lote
					EXEC sucursales.sp_generar_lotes
				END
				SET @j = @j + 1
			END

			SELECT @importe_total = SUM(subtotal) FROM #carrito
			INSERT INTO ventas.venta VALUES
				(@cliente, @vendedor, @fecha_movil, @importe_total)

			--SELECT @id_venta, id_producto, cantidad, peso, subtotal FROM #carrito

			SELECT @id_venta = id FROM ventas.venta WHERE fecha_hora = @fecha_movil;
			--SELECT @id_venta, id_producto, cantidad, peso, subtotal FROM #carrito;

			INSERT INTO ventas.lineaVenta (id_venta, id_producto, cantidad, peso, subtotal)
				SELECT @id_venta, id_producto, cantidad, peso, subtotal FROM #carrito

			UPDATE sucursales.lote SET peso_total = peso_total - @peso WHERE nro = @nro_lote;
		COMMIT TRAN
		---------------------------------------------------------------------------------------------------------------------------------------------------
		DROP TABLE #especies
		DROP TABLE #stock;
		TRUNCATE TABLE #carrito;

		SET @fecha_movil = DATEADD(DAY, 1, @fecha_movil)
	END

END
GO

DECLARE @fecha_limite DATETIME = DATEADD(DAY, 15, GETDATE());
EXEC ventas.sp_simular_movimientos @fecha_limite;
GO

SELECT * FROM ventas.venta
SELECT * FROM ventas.lineaVenta
