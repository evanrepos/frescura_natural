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
---- CREACION DE SPs PARA ALTA, BAJA Y MODIFICACION DE TODAS LAS TABLAS

USE FrescuraNatural
GO
----------------------------------------------------------
-- SUCURSAL
----------------------------------------------------------
IF OBJECT_ID('sucursales.sp_insert_sucursal') IS NOT NULL
    DROP PROCEDURE sucursales.sp_insert_sucursal;
GO
CREATE PROCEDURE sucursales.sp_insert_sucursal
    @localidad VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF @localidad IS NULL OR LTRIM(RTRIM(@localidad)) = ''
        SET @err += '- La localidad es obligatoria.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM sucursales.sucursal WHERE localidad = @localidad)
        SET @err += '- Ya existe una sucursal con esa localidad.' + CHAR(10);

    IF LEN(@err) > 0
	BEGIN 
        RAISERROR(@err, 16, 1);
		RETURN;
	END

    INSERT INTO sucursales.sucursal(localidad) VALUES(@localidad);
	SELECT 'Sucursal insertada correctamente' AS mensaje;
END
GO

IF OBJECT_ID('sucursales.sp_update_sucursal') IS NOT NULL
    DROP PROCEDURE sucursales.sp_update_sucursal;
GO
CREATE PROCEDURE sucursales.sp_update_sucursal
    @id INT,
    @localidad VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id)
        SET @err += '- No existe la sucursal.' + CHAR(10);

    IF @localidad IS NULL OR LTRIM(RTRIM(@localidad)) = ''
        SET @err += '- La localidad es obligatoria.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM sucursales.sucursal 
		WHERE localidad = @localidad AND id <> @id)
        SET @err += '- Ya existe otra sucursal con esa localidad.' + CHAR(10);

    IF LEN(@err) > 0
	BEGIN
        RAISERROR(@err, 16, 1);
		RETURN;
	END

    UPDATE sucursales.sucursal SET localidad = @localidad WHERE id = @id;
	SELECT 'Sucursal actualizada correctamente' AS mensaje;
END
GO

IF OBJECT_ID('sucursales.sp_delete_sucursal') IS NOT NULL
    DROP PROCEDURE sucursales.sp_delete_sucursal;
GO
CREATE PROCEDURE sucursales.sp_delete_sucursal
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id)
        SET @err += '- No existe la sucursal indicada.' + CHAR(10);

    -- vendedores en esta sucursal
    IF EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id_sucursal = @id)
        SET @err += '- No se puede eliminar, hay vendedores asociados a la sucursal.' + CHAR(10);
    
	-- ingresos de proveedores a esta sucursal
    IF EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id_sucursal = @id)
        SET @err += '- No se puede eliminar: hay ingresos de proveedores asociados a la sucursal.' + CHAR(10);

    IF LEN(@err) > 0
	BEGIN
        RAISERROR(@err, 16, 1);
		RETURN;
	END;

    DELETE FROM sucursales.sucursal WHERE id = @id;
    SELECT 'Sucursal eliminada correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- CAPACITADOR
----------------------------------------------------------
IF OBJECT_ID('sucursales.sp_insert_capacitador') IS NOT NULL
    DROP PROCEDURE sucursales.sp_insert_capacitador;
GO
CREATE PROCEDURE sucursales.sp_insert_capacitador
    @numero_registro VARCHAR(31),
    @nombre          VARCHAR(50),
    @telefono        VARCHAR(12) = NULL,
    @mail            VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del capacitador es obligatorio.' + CHAR(10);

    IF @numero_registro IS NULL OR LTRIM(RTRIM(@numero_registro)) = ''
        SET @err += '- El número de registro es obigatorio.' + CHAR(10);

    IF @telefono IS NOT NULL AND (@telefono LIKE '%[^0-9]%' OR LEN(@telefono) > 12)
        SET @err += '- El teléfono debe tener solo numeros y hasta 12 caracteres.' + CHAR(10);

    IF @mail IS NOT NULL AND (LEN(@mail) > 40 OR @mail NOT LIKE '%_@_%._%')
        SET @err += '- El mail no tiene formato válido o supera 40 caracteres.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO sucursales.capacitador (numero_registro, nombre, telefono, mail)
    VALUES (@numero_registro, @nombre, @telefono, @mail);

    SELECT 'Capacitador insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('sucursales.sp_update_capacitador') IS NOT NULL
    DROP PROCEDURE sucursales.sp_update_capacitador;
