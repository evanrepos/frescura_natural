/*
------------------------------------------------------------
Universidad Nacional de La Matanza
Trabajo Práctico Integrador - Bases de Datos Aplicadas
Integrantes: 
Apellido y Nombre						
Gonzáles Fernándes Iván Alejandro		
Juan Bautista Sabaris					
Mamani Estrada Lucas Gabriel			
------------------------------------------------------------
*/
----CREACIÓN DE LA BASE DE DATOS

USE master;
GO

-- Eliminar DB si existe
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FrescuraNatural')
BEGIN
    ALTER DATABASE FrescuraNatural SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FrescuraNatural;
END
GO

-- Crear DB
CREATE DATABASE FrescuraNatural;
GO

USE FrescuraNatural;
GO

PRINT 'Base de datos FrescuraNatural creada correctamente';
GO

----------------------------------------------------------------
-- CREACIÓN DE ESQUEMAS
----------------------------------------------------------------
CREATE SCHEMA productos;     
GO
CREATE SCHEMA proveedores; 
GO
CREATE SCHEMA sucursales;  
GO
CREATE SCHEMA ventas;     
GO

PRINT 'Esquemas creados correctamente';
GO
----------------------------------------------------------------
-- ESQUEMA: sucursales (sucursal, capacitador, vendedor)
----------------------------------------------------------------
CREATE TABLE sucursales.sucursal (
    id_sucursal INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    localidad VARCHAR(100) NOT NULL
);

CREATE TABLE sucursales.capacitador (
    id_capacitador INT IDENTITY(1,1) PRIMARY KEY,
    numero_registro VARCHAR(31) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(12),
    mail VARCHAR(40)
);

CREATE TABLE sucursales.vendedor (
    id_vendedor INT IDENTITY(1,1) PRIMARY KEY,
    id_capacitador INT NOT NULL,
    id_sucursal INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    fecha_capacitacion DATE,
    CONSTRAINT FK_vendedor_capacitador FOREIGN KEY (id_capacitador) 
		REFERENCES sucursales.capacitador (id_capacitador),
    CONSTRAINT FK_vendedor_sucursal FOREIGN KEY (id_sucursal)
		REFERENCES sucursales.Sucursal (id_sucursal)
);
GO
----------------------------------------------------------------
-- ESQUEMA: proveedores (proveedor)
----------------------------------------------------------------

CREATE TABLE proveedores.proveedor (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    direccion VARCHAR(100),
    telefono VARCHAR(20)
);
GO

----------------------------------------------------------------
-- ESQUEMA: productos (categoria, temporada, producto)
----------------------------------------------------------------

CREATE TABLE productos.categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);


CREATE TABLE productos.temporada (
    id_temporada INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

CREATE TABLE productos.producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    id_proveedor INT NOT NULL,
    id_categoria INT NOT NULL,
    id_temporada INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    precio DECIMAL(8,2) NOT NULL,
	CONSTRAINT CK_producto_precio CHECK (precio >= 0),
    CONSTRAINT FK_Producto_Proveedor FOREIGN KEY (id_proveedor) 
		REFERENCES proveedores.proveedor (id_proveedor),
    CONSTRAINT FK_producto_categoria FOREIGN KEY (id_categoria) 
		REFERENCES productos.categoria (id_categoria),
    CONSTRAINT FK_producto_temporada FOREIGN KEY (id_temporada) 
		REFERENCES productos.temporada (id_temporada)
);
GO

----------------------------------------------------------------
-- ESQUEMA: proveedores (ingreso, lote, lineaIngreso)
----------------------------------------------------------------

CREATE TABLE proveedores.ingreso (
    id_ingreso INT IDENTITY(1,1) PRIMARY KEY,
    id_proveedor INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_hora DATETIME NOT NULL,--capaz  DEFAULT GETDATE()
    CONSTRAINT FK_ingreso_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores.proveedor (id_proveedor),
    CONSTRAINT FK_ingreso_sucursal  FOREIGN KEY (id_sucursal)
        REFERENCES sucursales.sucursal (id_sucursal)
);

