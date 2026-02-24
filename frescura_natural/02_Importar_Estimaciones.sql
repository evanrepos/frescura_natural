USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE datos.sp_ingresar_estadisticas
    @path VARCHAR(MAX),
    @page_name VARCHAR(MAX)
AS
BEGIN
<<<<<<< HEAD
    SET NOCOUNT ON 
=======
    SET NOCOUNT ON
>>>>>>> 448959fd01c2789b35fc50c14c3146f4713e86ae
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

<<<<<<< HEAD
EXEC datos.sp_ingresar_estadisticas 'E:\frescura_natural\fuente\02.estimaciones\estimaciones-agricolas-1969_2025.xlsx', 'Hoja1'
=======
EXEC datos.sp_ingresar_estadisticas <ruta>, 'Hoja1'
>>>>>>> 448959fd01c2789b35fc50c14c3146f4713e86ae