GO
CREATE PROCEDURE sucursales.sp_update_capacitador
    @id              INT,
    @numero_registro VARCHAR(31),
    @nombre          VARCHAR(50),
    @telefono        VARCHAR(12) = NULL,
    @mail            VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.capacitador WHERE id = @id)
        SET @err += '- No existe el capacitador indicado.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del capacitador es obligatorio.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM sucursales.capacitador 
		WHERE numero_registro = @numero_registro AND id <> @id)
        SET @err += '- Ya existe otra capacitador con ese número de registro.' + CHAR(10);

    IF @telefono IS NOT NULL AND (@telefono LIKE '%[^0-9]%' OR LEN(@telefono) > 12)
        SET @err += '- El teléfono debe tener solo dígitos y hasta 12 caracteres.' + CHAR(10);

    IF @mail IS NOT NULL AND (LEN(@mail) > 40 OR @mail NOT LIKE '%_@_%._%')
        SET @err += '- El mail no tiene formato válido o supera 40 caracteres.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE sucursales.capacitador 
       SET numero_registro = @numero_registro,
           nombre          = @nombre,
           telefono        = @telefono,
           mail            = @mail
    WHERE id = @id;

    SELECT 'Capacitador actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('sucursales.sp_delete_capacitador') IS NOT NULL
    DROP PROCEDURE sucursales.sp_delete_capacitador;
GO
CREATE PROCEDURE sucursales.sp_delete_capacitador
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.capacitador WHERE id = @id)
        SET @err += '- No existe el capacitador indicado.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id_capacitador = @id)
        SET @err += '- No se puede eliminar: hay vendedores asociados a este capacitador.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM sucursales.capacitador WHERE id = @id;
    SELECT 'Capacitador eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- VENDEDOR
----------------------------------------------------------
IF OBJECT_ID('sucursales.sp_insert_vendedor') IS NOT NULL
    DROP PROCEDURE sucursales.sp_insert_vendedor;
GO
CREATE PROCEDURE sucursales.sp_insert_vendedor
    @id_capacitador     INT,
    @id_sucursal        INT,
    @nombre             VARCHAR(50),
    @fecha_capacitacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs existentes
    IF NOT EXISTS (SELECT 1 FROM sucursales.capacitador WHERE id = @id_capacitador)
        SET @err += '- El capacitador indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id_sucursal)
        SET @err += '- La sucursal indicada no existe.' + CHAR(10);
    -- Datos
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del vendedor es obligatorio.' + CHAR(10);

    IF @fecha_capacitacion > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de capacitación no puede ser futura.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO sucursales.vendedor (id_capacitador, id_sucursal, nombre, fecha_capacitacion)
    VALUES (@id_capacitador, @id_sucursal, @nombre, @fecha_capacitacion);

    SELECT 'Vendedor insertado correctamente' AS mensaje;
END
GO

IF OBJECT_ID('sucursales.sp_update_vendedor') IS NOT NULL
    DROP PROCEDURE sucursales.sp_update_vendedor;
GO
CREATE PROCEDURE sucursales.sp_update_vendedor 
    @id                  INT,
    @id_capacitador      INT,
    @nombre              VARCHAR(50),
    @fecha_capacitacion  DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id = @id)
        SET @err += '- No existe el vendedor indicado.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.capacitador WHERE id = @id_capacitador)
        SET @err += '- El capacitador indicado no existe.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del vendedor es obligatorio.' + CHAR(10);

	IF @fecha_capacitacion > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de capacitación no puede ser futura.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE sucursales.vendedor 
       SET id_capacitador     = @id_capacitador,
           nombre             = @nombre,
           fecha_capacitacion = @fecha_capacitacion
    WHERE id = @id;

    SELECT 'Vendedor actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('sucursales.sp_delete_vendedor') IS NOT NULL
    DROP PROCEDURE sucursales.sp_delete_vendedor;
GO
CREATE PROCEDURE sucursales.sp_delete_vendedor
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id = @id)
        SET @err += '- No existe el vendedor indicado.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM ventas.venta WHERE id_vendedor = @id)
        SET @err += '- No se puede eliminar: el vendedor tiene ventas asociadas.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM sucursales.vendedor WHERE id = @id;
    SELECT 'Vendedor eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- PROVEEDOR
----------------------------------------------------------
IF OBJECT_ID('proveedores.sp_insert_proveedor') IS NOT NULL
    DROP PROCEDURE proveedores.sp_insert_proveedor;
GO
CREATE PROCEDURE proveedores.sp_insert_proveedor
    @nombre VARCHAR(30),
    @pais   VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre es obligatorio.' + CHAR(10);

    -- UNIQUE nombre, pais
    IF EXISTS (SELECT 1 FROM proveedores.proveedor
        WHERE nombre = @nombre AND ISNULL(pais,'') = ISNULL(@pais,'')
    )
        SET @err += '- Ya existe un proveedor con el mismo nombre y país.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO proveedores.proveedor(nombre, pais) VALUES(@nombre, @pais);

    SELECT 'Proveedor insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_update_proveedor') IS NOT NULL
    DROP PROCEDURE proveedores.sp_update_proveedor;
