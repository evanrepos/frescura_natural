USE FrescuraNatural
GO

SELECT * FROM datos.precios
ORDER BY id
GO

CREATE OR ALTER PROCEDURE datos.ingresar_precios_dia
    @path VARCHAR(255),
    @datetime CHAR(6)
AS
    DECLARE @openrowset VARCHAR(MAX);
    DECLARE @prefijo CHAR(2);
    DECLARE @i INT = 1;
BEGIN
    SET NOCOUNT ON 
    
    CREATE TABLE datos.#precios_nuevos
    (
        id INT IDENTITY(1, 1),
        especie VARCHAR(30),
        variedad VARCHAR(30),
        procedencia VARCHAR(30),
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
        mipk DECIMAL(7, 2),
    )
    --Al iniciar, inicializa los precios de la tabla en cero, permitiendo la actualización y la inserción de nuevos productos.
    UPDATE datos.precios SET maximo = 0, modal = 0, minimo = 0, mapk = 0, mopk = 0, mipk = 0,
        procedencia = 'Mercado Central' WHERE procedencia = ''

    --Al insertar, rige la constraint UNIQUE para productos, evitando duplicados.
    --RECONFIGURE
    WHILE @i <= 2
    BEGIN
        IF @i = 1
        BEGIN
            SET @prefijo = 'RF';
        END
        IF @i = 2
        BEGIN
            SET @prefijo = 'RH';
        END
        
        SET @openrowset = '
        INSERT INTO datos.#precios_nuevos
            SELECT * FROM OPENROWSET(''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @path + '\' + @prefijo + @datetime + '.xlsx'+''',
            ''SELECT * FROM [' + @prefijo + @datetime + '$]''
            );
            ';
        EXEC (@openrowset);
        UPDATE datos.#precios_nuevos SET procedencia = 'Mercado Central' WHERE procedencia = ''
        
        MERGE datos.precios AS viejo
        USING (SELECT * FROM datos.#precios_nuevos) AS nuevo
        ON     viejo.especie = nuevo.especie AND
              viejo.variedad = nuevo.variedad AND
           viejo.procedencia = nuevo.procedencia AND
                viejo.envase = nuevo.envase AND
                  viejo.peso = nuevo.peso AND
               viejo.calidad = nuevo.calidad AND
                viejo.tamaño = nuevo.tamaño AND
                 viejo.grado = nuevo.grado
        WHEN MATCHED THEN
            UPDATE SET maximo = nuevo.maximo,
                        modal = nuevo.modal,
                       minimo = nuevo.minimo,
                         mapk = nuevo.mapk, 
                         mopk = nuevo.mopk,
                         mipk = nuevo.mipk
        WHEN NOT MATCHED THEN
            INSERT (especie, variedad, procedencia, 
                envase, peso, calidad, tamaño, grado, 
                maximo, modal, minimo, mapk, mopk, mipk)
            VALUES (nuevo.especie, nuevo.variedad, nuevo.procedencia, 
                nuevo.envase, nuevo.peso, nuevo.calidad, 
                nuevo.tamaño, nuevo.grado, nuevo.maximo, 
                nuevo.modal, nuevo.minimo, nuevo.mapk, 
                nuevo.mopk, nuevo.mipk);
        SET @i = @i + 1;
    END
    
END;
GO

CREATE OR ALTER PROCEDURE datos.cargar_lote (@path VARCHAR(255))
AS
    DECLARE @path_name VARCHAR(255);
    DECLARE @file_name CHAR(6);
BEGIN
    --Crear tabla temporal de archivos.
    CREATE TABLE #archivos(
        id INT IDENTITY(1, 1),
        subdirectory VARCHAR(255),
        depth INT,
        is_file BIT
    );
    
    --Por CADA CARPETA de mes, se CARGA el lote de archivos.
    DECLARE @i TINYINT = 1;
    WHILE @i <= MONTH(SYSDATETIME())
    BEGIN
        --INICIALIZAR TABLAS
        DELETE FROM #archivos
        DBCC CHECKIDENT('#archivos', RESEED, 0)

        --Listar todos los archivos en la tabla.
        IF @i < 10
            SELECT @path_name = @path + '\' + '0' + CAST(@i AS CHAR(1));
        ELSE
            SELECT @path_name = @path + '\' + CAST(@i AS CHAR(2));

        INSERT INTO #archivos (subdirectory, depth, is_file)
            EXEC xp_dirtree @path_name, 1, 1;
        UPDATE #archivos SET subdirectory = RIGHT(REPLACE(subdirectory, '.xlsx', ''), 6)

        --Por CADA ARCHIVO del lote, se produce la INSERCIÓN.
        DECLARE @j TINYINT = 1;
        DECLARE @max TINYINT = (SELECT COUNT(1) FROM #archivos);
        WHILE @j <= @max
        BEGIN
            SELECT @file_name = subdirectory FROM #archivos WHERE id = @j;
            EXEC datos.ingresar_precios_dia @path_name, @file_name;
            SET @j = @j + 1;
        END
        SET @i = @i + 1;
    END
END
GO

--CARGAR LOTE DE PRODUCTOS
EXEC datos.cargar_lote 'E:\frescura_natural\fuente\04.precios_mayoristas';
GO

--CARGAR ARCHIVO DE DÍA ESPECÍFICO
--EXEC datos.ingresar_precios_dia 'E:\frescura_natural\fuente\04.precios_mayoristas\02', '260226'
--GO
SELECT * FROM datos.precios
ORDER BY id
GO