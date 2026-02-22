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
CREATE SCHEMA esquema_1;
GO
CREATE SCHEMA esquema_2;
GO
CREATE SCHEMA esquema_4;
GO
CREATE SCHEMA esquema_5;
GO

PRINT 'Esquemas creados correctamente';
GO

----------------------------------------------------------------
-- TABLAS DE ESQUEMA_1
----------------------------------------------------------------

----------------------------------------------------------------
-- TABLAS DE ESQUEMA_2
----------------------------------------------------------------

----------------------------------------------------------------
-- TABLAS DE ESQUEMA_3
----------------------------------------------------------------

----------------------------------------------------------------
-- TABLAS DE ESQUEMA_4
----------------------------------------------------------------

----------------------------------------------------------------
-- TABLAS DE ESQUEMA_5
----------------------------------------------------------------