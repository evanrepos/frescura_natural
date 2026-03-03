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
---- Política de Respaldo – Base de Datos FrescuraNatural
/*

- Objetivo General 
	Definir un mecanismo de respaldo que garantice la recuperación de la base 
	ante fallas, considerando que el negocio actualiza precios diariamente.

- RPO (Recovery Point Objective)
	RPO = 24 horas
	* El sistema puede importar mermas, estadísticas y precios una vez por día.
	* El negocio puede tolerar perder como máximo la información generada en el 
	  último día, ya que los procesos de importación pueden volver a ejecutarse.

- RTO (Recovery Time Objective)
	RTO = 2–4 horas
	Tiempo estimado necesario para:
	* Restaurar la base.
	* Verificar integridad.
	* Ejecutar nuevamente la importación de precios del día si fuera necesario.

- Estrategia de Backup
	Backup FULL (obligatorio)
	* Frecuencia: 1 vez por día, en horario nocturno.
	* Contiene la base completa e incluye todos los datos requeridos por el sistema

	Backup DIFFNCIAL (opcional)
	* Frecuencia: diario al mediodía 
	* Reduce tiempo de restauración si ocurre un incidente antes del siguiente backup FULL.

- Retencion de Backups
	Mantener 7 días de backups FULL (una semana completa).
	Los DIFFERENCIALES, si se usan, pueden conservarse por 48 horas.

*/
