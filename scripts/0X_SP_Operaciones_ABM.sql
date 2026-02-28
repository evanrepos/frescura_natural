/*
------------------------------------------------------------
Universidad Nacional de La Matanza
Trabajo Práctico Integrador - Bases de Datos Aplicadas
Fecha de entrega: 04/03/2026
Integrantes: 
Apellido y Nombre						
Gonzáles Fernándes Iván Alejandro		
Mamani Estrada Lucas Gabriel			
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
    @numero_registro VARCHAR(31) = NULL,
    @nombre          VARCHAR(50),
    @telefono        VARCHAR(12) = NULL,
    @mail            VARCHAR(40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- Validaciones de entrada
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del capacitador es obligatorio.' + CHAR(10);

    IF @numero_registro IS NOT NULL AND LEN(@numero_registro) > 31
        SET @err += '- El número de registro supera 31 caracteres.' + CHAR(10);

    IF @telefono IS NOT NULL AND (@telefono LIKE '%[^0-9]%' OR LEN(@telefono) > 12)
        SET @err += '- El teléfono debe tener solo dígitos y hasta 12 caracteres.' + CHAR(10);

    IF @mail IS NOT NULL AND (LEN(@mail) > 40 OR @mail NOT LIKE '%_@_%._%')
        SET @err += '- El mail no tiene formato válido o supera 40 caracteres.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO sucursales.capacitador (numero_registro, nombre, telefono, mail)
    VALUES (@numero_registro, @nombre, @telefono, @mail);

    SELECT SCOPE_IDENTITY() AS id_nuevo;
END
GO


IF OBJECT_ID('sucursales.sp_update_capacitador') IS NOT NULL
    DROP PROCEDURE sucursales.sp_update_capacitador;
GO
CREATE PROCEDURE sucursales.sp_update_capacitador
    @id              INT,
    @numero_registro VARCHAR(31) = NULL,
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

    IF @numero_registro IS NOT NULL AND LEN(@numero_registro) > 31
        SET @err += '- El número de registro supera 31 caracteres.' + CHAR(10);

    IF @telefono IS NOT NULL AND (@telefono LIKE '%[^0-9]%' OR LEN(@telefono) > 12)
        SET @err += '- El teléfono debe tener solo dígitos y hasta 12 caracteres.' + CHAR(10);

    IF @mail IS NOT NULL AND (LEN(@mail) > 40 OR @mail NOT LIKE '%_@_%._%')
        SET @err += '- El mail no tiene formato válido o supera 40 caracteres.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE c
       SET numero_registro = @numero_registro,
           nombre          = @nombre,
           telefono        = @telefono,
           mail            = @mail
    FROM sucursales.capacitador c
    WHERE c.id = @id;

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

    -- Bloqueo por referencias: vendedor ? capacitador
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

    -- Reglas de datos
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del vendedor es obligatorio.' + CHAR(10);

    IF @fecha_capacitacion IS NULL
        SET @err += '- La fecha de capacitación es obligatoria.' + CHAR(10);
    ELSE IF @fecha_capacitacion > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de capacitación no puede ser futura.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    INSERT INTO sucursales.vendedor (id_capacitador, id_sucursal, nombre, fecha_capacitacion)
    VALUES (@id_capacitador, @id_sucursal, @nombre, @fecha_capacitacion);

    SELECT SCOPE_IDENTITY() AS id_nuevo;
END
GO


IF OBJECT_ID('sucursales.sp_update_vendedor') IS NOT NULL
    DROP PROCEDURE sucursales.sp_update_vendedor;
GO
CREATE PROCEDURE sucursales.sp_update_vendedor
    @id                  INT,
    @id_capacitador      INT,
    @id_sucursal         INT,   -- No se permite cambiar (validación abajo)
    @nombre              VARCHAR(50),
    @fecha_capacitacion  DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err VARCHAR(MAX) = '';

    -- Existencia del registro
    IF NOT EXISTS (SELECT 1 FROM sucursales.vendedor WHERE id = @id)
        SET @err += '- No existe el vendedor indicado.' + CHAR(10);

    -- FKs
    IF NOT EXISTS (SELECT 1 FROM sucursales.capacitador WHERE id = @id_capacitador)
        SET @err += '- El capacitador indicado no existe.' + CHAR(10);

    IF NOT EXISTS (SELECT 1 FROM sucursales.sucursal WHERE id = @id_sucursal)
        SET @err += '- La sucursal indicada no existe.' + CHAR(10);

    -- Reglas de datos
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @err += '- El nombre del vendedor es obligatorio.' + CHAR(10);

    IF @fecha_capacitacion IS NULL
        SET @err += '- La fecha de capacitación es obligatoria.' + CHAR(10);
    ELSE IF @fecha_capacitacion > CAST(GETDATE() AS DATE)
        SET @err += '- La fecha de capacitación no puede ser futura.' + CHAR(10);

    -- Regla de negocio: NO permitir cambiar sucursal
    IF EXISTS (
        SELECT 1
        FROM sucursales.vendedor v
        WHERE v.id = @id AND v.id_sucursal <> @id_sucursal
    )
        SET @err += '- No se permite cambiar la sucursal del vendedor.' + CHAR(10);

    IF LEN(@err) > 0
    BEGIN
        RAISERROR(@err, 16, 1);
        RETURN;
    END

    UPDATE v
       SET id_capacitador     = @id_capacitador,
           -- id_sucursal     = @id_sucursal, -- Intencionalmente NO se actualiza
           nombre             = @nombre,
           fecha_capacitacion = @fecha_capacitacion
    FROM sucursales.vendedor v
    WHERE v.id = @id;

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

    -- Bloqueo por referencias: venta ? vendedor
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
