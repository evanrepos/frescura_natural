USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE datos.sp_ingresar_estadisticas
    @path VARCHAR(MAX),
    @page_name VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON 

    DECLARE @openrowset VARCHAR(MAX);
    SET @openrowset = 'INSERT INTO datos.estimaciones
        SELECT * FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.16.0'',
    ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +' '',
    ''SELECT * FROM [' + @page_name + '$]''
    )';
    EXEC (@openrowset);
    
END;
GO

EXEC datos.sp_ingresar_estadisticas 'E:\frescura_natural\fuente\02.estimaciones\estimaciones-agricolas-1969_2025.xlsx', 'Hoja1'

