USE FrescuraNatural
GO

CREATE TABLE precios (
        especie VARCHAR(15),
        variedad VARCHAR(20),
        procedencia VARCHAR(15),
        envase CHAR(2),
        peso SMALLINT,
        calidad CHAR(3),
        tamaño VARCHAR(12),
        grado CHAR(3),
        maximo INT,
        modal INT,
        minimo INT,
        mapk DECIMAL(7, 2),
        mopk DECIMAL(7, 2),
        mipk DECIMAL(7, 2)
    );
GO

CREATE OR ALTER PROCEDURE sucursales.sp_ingresar_productos
    @path VARCHAR(MAX),
    @page_name VARCHAR(MAX)
AS
BEGIN
    CREATE TABLE #precios (
        especie VARCHAR(15),
        variedad VARCHAR(20),
        procedencia VARCHAR(15),
        envase CHAR(2),
        peso SMALLINT,
        calidad CHAR(3),
        tamaño VARCHAR(12),
        grado CHAR(3),
        maximo INT,
        modal INT,
        minimo INT,
        mapk DECIMAL(7, 2),
        mopk DECIMAL(7, 2),
        mipk DECIMAL(7, 2)
    );
   
    DECLARE @openrowset VARCHAR(MAX);
    SET @openrowset = 'INSERT INTO #precios
        SELECT * FROM OPENROWSET(
    ''Microsoft.ACE.OLEDB.16.0'',
    ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path +''',
    ''SELECT * FROM [' + @page_name + '$]''
    );';
    EXEC (@openrowset);
    INSERT INTO precios
        SELECT * FROM #precios
    --ORDER BY especie ASC
END;
GO

EXEC sucursales.sp_ingresar_productos <ruta>, <nombre-pagina>
