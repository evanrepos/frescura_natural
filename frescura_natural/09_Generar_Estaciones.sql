USE FrescuraNatural
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_categorias
AS
BEGIN
	INSERT INTO productos.categoria VALUES
		('Frutas'), ('Verduras'), ('Hortalizas de raiz'), ('Hortalizas de hoja'), ('Cítricos'), ('Tropicales');
END
GO

CREATE OR ALTER PROCEDURE productos.sp_generar_temporada
AS
BEGIN
	INSERT INTO productos.temporada (descripcion, mes_desde, dia_desde) VALUES
		('Primavera', 9, 21),
		   ('Verano', 12, 21),
		    ('Otoño', 3, 21),
		 ('Invierno', 6, 21);
END
GO
