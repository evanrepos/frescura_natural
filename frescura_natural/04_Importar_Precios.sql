USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE datos.sp_ingresar_precios
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
    SET @openrowset = '
    INSERT INTO datos.precios (especie, variedad, procedencia, envase, peso, calidad, tamaño, grado, maximo, modal, minimo, mapk, mopk, mipk)
        SELECT * FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.16.0'',
    ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +' '',
    ''SELECT * FROM [' + @page_name + '$]''
    )';
    EXEC (@openrowset);
END;
GO

<<<<<<< HEAD
--PRECIOS FRUTAS
EXEC datos.sp_ingresar_precios 'E:\frescura_natural\fuente\04.precios_mayoristas\02\RF240226.xlsx', 'RF240226'
GO
--PRECIOS HORTALIZAS
EXEC datos.sp_ingresar_precios 'E:\frescura_natural\fuente\04.precios_mayoristas\02\RH240226.xlsx', 'RH240226'
GO
=======
EXEC datos.sp_ingresar_precios <ruta>, 'RF020126'
>>>>>>> 448959fd01c2789b35fc50c14c3146f4713e86ae
