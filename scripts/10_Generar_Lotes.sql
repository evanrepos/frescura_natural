USE FrescuraNatural
GO

/*
DELETE FROM sucursales.ingreso
DBCC CHECKIDENT ('sucursales.ingreso', RESEED, 0)
GO
DELETE FROM sucursales.lote
DBCC CHECKIDENT ('sucursales.lote', RESEED, 0)
GO
*/

CREATE OR ALTER PROCEDURE sucursales.sp_generar_lotes (@cant_intentos INT)
AS
    DECLARE @especies TABLE (id INT IDENTITY(1, 1), orden_pop INT, especie VARCHAR(30));
    DECLARE @sucursal INT;
    DECLARE @cant_sucursales INT = (SELECT COUNT(1) FROM sucursales.sucursal) ;
    DECLARE @cant_prods INT; --CANTIDAD DE PRODUCTOS A PEDIR POR SUCURSAL
    DECLARE @factor_aparicion INT;
    DECLARE @id_proveedor INT;
    DECLARE @id_ingreso INT;
    DECLARE @fecha_ing DATETIME = GETDATE();
    DECLARE @i INT = 1; --POR CADA SUCURSAL.
    DECLARE @j INT = 1; --POR CADA NUMERO DE ORDEN
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #lotes_tmp
    (
        id_producto INT, 
        especie VARCHAR(50), 
        proveedor INT, 
        monto DECIMAL(7, 2)
    );

    CREATE TABLE #provs_tmp(
        fila INT IDENTITY(1, 1), 
        proveedor INT
    );

    --POR CADA SUCURSAL
    WHILE @i <= @cant_intentos
    BEGIN
        --Inicializar tablas
        TRUNCATE TABLE #lotes_tmp
        TRUNCATE TABLE #provs_tmp

        --Definir la cantidad de productos a importar por la sucursal, de forma ALEATORIA. Entre un 15% y un 40% de todos los productos.
        SET @sucursal = SELECT(CAST(RAND(CHECKSUM(NEWID())) * COUNT(1) AS INT) + 1 FROM sucursales.sucursal);
        SET @cant_prods = CAST(CAST(((RAND() / 4) + 0.15) * (SELECT COUNT(especie) FROM productos.producto) + 1 AS INT) AS INT);
       
        --POR CADA ORDEN DE POPULARIDAD
        SET @j = 1
        WHILE @j <= 6
        BEGIN
            SET @factor_aparicion = @cant_prods * (11 - (@j - 1) * 2) / 36;
            --Ingresar productos vendidos al mejor precio.
            WITH ranking AS (
                SELECT 
                    ROW_NUMBER() OVER (PARTITION BY pprod.especie, pprod.variedad ORDER BY mpk ASC) AS rn_especie,
                    pprod.id AS id, 
                    pprod.especie as especie, 
                    id_proveedor as proveedor, 
                    monto
	            FROM productos.producto pprod 
		            INNER JOIN proveedores.precio pprec 
			            ON pprod.id = pprec.id_producto
                WHERE orden_pop = @j AND peso > 0
            )
            INSERT INTO #lotes_tmp (id_producto, especie, proveedor, monto)
                SELECT TOP (@factor_aparicion) id, especie, proveedor, monto FROM ranking
                WHERE rn_especie = 1
                ORDER BY NEWID();
            
            SET @j = @j + 1
        END
        --Al terminar, la tabla lotes_tmp tendrá todos los lotes 'comprados' y hay que organizarlos por proveedor para armar los ingresos.
        
        --Por cada PROVEEDOR en la tabla de lotes.
        INSERT INTO #provs_tmp 
            SELECT DISTINCT proveedor FROM #lotes_tmp
        
        SET @j = 1
        WHILE @j <= (SELECT COUNT(1) FROM #provs_tmp)
        BEGIN
            --Encontrar el id de proveedor
            SELECT @id_proveedor = proveedor FROM #provs_tmp WHERE fila = @j

            --Determinar la fecha de ingreso
            SELECT @fecha_ing = DATEADD(MINUTE, (@j - 1) * 1, @fecha_ing);

            --INSERTAR el INGRESO en la tabla, con la fecha y el proveedor determinados.
            INSERT INTO sucursales.ingreso (id_proveedor, id_sucursal, fecha_hora, importe)
                SELECT DISTINCT @id_proveedor, @sucursal, @fecha_ing, SUM(monto) FROM #lotes_tmp WHERE proveedor = @id_proveedor;

            --Obtener el id de ingreso hecho anteriormente.
            SELECT @id_ingreso = id FROM sucursales.ingreso WHERE id_proveedor = @id_proveedor AND fecha_hora = @fecha_ing

            --Ingresar el lote en la tabla de lotes, ya vinculado con el ingreso.
            INSERT INTO sucursales.lote    
                SELECT DISTINCT id_producto, @id_ingreso, monto, @fecha_ing + pcateg.dias_caducidad, 1, pprod.peso FROM #lotes_tmp AS lote 
                    INNER JOIN productos.producto pprod ON lote.id_producto = pprod.id
                        INNER JOIN productos.categoria pcateg ON pprod.id_categoria = pcateg.id
                WHERE proveedor = @id_proveedor AND peso > 0;
                
            SET @j = @j + 1;   
        END
    --Al finalizar, los lotes de cada ingreso ya fueron ingresados por sucursal. Se vacía la tabla temporal y se pasa a otra sucursal.
    SET @i = @i + 1
    END
END
GO

EXEC sucursales.sp_generar_lotes 500
GO

--SELECT * FROM sucursales.ingreso
--GO
--SELECT * FROM sucursales.lote
--GO
SELECT TOP 50 slote.nro, id_producto, id_sucursal, pprod.especie, orden_pop, id_ingreso, slote.cantidad, slote.monto, fecha_vencimiento, peso_total 
    FROM sucursales.lote slote 
    INNER JOIN sucursales.ingreso sIng ON slote.id_ingreso = sIng.id
    INNER JOIN productos.producto pprod ON slote.id_producto = pprod.id
ORDER BY id_sucursal, especie