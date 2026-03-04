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
---- CIFRADO DE DATOS SENSIBLES

USE FrescuraNatural;
GO
-- 1) Mostrar datos sin cifrar
SELECT TOP 5 * FROM ventas.cliente;
SELECT TOP 5 * FROM sucursales.capacitador;
GO

-- 2) Ejecutar scrip de cifrado

-- 3) Mostrar datos cifrados
SELECT TOP 5 * FROM ventas.cliente;
SELECT TOP 5 * FROM sucursales.capacitador;
GO

-- 4) Ejecutar SPs para descifrar
EXEC seguridad.descifrar_clientes N'ClaveSecreta2026$';
EXEC seguridad.descifrar_capacitadores N'ClaveSecreta2026$';
GO



/*
SELECT * FROM ventas.cliente;
SELECT * FROM sucursales.capacitador;

EXEC sucursales.sp_insert_capacitador 
    @numero_registro='REG100',
    @nombre='Cap Uno',
    @telefono=NULL,
    @mail='cap1@mail.com';

EXEC ventas.sp_insert_cliente 
    @nombre='Juan',
    @direccion='Dir 1',
    @cuit_cuil='20345678901';
*/