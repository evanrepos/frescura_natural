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

---------------------------------------------------------
-- SP para agregar columnas para cifrado
---------------------------------------------------------

CREATE OR ALTER PROCEDURE seguridad.agregar_columna_para_cifrado
AS
BEGIN
	SET NOCOUNT ON;

    IF COL_LENGTH('ventas.cliente', 'nombre_Cif') IS NULL
		ALTER TABLE ventas.cliente ADD nombre_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('ventas.cliente', 'direccion_Cif') IS NULL
		ALTER TABLE ventas.cliente ADD direccion_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('ventas.cliente', 'cuit_cuil_Cif') IS NULL
		ALTER TABLE ventas.cliente ADD cuit_cuil_Cif VARBINARY(256) NULL;

	IF COL_LENGTH('sucursales.capacitador', 'numero_registro_Cif') IS NULL
		ALTER TABLE sucursales.capacitador ADD numero_registro_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('sucursales.capacitador', 'telefono_Cif') IS NULL
		ALTER TABLE sucursales.capacitador ADD telefono_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('sucursales.capacitador', 'mail_Cif') IS NULL
		ALTER TABLE sucursales.capacitador ADD mail_Cif VARBINARY(256) NULL;
	
	PRINT 'Campos para cifrado agregados correctamente.';
END;
GO

EXEC seguridad.agregar_columna_para_cifrado;
GO


---------------------------------------------------------
-- SP para cifrar datos sensibles
---------------------------------------------------------

CREATE OR ALTER PROCEDURE seguridad.cifrar_datos_sensibles
    @FraseClave NVARCHAR(128)
AS

BEGIN
    SET NOCOUNT ON;
    -- Cifrado de clientes
	UPDATE ventas.cliente
	SET nombre_Cif =
			EncryptByPassPhrase(@FraseClave, nombre, 1, CONVERT(VARBINARY, id)),
		direccion_Cif =
			EncryptByPassPhrase(@FraseClave, direccion, 1, CONVERT(VARBINARY, id)),
		cuit_cuil_Cif =
			EncryptByPassPhrase(@FraseClave, cuit_cuil, 1, CONVERT(VARBINARY, id))
	WHERE nombre_Cif IS NULL
		OR direccion_Cif IS NULL
		OR cuit_cuil_Cif IS NULL;

	-- Cifrado de capacitadores
	UPDATE sucursales.capacitador
	SET numero_registro_Cif =
			EncryptByPassPhrase(@FraseClave, numero_registro, 1, CONVERT(VARBINARY, id)),
		telefono_Cif =
			EncryptByPassPhrase(@FraseClave, telefono, 1, CONVERT(VARBINARY, id)),
		mail_Cif =
			EncryptByPassPhrase(@FraseClave, mail, 1, CONVERT(VARBINARY, id))
		WHERE telefono_Cif IS NULL
			OR mail_Cif IS NULL;

		PRINT 'Cifrado aplicado correctamente.';
END;
GO

EXEC seguridad.cifrar_datos_sensibles N'ClaveSecreta2026$';
GO


---------------------------------------------------------
-- SP para eliminar columnas
---------------------------------------------------------

