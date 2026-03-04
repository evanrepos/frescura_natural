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
---- TESTING DE SPs PARA ALTA, BAJA Y MODIFICACION DE TODAS LAS TABLAS

-- Antes de ejecutar un test es necesario ejecutar todos los anteriores

USE FrescuraNatural;
GO

SET NOCOUNT ON;
----------------------------------------------------------
-- SUCURSAL
----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_insert_sucursal @localidad = 'Morón';
SELECT * FROM sucursales.sucursal WHERE localidad = 'Morón';

-- Caso no exitoso (duplicado)
EXEC sucursales.sp_insert_sucursal @localidad = 'Morón';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_update_sucursal @id = 1, @localidad = 'Ramos Mejía';
SELECT * FROM sucursales.sucursal WHERE id = 1;

-- Caso no exitoso (ID inexistente y localida '')
EXEC sucursales.sp_update_sucursal @id = 999, @localidad = '';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_delete_sucursal @id = 1;
SELECT * FROM sucursales.sucursal WHERE id = 1;

-- Caso no exitoso  (ID inexistente)
EXEC sucursales.sp_delete_sucursal @id = 1;

----------------------------------------------------------
-- CAPACITADOR
----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_insert_capacitador 
    @numero_registro='REG100',
    @nombre='Cap Uno',
    @telefono=NULL,
    @mail='cap1@mail.com';
SELECT * FROM sucursales.capacitador;

-- Caso no exitoso
EXEC sucursales.sp_insert_capacitador 
    @numero_registro='',
    @nombre='';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_update_capacitador 
    @id=1,
    @numero_registro='REG100',
    @nombre='Cap Uno Upd',
    @telefono=NULL,
    @mail='cap1upd@mail.com';
SELECT * FROM sucursales.capacitador WHERE id=1;

-- Caso no exitoso
EXEC sucursales.sp_update_capacitador 
    @id=999,
    @numero_registro='REG100',
    @nombre='';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_delete_capacitador @id=1;
SELECT * FROM sucursales.capacitador WHERE id=1;

-- Caso no exitoso
EXEC sucursales.sp_delete_capacitador @id=1;


----------------------------------------------------------
-- VENDEDOR
----------------------------------------------------------
-- Necesita capacitador y sucursal
EXEC sucursales.sp_insert_capacitador 'REG200','CAP',NULL,'c@c.com';
EXEC sucursales.sp_insert_sucursal 'Lomas';

-- Caso exitoso
EXEC sucursales.sp_insert_vendedor 
    @id_capacitador=2,
    @id_sucursal=2,
    @nombre='Vend Uno',
    @fecha_capacitacion='2024-01-01';
SELECT * FROM sucursales.vendedor;

-- Caso no exitoso
EXEC sucursales.sp_insert_vendedor 
    @id_capacitador=999,
    @id_sucursal=999,
    @nombre='',
    @fecha_capacitacion='2050-01-01';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_update_vendedor 
    @id=1,
    @id_capacitador=2,
    @nombre='Vend Upd',
    @fecha_capacitacion='2024-01-02';
SELECT * FROM sucursales.vendedor WHERE id=1;

-- Caso no exitoso
EXEC sucursales.sp_update_vendedor 
    @id=999,
    @id_capacitador=999,
    @nombre='',
    @fecha_capacitacion='2050-01-01';

----------------------------------------------------------
-- Caso exitoso
EXEC sucursales.sp_delete_vendedor @id=1;
SELECT * FROM sucursales.vendedor WHERE id=1;

-- Caso no exitoso
EXEC sucursales.sp_delete_vendedor @id=1;


----------------------------------------------------------
-- PROVEEDOR
----------------------------------------------------------
-- Caso exitoso
EXEC proveedores.sp_insert_proveedor 
    @nombre='La Huerta',
    @pais='AR';
SELECT * FROM proveedores.proveedor;

-- Caso no exitoso
EXEC proveedores.sp_insert_proveedor 
    @nombre='La Huerta',
    @pais='AR';

