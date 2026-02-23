DECLARE @path VARCHAR(MAX) = 'E:\frescura_natural\fuente\precios_mayoristas';

USE FrescuraNatural
SELECT * FROM productos.categoria

CREATE OR ALTER PROCEDURE generar_sucursales 
    @path VARCHAR(MAX)
AS
BEGIN
    SELECT SYSDATETIME()
END;

exec generar_sucursales "hellp"

SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\frescura_natural\fuente\precios_mayoristas\RF230126.xlsx',
    'SELECT * FROM [RF230126$] ORDER BY PROC ASC'
);

SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\frescura_natural\fuente\precios_mayoristas\RF230126.xlsx',
    'SELECT * FROM [RF230126$] WHERE PROC = ""'
);
SELECT * FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;HDR=YES;IMEX=1;Database=E:\frescura_natural\fuente\01.mermas\desperdicios.xlsx',
    'SELECT * FROM [desperdicios$]'
);