GO
CREATE PROCEDURE proveedores.sp_update_proveedor
    @id     INT,
    @nombre VARCHAR(30),
    @pais   VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id)
        SET @err += '- No existe el proveedor indicado.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre es obligatorio.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM proveedores.proveedor
        WHERE nombre = @nombre AND ISNULL(pais,'') = ISNULL(@pais,'') AND id <> @id)
        SET @err += '- Existe otro proveedor con el mismo nombre y país.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE proveedores.proveedor
       SET nombre = @nombre,
           pais   = @pais
    WHERE id = @id;

    SELECT 'Proveedor actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_delete_proveedor') IS NOT NULL
    DROP PROCEDURE proveedores.sp_delete_proveedor;
GO
CREATE PROCEDURE proveedores.sp_delete_proveedor
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id)
        SET @err += '- No existe el proveedor indicado.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id_proveedor = @id)
        SET @err += '- No se puede eliminar: existen ingresos asociados al proveedor.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM proveedores.precio WHERE id_proveedor = @id)
        SET @err += '- No se puede eliminar: existen precios asociados al proveedor.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM proveedores.proveedor WHERE id = @id;
    SELECT 'Proveedor eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- INGRESO
----------------------------------------------------------
IF OBJECT_ID('proveedores.sp_insert_ingreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_insert_ingreso;
GO
CREATE PROCEDURE proveedores.sp_insert_ingreso
    @id_proveedor INT,
    @id_sucursal  INT,
    @fecha_hora   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id_proveedor)
        SET @err += '- El proveedor indicado no existe.' + CHAR(10);
    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id_sucursal)
        SET @err += '- La sucursal indicada no existe.' + CHAR(10);
    -- 
    IF @fecha_hora IS NULL
        SET @err += '- La fecha y hora del ingreso es obligatoria.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO proveedores.ingreso (id_proveedor, id_sucursal, fecha_hora)
    VALUES (@id_proveedor, @id_sucursal, @fecha_hora);

    SELECT 'Ingreso insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_update_ingreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_update_ingreso;
GO
CREATE PROCEDURE proveedores.sp_update_ingreso
    @id           INT,
    @id_proveedor INT,
    @id_sucursal  INT,
    @fecha_hora   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id = @id)
        SET @err += '- No existe el ingreso indicado.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id_proveedor)
        SET @err += '- El proveedor indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id_sucursal)
        SET @err += '- La sucursal indicada no existe.' + CHAR(10);

    IF @fecha_hora IS NULL
        SET @err += '- La fecha y hora del ingreso es obligatoria.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE proveedores.ingreso
       SET id_proveedor = @id_proveedor,
           id_sucursal  = @id_sucursal,
           fecha_hora   = @fecha_hora
    WHERE id = @id;

    SELECT 'Ingreso actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_delete_ingreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_delete_ingreso;
GO
CREATE PROCEDURE proveedores.sp_delete_ingreso
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id = @id)
        SET @err += '- No existe el ingreso indicado.' + CHAR(10);

    --lotes asociados
    IF EXISTS (SELECT 1 FROM proveedores.lote WHERE id_ingreso = @id)
        SET @err += '- No se puede eliminar: existen lotes asociados a este ingreso.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM proveedores.ingreso WHERE id = @id;
    SELECT 'Ingreso eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- LOTE
----------------------------------------------------------
IF OBJECT_ID('proveedores.sp_insert_lote') IS NOT NULL
    DROP PROCEDURE proveedores.sp_insert_lote;
GO
CREATE PROCEDURE proveedores.sp_insert_lote
    @id_producto   INT,
    @id_ingreso    INT,
    @fecha_ingreso DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);
    IF NOT EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id = @id_ingreso)
        SET @err += '- El ingreso indicado no existe.' + CHAR(10);
    -- 
    IF @fecha_ingreso IS NULL
        SET @err += '- La fecha de ingreso es obligatoria.' + CHAR(10);
    ELSE IF @fecha_ingreso > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de ingreso no puede ser futura.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO proveedores.lote (id_producto, id_ingreso, fecha_ingreso)
    VALUES (@id_producto, @id_ingreso, @fecha_ingreso);

    SELECT 'Lote insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_update_lote') IS NOT NULL
    DROP PROCEDURE proveedores.sp_update_lote;
GO
CREATE PROCEDURE proveedores.sp_update_lote
    @numero        INT,
    @id_producto   INT,
    @id_ingreso    INT,  
    @fecha_ingreso DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.lote WHERE numero = @numero)
        SET @err += '- No existe el lote indicado.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM proveedores.ingreso WHERE id = @id_ingreso)
        SET @err += '- El ingreso indicado no existe.' + CHAR(10);

    IF @fecha_ingreso IS NULL
        SET @err += '- La fecha de ingreso es obligatoria.' + CHAR(10);
    ELSE IF @fecha_ingreso > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de ingreso no puede ser futura.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE proveedores.lote
       SET id_producto   = @id_producto,
           id_ingreso = @id_ingreso,  
           fecha_ingreso = @fecha_ingreso
    WHERE numero = @numero;

    SELECT 'Lote actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_delete_lote') IS NOT NULL
    DROP PROCEDURE proveedores.sp_delete_lote;