----------------------------------------------------------
-- Caso exitoso
EXEC proveedores.sp_update_proveedor 
    @id=1,
    @nombre='La Huerta Upd',
    @pais='ARG';
SELECT * FROM proveedores.proveedor WHERE id=1;

-- Caso no exitoso
EXEC proveedores.sp_update_proveedor 
    @id=999,
    @nombre='',
    @pais='';

----------------------------------------------------------
-- Caso exitoso
EXEC proveedores.sp_delete_proveedor @id=1;
SELECT * FROM proveedores.proveedor WHERE id=1;

-- Caso no exitoso
EXEC proveedores.sp_delete_proveedor @id=1;


----------------------------------------------------------
-- INGRESO (requiere proveedor y sucursal)
----------------------------------------------------------
EXEC proveedores.sp_insert_proveedor 'Prov2','UY';
EXEC sucursales.sp_insert_sucursal 'Lanus';

-- Caso exitoso
DECLARE @d1 DATETIME = GETDATE();
EXEC proveedores.sp_insert_ingreso 
    @id_proveedor=2,
    @id_sucursal=3,
    @fecha_hora=@d1;
SELECT * FROM sucursales.ingreso;

-- Caso no exitoso
EXEC proveedores.sp_insert_ingreso 
    @id_proveedor=999,
    @id_sucursal=999,
    @fecha_hora=NULL;

----------------------------------------------------------
-- Caso exitoso
DECLARE @d2 DATETIME = GETDATE();
EXEC proveedores.sp_update_ingreso 
    @id=1,
    @id_proveedor=2,
    @id_sucursal=3,
    @fecha_hora=@d2;
SELECT * FROM sucursales.ingreso WHERE id=1;

-- Caso no exitoso
EXEC proveedores.sp_update_ingreso 
    @id=999,
    @id_proveedor=999,
    @id_sucursal=999,
    @fecha_hora=NULL;

----------------------------------------------------------
-- Caso exitoso
EXEC proveedores.sp_delete_ingreso @id=1;
SELECT * FROM sucursales.ingreso WHERE id=1;

-- Caso no exitoso
EXEC proveedores.sp_delete_ingreso @id=1;


----------------------------------------------------------
-- TEMPORADA
----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_insert_temporada 
    @descripcion='Verano',
    @mes_desde=1,
    @dia_desde=1;
SELECT * FROM productos.temporada;

-- Caso no exitoso
EXEC productos.sp_insert_temporada 
    @descripcion='',
    @mes_desde=20,
    @dia_desde=0;

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_update_temporada 
    @id=1,
    @descripcion='Verano Upd',
    @mes_desde=2,
    @dia_desde=1;
SELECT * FROM productos.temporada WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_update_temporada 
    @id=999,
    @descripcion='',
    @mes_desde=20,
    @dia_desde=0;

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_delete_temporada @id=1;
SELECT * FROM productos.temporada WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_delete_temporada @id=1;


----------------------------------------------------------
-- CATEGORIA (requiere temporada)
----------------------------------------------------------
EXEC productos.sp_insert_temporada 'T1',1,1;

-- Caso exitoso
EXEC productos.sp_insert_categoria 
    @id_temporada=2,
    @descripcion='Frutas',
    @dias_caducidad=10,
    @margen=20;
SELECT * FROM productos.categoria;

-- Caso no exitoso
EXEC productos.sp_insert_categoria 
    @id_temporada=999,
    @descripcion='',
    @dias_caducidad=0,
    @margen=0;

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_update_categoria 
    @id=1,
    @id_temporada=2,
    @descripcion='Frutas Upd',
    @dias_caducidad=12,
    @margen=25;
SELECT * FROM productos.categoria WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_update_categoria 
    @id=999,
    @id_temporada=999,
    @descripcion='',
    @dias_caducidad=0,
    @margen=0;

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_delete_categoria @id=1;
SELECT * FROM productos.categoria WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_delete_categoria @id=1;


