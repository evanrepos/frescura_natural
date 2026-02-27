USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_temporada
AS
BEGIN
	DELETE FROM productos.temporada
	DBCC CHECKIDENT ('productos.temporada', RESEED, 0)

	INSERT INTO productos.temporada (descripcion, mes_desde, dia_desde) VALUES
		('Primavera', 9, 21),
		   ('Verano', 12, 21),
		    ('Otoño', 3, 21),
		 ('Invierno', 6, 21);
END
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_categorias
AS
	DECLARE @id_temporada INT;
BEGIN
	DELETE FROM productos.categoria
	DBCC CHECKIDENT ('productos.categoria', RESEED, 0)

	SELECT @id_temporada = id FROM productos.temporada WHERE descripcion LIKE '%Primavera%'
	INSERT INTO productos.categoria (id_temporada, descripcion, dias_caducidad, margen) VALUES
		(@id_temporada , 'Hierbas y aromaticas', 5, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Frutas pequenas', 3, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5)

	SELECT @id_temporada = id FROM productos.temporada WHERE descripcion LIKE '%Verano%'
	INSERT INTO productos.categoria (id_temporada, descripcion, dias_caducidad, margen) VALUES
		(@id_temporada , 'Verduras de fruto', 7, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Cucurbitaceas', 14, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Frutas de carozo', 5, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Frutas tropicales', 10, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5)

	SELECT @id_temporada = id FROM productos.temporada WHERE descripcion LIKE '%Otoño%'
	INSERT INTO productos.categoria (id_temporada, descripcion, dias_caducidad, margen) VALUES
		(@id_temporada , 'Frutas de pepita', 90, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5)

	SELECT @id_temporada = id FROM productos.temporada WHERE descripcion LIKE '%Invierno%'
	INSERT INTO productos.categoria (id_temporada, descripcion, dias_caducidad, margen) VALUES
		(@id_temporada , 'Verduras de hoja' , 5, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Tuberculos', 60, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Bulbos y tallos', 30, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5),
		(@id_temporada , 'Citricos', 21, CAST(RAND(CHECKSUM(NEWID())) * 7 + 1 AS INT) * 5)

END
GO

EXEC productos.sp_generar_temporada
GO
EXEC productos.sp_generar_categorias
GO

SELECT * FROM productos.categoria
GO
SELECT * FROM productos.temporada
GO