GO
CREATE PROCEDURE proveedores.sp_delete_lote
    @numero INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.lote WHERE numero = @numero)
        SET @err += '- No existe el lote indicado.' + CHAR(10);

    --líneas de ingreso asociadas
    IF EXISTS (SELECT 1 FROM proveedores.lineaIngreso WHERE numero_lote = @numero)
        SET @err += '- No se puede eliminar: existen líneas de ingreso asociadas al lote.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM proveedores.lote WHERE numero = @numero;
    SELECT 'Lote eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- LINEA INGRESO
----------------------------------------------------------
IF OBJECT_ID('proveedores.sp_insert_lineaIngreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_insert_lineaIngreso;
GO
CREATE PROCEDURE proveedores.sp_insert_lineaIngreso
    @numero_lote INT,
    @cantidad    SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.lote WHERE numero = @numero_lote)
        SET @err += '- El lote indicado no existe.' + CHAR(10);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @err += '- La cantidad debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO proveedores.lineaIngreso (numero_lote, cantidad)
    VALUES (@numero_lote, @cantidad);

    SELECT 'Línea de ingreso insertada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_update_lineaIngreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_update_lineaIngreso;
GO
CREATE PROCEDURE proveedores.sp_update_lineaIngreso
    @numero      INT,
    @numero_lote INT,
    @cantidad    SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.lineaIngreso WHERE numero = @numero)
        SET @err += '- No existe la línea de ingreso indicada.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM proveedores.lote WHERE numero = @numero_lote)
        SET @err += '- El lote indicado no existe.' + CHAR(10);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @err += '- La cantidad debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE proveedores.lineaIngreso
       SET numero_lote = @numero_lote,
           cantidad    = @cantidad
    WHERE numero = @numero;

    SELECT 'Línea de ingreso actualizada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_delete_lineaIngreso') IS NOT NULL
    DROP PROCEDURE proveedores.sp_delete_lineaIngreso;
GO
CREATE PROCEDURE proveedores.sp_delete_lineaIngreso
    @numero INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.lineaIngreso WHERE numero = @numero)
        SET @err += '- No existe la línea de ingreso indicada.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM proveedores.lineaIngreso WHERE numero = @numero;
    SELECT 'Línea de ingreso eliminada correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- PRECIO
----------------------------------------------------------
IF OBJECT_ID('proveedores.sp_insert_precio') IS NOT NULL
    DROP PROCEDURE proveedores.sp_insert_precio;
GO
CREATE PROCEDURE proveedores.sp_insert_precio
    @id_producto  INT,
    @id_proveedor INT,
    @monto        INT,
    @mpk          DECIMAL(7,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);
    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id_proveedor)
        SET @err += '- El proveedor indicado no existe.' + CHAR(10);
    --
    IF @monto IS NULL OR @monto <= 0
        SET @err += '- El monto debe ser mayor a 0.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM proveedores.precio
        WHERE id_producto = @id_producto AND id_proveedor = @id_proveedor)
        SET @err += '- Ya existe un precio para el producto con ese proveedor.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO proveedores.precio (id_producto, id_proveedor, monto, mpk)
    VALUES (@id_producto, @id_proveedor, @monto, @mpk);

    SELECT 'Precio insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_update_precio') IS NOT NULL
    DROP PROCEDURE proveedores.sp_update_precio;
GO
CREATE PROCEDURE proveedores.sp_update_precio
    @id           INT,
    @id_producto  INT,
    @id_proveedor INT,
    @monto        INT,
    @mpk          DECIMAL(7,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.precio WHERE id = @id)
        SET @err += '- No existe el precio indicado.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM proveedores.proveedor WHERE id = @id_proveedor)
        SET @err += '- El proveedor indicado no existe.' + CHAR(10);

    IF @monto IS NULL OR @monto <= 0
        SET @err += '- El monto debe ser mayor a 0.' + CHAR(10);
 
    IF EXISTS (SELECT 1 FROM proveedores.precio
        WHERE id_producto = @id_producto AND id_proveedor = @id_proveedor
			AND id <> @id)
        SET @err += '- Ya existe otro precio para ese producto/proveedor.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE proveedores.precio
       SET id_producto  = @id_producto,
           id_proveedor = @id_proveedor,
           monto        = @monto,
           mpk          = @mpk
    WHERE id = @id;

    SELECT 'Precio actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('proveedores.sp_delete_precio') IS NOT NULL
    DROP PROCEDURE proveedores.sp_delete_precio;
GO
CREATE PROCEDURE proveedores.sp_delete_precio
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM proveedores.precio WHERE id = @id)
        SET @err += '- No existe el precio indicado.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM proveedores.precio WHERE id = @id;
    SELECT 'Precio eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- TEMPORADA
----------------------------------------------------------
IF OBJECT_ID('productos.sp_insert_temporada') IS NOT NULL
    DROP PROCEDURE productos.sp_insert_temporada;