----------------------------------------------------------
-- PRODUCTO (requiere categoría)
----------------------------------------------------------
EXEC productos.sp_insert_categoria 2,'Cat2',5,10;

-- Caso exitoso
EXEC productos.sp_insert_producto 
    @id_categoria=2,
    @especie='Manzana',
    @peso=500;
SELECT * FROM productos.producto;

-- Caso no exitoso
EXEC productos.sp_insert_producto 
    @id_categoria=999,
    @especie='';

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_update_producto 
    @id=1,
    @id_categoria=2,
    @especie='Manzana Upd',
    @peso=600;
SELECT * FROM productos.producto WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_update_producto 
    @id=999,
    @id_categoria=2,
    @especie='';

----------------------------------------------------------
-- Caso exitoso
EXEC productos.sp_delete_producto @id=1;
SELECT * FROM productos.producto WHERE id=1;

-- Caso no exitoso
EXEC productos.sp_delete_producto @id=1;


----------------------------------------------------------
-- CLIENTE
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_insert_cliente 
    @nombre='Juan',
    @direccion='Dir 1',
    @cuit_cuil='20345678901';
SELECT * FROM ventas.cliente;

-- Caso no exitoso
EXEC ventas.sp_insert_cliente 
    @nombre='',
    @direccion='',
    @cuit_cuil='123';

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_update_cliente 
    @id=1,
    @nombre='Juan Upd',
    @direccion='Dir 2',
    @cuit_cuil='20345678901';
SELECT * FROM ventas.cliente WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_update_cliente 
    @id=999,
    @nombre='',
    @direccion='',
    @cuit_cuil='0';

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_delete_cliente @id=1;
SELECT * FROM ventas.cliente WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_delete_cliente @id=1;


----------------------------------------------------------
-- PEDIDO (requiere cliente)
----------------------------------------------------------
EXEC ventas.sp_insert_cliente 'C2','Dir C2','20345678902';

-- Caso exitoso
EXEC ventas.sp_insert_pedido 
    @id_cliente=2,
    @fecha='2024-01-01';
SELECT * FROM ventas.pedido;

-- Caso no exitoso
EXEC ventas.sp_insert_pedido 
    @id_cliente=999,
    @fecha=NULL;

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_update_pedido 
    @id=1,
    @id_cliente=2,
    @fecha='2024-01-02';
SELECT * FROM ventas.pedido WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_update_pedido 
    @id=999,
    @id_cliente=999,
    @fecha=NULL;

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_delete_pedido @id=1;
SELECT * FROM ventas.pedido WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_delete_pedido @id=1;


----------------------------------------------------------
-- VENTA (requiere cliente + vendedor)
----------------------------------------------------------
EXEC sucursales.sp_insert_vendedor 2,2,'VFinal','2024-01-01';

-- Caso exitoso
DECLARE @d3 DATETIME = GETDATE();
EXEC ventas.sp_insert_venta 
    @id_cliente=2,
    @id_vendedor=2,
    @fecha_hora=@d3,
    @total=1000;
SELECT * FROM ventas.venta;

-- Caso no exitoso
EXEC ventas.sp_insert_venta 
    @id_cliente=999,
    @id_vendedor=999,
    @fecha_hora=NULL,
    @total=0;

----------------------------------------------------------
-- Caso exitoso
DECLARE @d4 DATETIME = GETDATE();
EXEC ventas.sp_update_venta 
    @id=1,
    @id_cliente=2,
    @id_vendedor=2,
    @fecha_hora=@d4,
    @total=1500;
SELECT * FROM ventas.venta WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_update_venta 
    @id=999,
    @id_cliente=999,
    @id_vendedor=999,
    @fecha_hora=NULL,
    @total=-1;

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_delete_venta @id=1;
SELECT * FROM ventas.venta WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_delete_venta @id=1;


