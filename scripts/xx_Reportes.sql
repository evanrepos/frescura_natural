/*
------------------------------------------------------------
Universidad Nacional de La Matanza
Trabajo Práctico Integrador - Bases de Datos Aplicadas
Fecha de entrega: 04/03/2026
Integrantes: 					
- Gonzáles Fernándes Iván Alejandro		
- Mamani Estrada Lucas Gabriel			
------------------------------------------------------------
*/
----CREACIÓN DE SPs DE REPORTES

USE FrescuraNatural;
GO
---------------------------------------------------------
-- Alerta de vencimiento con xml
---------------------------------------------------------
CREATE OR ALTER PROCEDURE sucursales.sp_alerta_vencimientos_xml
AS
BEGIN
    SET NOCOUNT ON;

    WITH lotes_proximos AS (
        SELECT
            s.localidad AS sucursal,
            p.especie,
            p.variedad,
            l.nro AS nro_lote,
            CAST(l.fecha_vencimiento AS date) AS fecha_vencimiento,
            DATEDIFF(day, GETDATE(), l.fecha_vencimiento) AS dias_restantes,
            l.cantidad,
            l.peso_total
        FROM sucursales.lote l
        INNER JOIN sucursales.ingreso i ON i.id = l.id_ingreso
        INNER JOIN sucursales.sucursal s ON s.id = i.id_sucursal
        INNER JOIN productos.producto p ON p.id = l.id_producto
		WHERE l.fecha_vencimiento >= CAST(GETDATE() AS date)
			AND l.fecha_vencimiento <  DATEADD(day, 4, CAST(GETDATE() AS date))
    )
    SELECT
        sucursal AS [@sucursal],
        (
            SELECT
                especie           AS [@especie],
                ISNULL(variedad,'') AS [@variedad],
                nro_lote            AS [nro_lote],
                fecha_vencimiento   AS [fecha_vencimiento],
                dias_restantes      AS [dias_restantes],
                cantidad            AS [cantidad],
                peso_total          AS [peso_kg]
            FROM lotes_proximos l2
            WHERE l2.sucursal = l1.sucursal
            FOR XML PATH('lote'), TYPE
        )
    FROM (SELECT DISTINCT sucursal FROM lotes_proximos) l1
    FOR XML PATH('sucursal'), ROOT('alerta_vencimientos'), TYPE;
END;
GO

EXEC sucursales.sp_alerta_vencimientos_xml;

/* Borrar
-- Lote que vence hoy
INSERT INTO sucursales.lote
(id_producto, id_ingreso, cantidad, monto, fecha_vencimiento, peso_total)
VALUES
(1, 1, 5, 500, DATEADD(DAY, 0, GETDATE()), 10.0);

-- Lote que vence en 3 DÍAS 
INSERT INTO sucursales.lote
(id_producto, id_ingreso, cantidad, monto, fecha_vencimiento, peso_total)
VALUES
(1, 28, 4, 450, DATEADD(DAY, 3, GETDATE()), 8.5);

select * from productos.producto where id=1;
select * from sucursales.ingreso where id=1;
select * from sucursales.lote ORDER BY nro DESC;

*/

---------------------------------------------------------
-- Ranking de proveedores
---------------------------------------------------------
CREATE OR ALTER PROCEDURE proveedores.sp_top5_proveedores_por_categoria
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @desde DATE = DATEADD(MONTH, -1, CAST(GETDATE() AS date));

    WITH precios_mes AS (
        SELECT
            pc.descripcion AS categoria,
            pp.id_proveedor,
            AVG(pp.mpk) AS precio_prom_mpk
        FROM proveedores.precio pp
        INNER JOIN productos.producto p ON p.id = pp.id_producto
        INNER JOIN productos.categoria pc ON pc.id = p.id_categoria
        WHERE pp.fecha >= @desde     -- SOLO ÚLTIMO MES
          AND pp.mpk > 0
        GROUP BY pc.descripcion, pp.id_proveedor
    ),
    rankeados AS (
        SELECT
            categoria,
            id_proveedor,
            precio_prom_mpk,
            RANK() OVER (PARTITION BY categoria ORDER BY precio_prom_mpk ASC) AS rn
        FROM precios_mes
    )
    SELECT
        r.categoria,
        pr.id AS id_proveedor,
        pr.nombre AS proveedor,
        pr.pais,
        CAST(r.precio_prom_mpk AS DECIMAL(12,4)) AS precio_promedio_mpk
    FROM rankeados r
    INNER JOIN proveedores.proveedor pr ON pr.id = r.id_proveedor
    WHERE r.rn <= 5
    ORDER BY r.categoria, r.rn;
END
GO

EXEC proveedores.sp_top5_proveedores_por_categoria;