GO
CREATE PROCEDURE productos.sp_insert_temporada
    @descripcion VARCHAR(50),
    @mes_desde   TINYINT = NULL,
    @dia_desde   TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- Reglas
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @err += '- La descripción de la temporada es obligatoria.' + CHAR(10);

    IF @mes_desde IS NOT NULL AND (@mes_desde < 1 OR @mes_desde > 12)
        SET @err += '- El mes debe estar entre 1 y 12.' + CHAR(10);

    IF @dia_desde IS NOT NULL AND (@dia_desde < 1 OR @dia_desde > 31)
        SET @err += '- El dia debe estar entre 1 y 31.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO productos.temporada (descripcion, mes_desde, dia_desde)
    VALUES (@descripcion, @mes_desde, @dia_desde);

    SELECT 'Temporada insertada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_update_temporada') IS NOT NULL
    DROP PROCEDURE productos.sp_update_temporada;
GO
CREATE PROCEDURE productos.sp_update_temporada
    @id          INT,
    @descripcion VARCHAR(50),
    @mes_desde   TINYINT = NULL,
    @dia_desde   TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.temporada WHERE id = @id)
        SET @err += '- No existe la temporada indicada.' + CHAR(10);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @err += '- La descripción de la temporada es obligatoria.' + CHAR(10);

    IF @mes_desde IS NOT NULL AND (@mes_desde < 1 OR @mes_desde > 12)
        SET @err += '- El mes_desde debe estar entre 1 y 12.' + CHAR(10);

    IF @dia_desde IS NOT NULL AND (@dia_desde < 1 OR @dia_desde > 31)
        SET @err += '- El dia_desde debe estar entre 1 y 31.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE productos.temporada
       SET descripcion = @descripcion,
           mes_desde   = @mes_desde,
           dia_desde   = @dia_desde
    WHERE id = @id;

    SELECT 'Temporada actualizada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_delete_temporada') IS NOT NULL
    DROP PROCEDURE productos.sp_delete_temporada;
GO
CREATE PROCEDURE productos.sp_delete_temporada
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.temporada WHERE id = @id)
        SET @err += '- No existe la temporada indicada.' + CHAR(10);
	--categorias que referencian esta temporada
    IF EXISTS (SELECT 1 FROM productos.categoria WHERE id_temporada = @id)
        SET @err += '- No se puede eliminar: existen categorías asociadas a la temporada.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM productos.temporada WHERE id = @id;
    SELECT 'Temporada eliminada correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- CATEGORIA
----------------------------------------------------------
IF OBJECT_ID('productos.sp_insert_categoria') IS NOT NULL
    DROP PROCEDURE productos.sp_insert_categoria;
GO
CREATE PROCEDURE productos.sp_insert_categoria
    @id_temporada   INT,
    @descripcion    VARCHAR(50),
    @dias_caducidad TINYINT = NULL,
    @margen         TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM productos.temporada WHERE id = @id_temporada)
        SET @err += '- La temporada indicada no existe.' + CHAR(10);
    -- 
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @err += '- La descripción de la categoría es obligatoria.' + CHAR(10);

    IF @dias_caducidad IS NOT NULL AND @dias_caducidad <= 0
        SET @err += '- Los días de caducidad deben ser mayor a 0.' + CHAR(10);

    IF @margen IS NOT NULL AND @margen <= 0
        SET @err += '- El margen debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO productos.categoria (id_temporada, descripcion, dias_caducidad, margen)
    VALUES (@id_temporada, @descripcion, @dias_caducidad, @margen);

    SELECT 'Categoria insertada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_update_categoria') IS NOT NULL
    DROP PROCEDURE productos.sp_update_categoria;
GO
CREATE PROCEDURE productos.sp_update_categoria
    @id             INT,
    @id_temporada   INT,
    @descripcion    VARCHAR(50),
    @dias_caducidad TINYINT = NULL,
    @margen         TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.categoria WHERE id = @id)
        SET @err += '- No existe la categoría indicada.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM productos.temporada WHERE id = @id_temporada)
        SET @err += '- La temporada indicada no existe.' + CHAR(10);

    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @err += '- La descripción de la categoría es obligatoria.' + CHAR(10);

    IF @dias_caducidad IS NOT NULL AND @dias_caducidad <= 0
        SET @err += '- Los días de caducidad deben ser mayor a 0.' + CHAR(10);

    IF @margen IS NOT NULL AND @margen <= 0
        SET @err += '- El margen debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE productos.categoria 
       SET id_temporada   = @id_temporada,
           descripcion    = @descripcion,
           dias_caducidad = @dias_caducidad,
           margen         = @margen
    WHERE id = @id;

    SELECT 'Categoría actualizada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_delete_categoria') IS NOT NULL
    DROP PROCEDURE productos.sp_delete_categoria;
GO
CREATE PROCEDURE productos.sp_delete_categoria
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.categoria WHERE id = @id)
        SET @err += '- No existe la categoría indicada.' + CHAR(10);

    -- productos asociados a la categoría
    IF EXISTS (SELECT 1 FROM productos.producto WHERE id_categoria = @id)
        SET @err += '- No se puede eliminar: existen productos asociados a la categoría.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM productos.categoria WHERE id = @id;
    SELECT 'Categoría eliminada correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- PRODUCTO
