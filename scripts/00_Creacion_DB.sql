/*
------------------------------------------------------------
Universidad Nacional de La Matanza
Trabajo Práctico Integrador - Bases de Datos Aplicadas
Integrantes: 
Apellido y Nombre						
Gonzáles Fernándes Iván Alejandro		
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
CREATE SCHEMA datos;
GO
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
-- ESQUEMA: datos (mermas, estimaciones, precios)
----------------------------------------------------------------
CREATE TABLE datos.mermas (
    fecha DATETIME,
    producto VARCHAR(30),
    cantidad SMALLINT,
    sucursal VARCHAR(30),
    CONSTRAINT UQ_datos_mermas UNIQUE (fecha, producto, cantidad, sucursal)
);

CREATE TABLE datos.estimaciones (
    cultivo VARCHAR(30), 
    campaña CHAR(7), 
    municipio_id CHAR(5), 
    municipio_nombre VARCHAR(50), 
    superficie_sembrada INT,
    superficie_cosechada INT,
    produccion INT,
    rendimiento INT,
    CONSTRAINT UQ_datos_estimaciones UNIQUE (cultivo, campaña, municipio_id)
);

CREATE TABLE datos.precios 
(
    id INT IDENTITY(1, 1),
    especie VARCHAR(30),
    variedad VARCHAR(30),
    procedencia VARCHAR(30),
    envase CHAR(2),
    peso DECIMAL(6, 3),
    calidad CHAR(3),
    tamaño VARCHAR(12),
    grado CHAR(3),
    maximo INT,
    modal INT,
    minimo INT,
    mapk DECIMAL(7, 2),
    mopk DECIMAL(7, 2),
    mipk DECIMAL(7, 2),
    CONSTRAINT PK_id_precio PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_datos_precios 
        UNIQUE (especie, variedad, procedencia, envase, peso, calidad, tamaño, grado),
    CONSTRAINT CK_precios 
        CHECK (maximo >= 0 AND modal >= 0 AND minimo >= 0 AND mapk >= 0 AND mopk >= 0 AND mipk >= 0)
);

----------------------------------------------------------------
-- ESQUEMA: productos (categoria, temporada, producto)
----------------------------------------------------------------

CREATE TABLE productos.temporada (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    descripcion VARCHAR(50) NOT NULL,
    mes_desde TINYINT,
    dia_desde TINYINT,
);

CREATE TABLE productos.categoria (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_temporada INT NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    dias_caducidad TINYINT,
    margen TINYINT,
    CONSTRAINT FK_temporada FOREIGN KEY (id_temporada) REFERENCES productos.temporada(id)
);


--Esta tabla contempla los datos de origen, como el precio de venta por unidad en stock.
CREATE TABLE productos.producto (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_categoria INT NOT NULL,
    orden_pop TINYINT NOT NULL,
    especie VARCHAR(50) NOT NULL,
    variedad VARCHAR(50),
    procedencia VARCHAR(50),
	envase CHAR(2),
	calidad CHAR(2),
	tamaño VARCHAR(12),
	grado CHAR(3),
    peso DECIMAL(6, 3),
    cantidad SMALLINT,
    precioXKg DECIMAL(7, 2) NOT NULL,
    CONSTRAINT FK_categoria FOREIGN KEY (id_categoria) REFERENCES productos.categoria(id),
    CONSTRAINT UQ_producto UNIQUE (especie, variedad, procedencia, envase, peso, calidad, tamaño, grado)
);
GO


----------------------------------------------------------------
-- ESQUEMA: proveedores (proveedor, ingreso, lote, lineaIngreso, precio)
----------------------------------------------------------------

CREATE TABLE proveedores.proveedor (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    nombre VARCHAR(30) NOT NULL,
    pais VARCHAR(20),
    CONSTRAINT UQ_proveedor UNIQUE (nombre, pais)
);
GO


CREATE TABLE proveedores.precio (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    monto INT NOT NULL,
    mpk DECIMAL(7, 2) NOT NULL,
    fecha AS CAST(SYSDATETIME() AS DATE),
    CONSTRAINT CK_precio_monto CHECK (monto > 0),
    --CONSTRAINT FK_precio_producto FOREIGN KEY (id_producto)
    --    REFERENCES productos.producto (id),
    --CONSTRAINT FK_precio_proveedor FOREIGN KEY (id_proveedor)
    --    REFERENCES proveedores.proveedor (id),
    CONSTRAINT UQ_producto_proveedor UNIQUE (id_producto, id_proveedor)
);
GO

----------------------------------------------------------------
-- ESQUEMA: sucursales (sucursal, capacitador, vendedor)
----------------------------------------------------------------
CREATE TABLE sucursales.sucursal (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    localidad VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_sucursal_localidad UNIQUE (localidad)
);

CREATE TABLE sucursales.capacitador (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    numero_registro VARCHAR(31),
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(12),
    mail VARCHAR(40)
);

CREATE TABLE sucursales.vendedor (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_capacitador INT NOT NULL,
    id_sucursal INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    fecha_capacitacion DATE,
    CONSTRAINT FK_vendedor_capacitador FOREIGN KEY (id_capacitador) 
		REFERENCES sucursales.capacitador (id),
    CONSTRAINT FK_vendedor_sucursal FOREIGN KEY (id_sucursal)
		REFERENCES sucursales.Sucursal (id)
);
GO

CREATE TABLE sucursales.ingreso (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_proveedor INT NOT NULL,
    id_sucursal INT NOT NULL,
    fecha_hora DATETIME NOT NULL,--capaz  DEFAULT GETDATE()
    importe DECIMAL(9, 2),
    CONSTRAINT FK_ingreso_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedores.proveedor (id),
    CONSTRAINT FK_ingreso_sucursal  FOREIGN KEY (id_sucursal)
        REFERENCES sucursales.sucursal (id)
);

CREATE TABLE sucursales.lote (
    nro INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,--capaz sin IDENTITY o con un id con identity y otro campo con numero
    id_producto INT NOT NULL,
    id_ingreso INT NOT NULL,
    monto DECIMAL(10, 2),
    fecha_vencimiento DATETIME,
    cantidad SMALLINT,
    peso_total DECIMAL(6, 3),
    CONSTRAINT CK_lote_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_lote_monto CHECK (monto >= 0),
    CONSTRAINT FK_lote_producto FOREIGN KEY (id_producto)
        REFERENCES productos.producto (id),
    CONSTRAINT FK_lote_ingreso  FOREIGN KEY (id_ingreso)
        REFERENCES sucursales.ingreso (id)
);

----------------------------------------------------------------
-- ESQUEMA: ventas (cliente, pedido, venta, lineaVenta)
----------------------------------------------------------------

CREATE TABLE ventas.cliente (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    nombre VARCHAR(50) NOT NULL,
    --direccion VARCHAR(100) NOT NULL,
    cuit_cuil CHAR(13) NULL,
	CONSTRAINT CK_cliente_cUIT_Formato CHECK (
        cuit_cuil IS NULL OR (LEN(cuit_cuil) = 13 AND cuit_cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'))
);

CREATE TABLE ventas.pedido (--revisar
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_cliente INT NOT NULL,
    fecha DATE NOT NULL,
    CONSTRAINT FK_pedido_cliente FOREIGN KEY (id_cliente)--esta bien?
        REFERENCES ventas.cliente (id)
);

CREATE TABLE ventas.venta (--falta agregar la fk de pedido??
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    importe_total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT CK_venta_total CHECK (importe_total > 0),
    --CONSTRAINT FK_venta_cliente FOREIGN KEY (id_cliente)
        --REFERENCES ventas.cliente (id),
    --CONSTRAINT FK_venta_vendedor FOREIGN KEY (id_vendedor)
        --REFERENCES sucursales.vendedor (id)
);

CREATE TABLE ventas.lineaVenta (
    id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT, 
    peso DECIMAL(6, 3),
    subtotal DECIMAL(8, 2),
    --CONSTRAINT FK_lineaVenta_venta FOREIGN KEY (id_venta)
        --REFERENCES ventas.venta (id),
    --CONSTRAINT FK_lineaVenta_producto FOREIGN KEY (id_producto)
        --REFERENCES productos.producto (id)
);
GO

PRINT 'Tablas creadas correctamente';
GO