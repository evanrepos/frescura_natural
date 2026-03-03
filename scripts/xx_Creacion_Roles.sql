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
---- Creacion de Roles
USE FrescuraNatural;
GO

-- Sin los roles creados
SELECT name AS rol FROM sys.database_principals
WHERE type = 'R';

---------------------------------------------------------
-- Roles
---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_admin')
    CREATE ROLE rol_admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_importador')
    CREATE ROLE rol_importador;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_consultas')
    CREATE ROLE rol_consultas;
GO

-- rol_admin
ALTER ROLE db_owner ADD MEMBER rol_admin;
GO

-- rol_importador
GRANT EXECUTE ON SCHEMA::datos       TO rol_importador;
GRANT EXECUTE ON SCHEMA::sucursales  TO rol_importador;
GRANT EXECUTE ON SCHEMA::proveedores TO rol_importador;
GRANT EXECUTE ON SCHEMA::productos   TO rol_importador;

-- rol_consultas
GRANT SELECT ON SCHEMA::datos       TO rol_consultas;
GRANT SELECT ON SCHEMA::productos   TO rol_consultas;
GRANT SELECT ON SCHEMA::proveedores TO rol_consultas;
GRANT SELECT ON SCHEMA::sucursales  TO rol_consultas;
GRANT SELECT ON SCHEMA::ventas      TO rol_consultas;
--agregar permisos para los reportes

--Con los roles creados
SELECT name AS rol FROM sys.database_principals
WHERE type = 'R';

SELECT pr.name            AS rol,
       dp.state_desc      AS estado,       -- GRANT / DENY
       dp.permission_name AS permiso,
       dp.class_desc      AS clase,
       SCHEMA_NAME(dp.major_id) AS esquema
FROM sys.database_permissions dp
JOIN sys.database_principals pr
  ON pr.principal_id = dp.grantee_principal_id
WHERE pr.name = 'rol_importador'
  AND dp.class_desc = 'SCHEMA'
ORDER BY estado, permiso, esquema;

SELECT pr.name            AS rol,
       dp.state_desc      AS estado,       
       dp.permission_name AS permiso,
       dp.class_desc      AS clase,
       SCHEMA_NAME(dp.major_id) AS esquema
FROM sys.database_permissions dp
JOIN sys.database_principals pr
  ON pr.principal_id = dp.grantee_principal_id
WHERE pr.name = 'rol_consultas'
  AND dp.class_desc = 'SCHEMA'
ORDER BY estado, permiso, esquema;