----------------------------------------------------------
IF OBJECT_ID('productos.sp_insert_producto') IS NOT NULL
    DROP PROCEDURE productos.sp_insert_producto;
GO
CREATE PROCEDURE productos.sp_insert_producto
    @id_categoria INT,
    @especie      VARCHAR(50),
    @variedad     VARCHAR(50) = NULL,
    @procedencia  VARCHAR(50) = NULL,
    @envase       CHAR(2)     = NULL,
    @calidad      CHAR(2)     = NULL,
    @grado        CHAR(3)     = NULL,
    @tamaño       VARCHAR(12) = NULL,   
    @peso         SMALLINT    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FK existente
    IF NOT EXISTS (SELECT 1 FROM productos.categoria WHERE id = @id_categoria)
        SET @err += '- La categoría indicada no existe.' + CHAR(10);
    -- 
    IF @especie IS NULL OR LTRIM(RTRIM(@especie)) = ''
        SET @err += '- La especie es obligatoria.' + CHAR(10);

    -- UQ 
    IF EXISTS (
        SELECT 1 FROM productos.producto
        WHERE especie = @especie
          AND ISNULL(variedad,'')   = ISNULL(@variedad,'')
          AND ISNULL(procedencia,'')= ISNULL(@procedencia,'')
          AND ISNULL(envase,'')     = ISNULL(@envase,'')
          AND ISNULL(peso,-1)       = ISNULL(@peso,-1)
          AND ISNULL(calidad,'')    = ISNULL(@calidad,'')
          AND ISNULL(tamaño,'')     = ISNULL(@tamaño,'')
          AND ISNULL(grado,'')      = ISNULL(@grado,'')
    )
        SET @err += '- Ya existe un producto con los mismos atributos.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO productos.producto (
        id_categoria, especie, variedad, procedencia, envase, calidad, grado, tamaño, peso
    ) VALUES (
        @id_categoria, @especie, @variedad, @procedencia, @envase, @calidad, @grado, @tamaño, @peso
    );

    SELECT 'Producto insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_update_producto') IS NOT NULL
    DROP PROCEDURE productos.sp_update_producto;
GO
CREATE PROCEDURE productos.sp_update_producto
    @id           INT,
    @id_categoria INT,
    @especie      VARCHAR(50),
    @variedad     VARCHAR(50) = NULL,
    @procedencia  VARCHAR(50) = NULL,
    @envase       CHAR(2)     = NULL,
    @calidad      CHAR(2)     = NULL,
    @grado        CHAR(3)     = NULL,
    @tamaño       VARCHAR(12) = NULL,
    @peso         SMALLINT    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id)
        SET @err += '- No existe el producto indicado.' + CHAR(10);
    -- FK
    IF NOT EXISTS (SELECT 1 FROM productos.categoria WHERE id = @id_categoria)
        SET @err += '- La categoría indicada no existe.' + CHAR(10);
    -- 
    IF @especie IS NULL OR LTRIM(RTRIM(@especie)) = ''
        SET @err += '- La especie es obligatoria.' + CHAR(10);

    -- UQ
    IF EXISTS (
        SELECT 1 FROM productos.producto
        WHERE especie               = @especie
          AND ISNULL(variedad,'')   = ISNULL(@variedad,'')
          AND ISNULL(procedencia,'')= ISNULL(@procedencia,'')
          AND ISNULL(envase,'')     = ISNULL(@envase,'')
          AND ISNULL(peso,-1)       = ISNULL(@peso,-1)
          AND ISNULL(calidad,'')    = ISNULL(@calidad,'')
          AND ISNULL(tamaño,'')     = ISNULL(@tamaño,'')
          AND ISNULL(grado,'')      = ISNULL(@grado,'')
          AND id <> @id
    )
        SET @err += '- Ya existe otro producto con los mismos atributos.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE productos.producto
       SET id_categoria = @id_categoria,
           especie      = @especie,
           variedad     = @variedad,
           procedencia  = @procedencia,
           envase       = @envase,
           calidad      = @calidad,
           grado        = @grado,
           tamaño       = @tamaño,
           peso         = @peso
    WHERE id = @id;

    SELECT 'Producto actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('productos.sp_delete_producto') IS NOT NULL
    DROP PROCEDURE productos.sp_delete_producto;
GO
CREATE PROCEDURE productos.sp_delete_producto
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id)
        SET @err += '- No existe el producto indicado.' + CHAR(10);

    --lotes, líneas de venta, precios
    IF EXISTS (SELECT 1 FROM proveedores.lote WHERE id_producto = @id)
        SET @err += '- No se puede eliminar: existen lotes asociados al producto.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM ventas.lineaVenta WHERE id_producto = @id)
        SET @err += '- No se puede eliminar: existen líneas de venta asociadas al producto.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM proveedores.precio WHERE id_producto = @id)
        SET @err += '- No se puede eliminar: existen precios asociados al producto.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM productos.producto WHERE id = @id;
    SELECT 'Producto eliminado correctamente' AS mensaje;
