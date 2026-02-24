USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE datos.sp_ingresar_precios
    @path VARCHAR(MAX),
    @page_name VARCHAR(MAX)
AS
BEGIN
    DECLARE @openrowset VARCHAR(MAX);
    SET @openrowset = 'INSERT INTO datos.precios
        SELECT * FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.16.0'',
    ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +' '',
    ''SELECT * FROM [' + @page_name + '$]''
    )';
    EXEC (@openrowset);
    
END;
GO

EXEC datos.sp_ingresar_precios <ruta>, 'RF020126'