----------------------------------------------------------
-- LINEA VENTA (requiere venta + producto)
----------------------------------------------------------
EXEC productos.sp_insert_producto 2,'ProdLV',NULL,NULL,NULL,NULL,NULL,NULL,300;
DECLARE @d5 DATETIME = GETDATE();
EXEC ventas.sp_insert_venta 2,2,@d5,500;

-- Caso exitoso
EXEC ventas.sp_insert_lineaVenta 
    @id_venta=2,
    @id_producto=2,
    @cantidad=5;
SELECT * FROM ventas.lineaVenta;

-- Caso no exitoso
EXEC ventas.sp_insert_lineaVenta 
    @id_venta=999,
    @id_producto=999,
    @cantidad=-1;

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_update_lineaVenta 
    @id=1,
    @id_venta=2,
    @id_producto=2,
    @cantidad=10;
SELECT * FROM ventas.lineaVenta WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_update_lineaVenta 
    @id=999,
    @id_venta=999,
    @id_producto=999,
    @cantidad=0;

----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_delete_lineaVenta @id=1;
SELECT * FROM ventas.lineaVenta WHERE id=1;

-- Caso no exitoso
EXEC ventas.sp_delete_lineaVenta @id=1;


----------------------------------------------------------
-- PRECIO
----------------------------------------------------------
EXEC proveedores.sp_insert_precio 
    @id_producto = 2,
    @id_proveedor = 2,
    @monto = 1200,
    @mpk = 12.5;
SELECT * FROM proveedores.precio WHERE id_producto = 2 AND id_proveedor = 2;

-- Caso no exitoso 
EXEC proveedores.sp_insert_precio 
    @id_producto = 2,
    @id_proveedor = 2,
    @monto = 1500,
    @mpk = 15.0;

----------------------------------------------------------
-- Caso exitoso 
EXEC proveedores.sp_update_precio 
    @id = 1,
    @id_producto = 2,
    @id_proveedor = 2,
    @monto = 1300,
    @mpk = 13.0;
SELECT * FROM proveedores.precio WHERE id = 1;

-- Caso no exitoso (UPDATE con producto inexistente)
EXEC proveedores.sp_update_precio 
    @id = 1,
    @id_producto = 999,
    @id_proveedor = 999,
    @monto = 0,
    @mpk = 0;

----------------------------------------------------------
-- Caso exitoso (DELETE)
EXEC proveedores.sp_delete_precio @id = 1;
SELECT * FROM proveedores.precio WHERE id = 1;

-- Caso no exitoso (DELETE inexistente)
EXEC proveedores.sp_delete_precio @id = 1;


----------------------------------------------------------
-- LOTE
----------------------------------------------------------
DECLARE @d6 DATETIME = GETDATE();
EXEC proveedores.sp_insert_ingreso 2,2,@d6;

-- Caso exitoso 
EXEC proveedores.sp_insert_lote 
    @id_producto = 2,
    @id_ingreso = 2,
    @fecha_ingreso = '2024-01-10';
SELECT * FROM sucursales.lote WHERE id_producto = 2 AND id_ingreso = 2;

-- Caso no exitoso 
EXEC proveedores.sp_insert_lote 
    @id_producto = 999,
    @id_ingreso = 999,
    @fecha_ingreso = '2050-01-01';

----------------------------------------------------------
-- Caso exitoso
EXEC proveedores.sp_update_lote 
    @numero = 1,
    @id_producto = 2,
    @id_ingreso = 2,
    @fecha_ingreso = '2024-01-15';
SELECT * FROM sucursales.lote WHERE nro = 1;

-- Caso no exitoso 
EXEC proveedores.sp_update_lote 
    @numero = 999,
    @id_producto = 999,
    @id_ingreso = 999,
    @fecha_ingreso = '2050-01-01';

----------------------------------------------------------
-- Caso exitoso 
EXEC proveedores.sp_delete_lote @numero = 1;
SELECT * FROM sucursales.lote;

-- Caso no exitoso
EXEC proveedores.sp_delete_lote @numero = 999;