END
GO


----------------------------------------------------------
-- CLIENTE
----------------------------------------------------------
IF OBJECT_ID('ventas.sp_insert_cliente') IS NOT NULL
    DROP PROCEDURE ventas.sp_insert_cliente;
GO
CREATE PROCEDURE ventas.sp_insert_cliente
    @nombre    VARCHAR(50),
    @direccion VARCHAR(100),
    @cuit_cuil CHAR(11) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del cliente es obligatorio.' + CHAR(10);

    IF @direccion IS NULL OR LTRIM(RTRIM(@direccion)) = ''
        SET @err += '- La dirección del cliente es obligatoria.' + CHAR(10);

    IF @cuit_cuil IS NOT NULL AND (LEN(@cuit_cuil) <> 11 OR @cuit_cuil LIKE '%[^0-9]%')
		SET @err += '- El CUIT/CUIL debe tener exactamente 11 dígitos (o ser NULL).' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO ventas.cliente (nombre, direccion, cuit_cuil)
    VALUES (@nombre, @direccion, @cuit_cuil);

    SELECT 'Cliente insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_update_cliente') IS NOT NULL
    DROP PROCEDURE ventas.sp_update_cliente;
GO
CREATE PROCEDURE ventas.sp_update_cliente
    @id        INT,
    @nombre    VARCHAR(50),
    @direccion VARCHAR(100),
    @cuit_cuil CHAR(11) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id)
        SET @err += '- No existe el cliente indicado.' + CHAR(10);

    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del cliente es obligatorio.' + CHAR(10);

    IF @direccion IS NULL OR LTRIM(RTRIM(@direccion)) = ''
        SET @err += '- La dirección del cliente es obligatoria.' + CHAR(10);
	
	IF @cuit_cuil IS NOT NULL AND (LEN(@cuit_cuil) <> 11 OR @cuit_cuil LIKE '%[^0-9]%')
		SET @err += '- El CUIT/CUIL debe tener exactamente 11 dígitos (o ser NULL).' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE ventas.cliente
       SET nombre    = @nombre,
           direccion = @direccion,
           cuit_cuil = @cuit_cuil
    WHERE id = @id;

    SELECT 'Cliente actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_delete_cliente') IS NOT NULL
    DROP PROCEDURE ventas.sp_delete_cliente;
GO
CREATE PROCEDURE ventas.sp_delete_cliente
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id)
        SET @err += '- No existe el cliente indicado.' + CHAR(10);

    -- pedidos y ventas
    IF EXISTS (SELECT 1 FROM ventas.pedido WHERE id_cliente = @id)
        SET @err += '- No se puede eliminar: existen pedidos asociados al cliente.' + CHAR(10);

    IF EXISTS (SELECT 1 FROM ventas.venta WHERE id_cliente = @id)
        SET @err += '- No se puede eliminar: existen ventas asociadas al cliente.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM ventas.cliente WHERE id = @id;
    SELECT 'Cliente eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- PEDIDO
----------------------------------------------------------
IF OBJECT_ID('ventas.sp_insert_pedido') IS NOT NULL
    DROP PROCEDURE ventas.sp_insert_pedido;
GO
CREATE PROCEDURE ventas.sp_insert_pedido
    @id_cliente INT,
    @fecha      DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id_cliente)
        SET @err += '- El cliente indicado no existe.' + CHAR(10);

    IF @fecha IS NULL
        SET @err += '- La fecha del pedido es obligatoria.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO ventas.pedido (id_cliente, fecha) VALUES (@id_cliente, @fecha);

    SELECT 'Pedido insertado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_update_pedido') IS NOT NULL
    DROP PROCEDURE ventas.sp_update_pedido;
GO
CREATE PROCEDURE ventas.sp_update_pedido
    @id         INT,
    @id_cliente INT,
    @fecha      DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pedido WHERE id = @id)
        SET @err += '- No existe el pedido indicado.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id_cliente)
        SET @err += '- El cliente indicado no existe.' + CHAR(10);

    IF @fecha IS NULL
        SET @err += '- La fecha del pedido es obligatoria.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE ventas.pedido
       SET id_cliente = @id_cliente,
           fecha      = @fecha
    WHERE id = @id;

    SELECT 'Pedido actualizado correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_delete_pedido') IS NOT NULL
    DROP PROCEDURE ventas.sp_delete_pedido;
GO
CREATE PROCEDURE ventas.sp_delete_pedido
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pedido WHERE id = @id)
        SET @err += '- No existe el pedido indicado.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM ventas.pedido WHERE id = @id;
    SELECT 'Pedido eliminado correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- VENTA
----------------------------------------------------------
IF OBJECT_ID('ventas.sp_insert_venta') IS NOT NULL
    DROP PROCEDURE ventas.sp_insert_venta;