CREATE OR ALTER PROCEDURE seguridad.eliminar_columnas_en_claro
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @err VARCHAR(MAX) = '';

	-- Validar que todos los registros tengan su cifrado
	-- cliente
	IF EXISTS (SELECT 1 FROM ventas.cliente 
		WHERE (nombre IS NOT NULL AND nombre_Cif IS NULL))
			SET @err += '- Hay nombres de clientes sin cifrar.' + CHAR(10);

	IF EXISTS (SELECT 1 FROM ventas.cliente 
		WHERE (direccion IS NOT NULL AND direccion_Cif IS NULL))
			SET @err += '- Hay direcciones de clientes sin cifrar.' + CHAR(10);

	IF EXISTS (SELECT 1 FROM ventas.cliente 
		WHERE (cuit_cuil IS NOT NULL AND cuit_cuil_Cif IS NULL))
			SET @err += '- Hay cuit_cuil de clientes sin cifrar.' + CHAR(10);

    -- capacitador
	IF EXISTS (SELECT 1 FROM sucursales.capacitador 
		WHERE (numero_registro IS NOT NULL AND numero_registro_Cif IS NULL))
			SET @err += '- Hay numeros de registros de capacitadores sin cifrar.' + CHAR(10);

	IF EXISTS (SELECT 1 FROM sucursales.capacitador 
		WHERE (telefono IS NOT NULL AND telefono_Cif IS NULL))
			SET @err += '- Hay telefonos de capacitadores sin cifrar.' + CHAR(10);

	IF EXISTS (SELECT 1 FROM sucursales.capacitador 
		WHERE (mail IS NOT NULL AND mail_Cif IS NULL))
			SET @err += '- Hay mails de capacitadores sin cifrar.' + CHAR(10);
	
	IF LEN(@err) > 0
	BEGIN 
        RAISERROR(@err, 16, 1);
		RETURN;
	END
	-- Quitar constraints 
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_cliente_cUIT_Formato'
		AND parent_object_id = OBJECT_ID('ventas.cliente'))
            ALTER TABLE ventas.cliente DROP CONSTRAINT CK_cliente_cUIT_Formato;

	-- Drop columnas en claro 
	IF COL_LENGTH('ventas.cliente', 'nombre') IS NOT NULL
		ALTER TABLE ventas.cliente DROP COLUMN nombre;

	IF COL_LENGTH('ventas.cliente', 'direccion') IS NOT NULL
		ALTER TABLE ventas.cliente DROP COLUMN direccion;

	IF COL_LENGTH('ventas.cliente', 'cuit_cuil') IS NOT NULL
		ALTER TABLE ventas.cliente DROP COLUMN cuit_cuil;

	IF COL_LENGTH('sucursales.capacitador', 'numero_registro') IS NOT NULL
		ALTER TABLE sucursales.capacitador DROP COLUMN numero_registro;

	IF COL_LENGTH('sucursales.capacitador', 'telefono') IS NOT NULL
		ALTER TABLE sucursales.capacitador DROP COLUMN telefono;

	IF COL_LENGTH('sucursales.capacitador', 'mail') IS NOT NULL
		ALTER TABLE sucursales.capacitador DROP COLUMN mail;

	PRINT 'Columnas en claro eliminadas correctamente.';
END;
GO

EXEC seguridad.eliminar_columnas_en_claro;
GO

---------------------------------------------------------
-- SPs para descifrar
---------------------------------------------------------

CREATE OR ALTER PROCEDURE seguridad.descifrar_clientes
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SELECT 
        id,
        CONVERT(VARCHAR(200),
            DecryptByPassPhrase(@FraseClave, nombre_Cif, 1, CONVERT(VARBINARY,id))
        ) AS nombre,
        CONVERT(VARCHAR(200),
            DecryptByPassPhrase(@FraseClave, direccion_Cif, 1, CONVERT(VARBINARY,id))
        ) AS direccion,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave, cuit_cuil_Cif, 1, CONVERT(VARBINARY,id))
        ) AS cuit_cuil
    FROM ventas.cliente;
END;
GO

CREATE OR ALTER PROCEDURE seguridad.descifrar_capacitadores
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SELECT 
        id,
        nombre,
		CONVERT(VARCHAR(31),  
			DecryptByPassPhrase(@FraseClave, numero_registro_Cif, 1, CONVERT(VARBINARY,id))
		) AS numero_registro,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave, telefono_Cif, 1, CONVERT(VARBINARY,id))
        ) AS telefono,
        CONVERT(VARCHAR(100),
            DecryptByPassPhrase(@FraseClave, mail_Cif, 1, CONVERT(VARBINARY,id))
        ) AS mail
    FROM sucursales.capacitador;
END;
GO