CREATE TABLE proveedores.lote (
    numero INT IDENTITY(1,1) PRIMARY KEY,--capaz sin IDENTITY o con un id con identity y otro campo con numero
    id_producto INT NOT NULL,
    id_ingreso INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    CONSTRAINT FK_lote_producto FOREIGN KEY (id_producto)
        REFERENCES productos.producto (id_producto),
    CONSTRAINT FK_lote_ingreso  FOREIGN KEY (id_ingreso)
        REFERENCES proveedores.ingreso (id_ingreso)
);

CREATE TABLE proveedores.lineaIngreso (
    numero INT IDENTITY(1,1) NOT NULL PRIMARY KEY,--capaz sin IDENTITY o con un id con identity y otro campo con numero
    numero_lote INT NOT NULL,
    cantidad SMALLINT NOT NULL,
    CONSTRAINT CK_lineaIngreso_cantidad CHECK (cantidad > 0),
    CONSTRAINT FK_lineaIngreso_lote FOREIGN KEY (numero_lote)
        REFERENCES proveedores.lote (numero)
);
GO

----------------------------------------------------------------
-- ESQUEMA: ventas (cliente, pedido, venta, lineaVenta)
----------------------------------------------------------------

CREATE TABLE ventas.cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    cuit_cuil CHAR(11) NULL,
	CONSTRAINT CK_cliente_cUIT_Formato CHECK (
        cuit_cuil IS NULL OR (LEN(cuit_cuil) = 11 AND cuit_cuil NOT LIKE '%[^0-9]%'))
);

CREATE TABLE ventas.pedido (--revisar
    id_pedido INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    CONSTRAINT FK_pedido_cliente FOREIGN KEY (id_cliente)--esta bien?
        REFERENCES ventas.cliente (id_cliente)
);

CREATE TABLE ventas.venta (--falta agregar la fk de pedido??
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    total DECIMAL(9,2) NOT NULL,
    CONSTRAINT CK_venta_total CHECK (total > 0),
    CONSTRAINT FK_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES ventas.cliente (id_cliente),
    CONSTRAINT FK_venta_vendedor FOREIGN KEY (id_vendedor)
        REFERENCES sucursales.vendedor (id_vendedor)
);

CREATE TABLE ventas.lineaVenta (
    id_lineaVenta INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad SMALLINT NOT NULL,
    CONSTRAINT CK_lineaVenta_cantidad CHECK (cantidad > 0),
    CONSTRAINT FK_lineaVenta_venta FOREIGN KEY (id_venta)
        REFERENCES ventas.venta (id_venta),
    CONSTRAINT FK_lineaVenta_producto FOREIGN KEY (id_producto)
        REFERENCES productos.producto (id_producto)
);
GO

----------------------------------------------------------------
-- ESQUEMA: proveedores (precio)
----------------------------------------------------------------

CREATE TABLE proveedores.precio (
    id_precio INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    monto DECIMAL(8,2) NOT NULL,
    CONSTRAINT CK_precio_monto CHECK (monto > 0),
    CONSTRAINT FK_precio_producto FOREIGN KEY (id_producto)
        REFERENCES productos.producto (id_producto),
    CONSTRAINT FK_precio_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores.proveedor (id_proveedor)
);
GO

----------------------------------------------------------------
-- ESQUEMA: sucursales (mermas)
----------------------------------------------------------------

CREATE TABLE sucursales.merma (
	id_merma INT IDENTITY(1,1) PRIMARY KEY,
	fecha DATE NOT NULL,
	id_producto INT NOT NULL,
	cantidad INT NOT NULL,
	id_sucursal INT NOT NULL,
	CONSTRAINT CK_merma_cantidad CHECK (cantidad > 0),
	CONSTRAINT FK_merma_producto FOREIGN KEY (id_producto)
        REFERENCES productos.producto (id_producto),
    CONSTRAINT FK_merma_sucursal FOREIGN KEY (id_sucursal)
        REFERENCES sucursales.sucursal (id_sucursal)
);
GO

PRINT 'Tablas creadas correctamente';
GO