GO
CREATE PROCEDURE ventas.sp_insert_venta
    @id_cliente  INT,
    @id_vendedor INT,
    @fecha_hora  DATETIME,
    @total       DECIMAL(9,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id_cliente)
        SET @err += '- El cliente indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id = @id_vendedor)
        SET @err += '- El vendedor indicado no existe.' + CHAR(10);
    -- 
    IF @fecha_hora IS NULL
        SET @err += '- La fecha y hora de la venta es obligatoria.' + CHAR(10);
    ELSE IF @fecha_hora > GETDATE()
        SET @err += '- La fecha y hora de la venta no puede ser futura.' + CHAR(10);

    IF @total IS NULL OR @total <= 0
        SET @err += '- El total de la venta debe ser mayor a 0.' + CHAR(10); 

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO ventas.venta (id_cliente, id_vendedor, fecha_hora, total)
    VALUES (@id_cliente, @id_vendedor, @fecha_hora, @total);

    SELECT 'Venta insertada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_update_venta') IS NOT NULL
    DROP PROCEDURE ventas.sp_update_venta;
GO
CREATE PROCEDURE ventas.sp_update_venta
    @id          INT,
    @id_cliente  INT,
    @id_vendedor INT,
    @fecha_hora  DATETIME,
    @total       DECIMAL(9,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id = @id)
        SET @err += '- No existe la venta indicada.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM ventas.cliente WHERE id = @id_cliente)
        SET @err += '- El cliente indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id = @id_vendedor)
        SET @err += '- El vendedor indicado no existe.' + CHAR(10);

    IF @fecha_hora IS NULL
        SET @err += '- La fecha y hora de la venta es obligatoria.' + CHAR(10);
    ELSE IF @fecha_hora > GETDATE()
        SET @err += '- La fecha y hora de la venta no puede ser futura.' + CHAR(10);

    IF @total IS NULL OR @total <= 0
        SET @err += '- El total de la venta debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE ventas.venta
       SET id_cliente  = @id_cliente,
           id_vendedor = @id_vendedor,
           fecha_hora  = @fecha_hora,
           total       = @total
    WHERE id = @id;

    SELECT 'Venta actualizada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_delete_venta') IS NOT NULL
    DROP PROCEDURE ventas.sp_delete_venta;
GO
CREATE PROCEDURE ventas.sp_delete_venta
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id = @id)
        SET @err += '- No existe la venta indicada.' + CHAR(10);

    --líneas de venta asociadas
    IF EXISTS (SELECT 1 FROM ventas.lineaVenta WHERE id_venta = @id)
        SET @err += '- No se puede eliminar: existen líneas de venta asociadas a la venta.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM ventas.venta WHERE id = @id;
    SELECT 'Venta eliminada correctamente' AS mensaje;
END
GO

----------------------------------------------------------
-- LINEA VENTA
----------------------------------------------------------
IF OBJECT_ID('ventas.sp_insert_lineaVenta') IS NOT NULL
    DROP PROCEDURE ventas.sp_insert_lineaVenta;
GO
CREATE PROCEDURE ventas.sp_insert_lineaVenta
    @id_venta   INT,
    @id_producto INT,
    @cantidad   SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id = @id_venta)
        SET @err += '- La venta indicada no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);
    --
    IF @cantidad IS NULL OR @cantidad <= 0
        SET @err += '- La cantidad debe ser mayor a 0.' + CHAR(10); 

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO ventas.lineaVenta (id_venta, id_producto, cantidad)
    VALUES (@id_venta, @id_producto, @cantidad);

    SELECT 'Línea de venta insertada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_update_lineaVenta') IS NOT NULL
    DROP PROCEDURE ventas.sp_update_lineaVenta;
GO
CREATE PROCEDURE ventas.sp_update_lineaVenta
    @id          INT,
    @id_venta    INT,
    @id_producto INT,
    @cantidad    SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.lineaVenta WHERE id = @id)
        SET @err += '- No existe la línea de venta indicada.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id = @id_venta)
        SET @err += '- La venta indicada no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM productos.producto WHERE id = @id_producto)
        SET @err += '- El producto indicado no existe.' + CHAR(10);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @err += '- La cantidad debe ser mayor a 0.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE ventas.lineaVenta
       SET id_venta    = @id_venta,
           id_producto = @id_producto,
           cantidad    = @cantidad
    WHERE id = @id;

    SELECT 'Línea de venta actualizada correctamente' AS mensaje;
END
GO


IF OBJECT_ID('ventas.sp_delete_lineaVenta') IS NOT NULL
    DROP PROCEDURE ventas.sp_delete_lineaVenta;
GO
CREATE PROCEDURE ventas.sp_delete_lineaVenta
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.lineaVenta WHERE id = @id)
        SET @err += '- No existe la línea de venta indicada.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    DELETE FROM ventas.lineaVenta WHERE id = @id;
    SELECT 'Línea de venta eliminada correctamente' AS mensaje;
END
GO