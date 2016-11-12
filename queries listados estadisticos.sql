--
-- NINGUNA DE LAS QUERIES TIENE LOS FILTROS TEMPORALES QUE DEBEN PONERSE EN LOS LISTADOS
-- SOLO PRESENTAN EL RESULTADO CORRECTO SIN EL FILTRO, AGREGAR EL WHERE CUANDO SE VAYA A 
-- PONER EN LA APP

--Top 5 de las especialidades que m�s se registraron cancelaciones, tanto de
-- afiliados como de profesionales.

SELECT descripcion from SIEGRIED.ESPECIALIDADES where id_especialidad IN (
SELECT TOP 5 id_especialidad, COUNT(id_turno) 
from SIEGFRIED.TURNOS 
where id_turno in (SELECT id_turno FROM SIEGFRIED.CANCELACION)
GROUP BY id_especialidad
ORDER BY 2 desc)

----------------------------------------------------------------------------------------
-- Top 5 de los profesionales m�s consultados por Plan, detallando tambi�n bajo
-- que Especialidad.

SELECT TOP 5 usuario.nombre+' '+usuario.apellido as medico,
	   plann.descripcion,
	   especialidad.descripcion
	   count(*) as cantidad_consultas
FROM (
	SELECT 
		bono.id_plan as planid,
		turno.id_profesional as profesional
		turno.id_especialidad as especialidad
	FROM SIEGFRIED.BONOS bono
	LEFT JOIN SIEGFRIED.CONSULTAS consulta on bono.id_consulta = consulta.id_consulta
	LEFT JOIN SIEGFRIED.TURNOS turno on turno.id_turno = consulta.id_turno
	WHERE bono.id_consulta is not null ) as vista
LEFT JOIN SIEGFRIED.USUARIOS usuario ON vista.profesional = usuario.id_usuario
LEFT JOIN SIEGFRIED.PLANES plann on plann.id_plan = vista.planid
LEFT JOIN SIEGFRIED.ESPECIALIDADES especialidad on especialidad.id_especialidad = vista.especialidad
GROUP BY plann.descripcion, usuario.nombre+' '+usuario.apellido
ORDER BY 3 DESC

---------------------------------------------------------------------------------------
-- Top 5 de las especialidades de m�dicos con m�s bonos de consultas
-- utilizados.

SELECT especialidad.descripcion, vista.cantidad_consultas
FROM (
SELECT
	bono.id_bono as id_bono,
	turno.id_especialidad as id_especialidad,
	COUNT(*) as cantidad_consultas
FROM SIEGFRIED.BONOS bono
LEFT JOIN SIEGFRIED.CONSULTAS consulta on bono.id_consulta = consulta.id_consulta
LEFT JOIN SIEGFRIED.TURNOS turno on turno.id_turno = consulta.id_turno
WHERE bono.id_consulta is not null
GROUP BY 1,2
) vista
left join siegfried.especialidades especialidad on especialidad.id_especialidad = vista.id_especialidad

--------------------------------------------------------------------------------------------
--Top 5 de los profesionales con menos horas trabajadas filtrando por Plan y
--Especialidad -> AGREGAR LOS WHERE EN LA APP


SELECT TOP 5 usuario.nombre+' '+usuario.apellido as medico,
	   --plann.descripcion,
	   especialidad.descripcion,
	   count(*) / 2 as horas_trabajadas
FROM (
	SELECT 
		--bono.id_plan as planid,
		turno.id_profesional as profesional,
		turno.id_especialidad as especialidad
	FROM SIEGFRIED.BONOS bono
	LEFT JOIN SIEGFRIED.CONSULTAS consulta on bono.id_consulta = consulta.id_consulta
	LEFT JOIN SIEGFRIED.TURNOS turno on turno.id_turno = consulta.id_turno
	WHERE bono.id_consulta is not null ) as vista
LEFT JOIN SIEGFRIED.USUARIOS usuario ON vista.profesional = usuario.id_usuario
--LEFT JOIN SIEGFRIED.PLANES plann on plann.id_plan = vista.planid
LEFT JOIN SIEGFRIED.ESPECIALIDADES especialidad on especialidad.id_especialidad = vista.especialidad
--GROUP BY plann.descripcion, 
GROUP BY usuario.nombre+' '+usuario.apellido
ORDER BY 3 ASC

----------------------------------------------------------------------------------------
-- Top 5 de los afiliados con mayor cantidad de bonos comprados, detallando si
-- pertenece a un grupo familiar..

SELECT TOP 5 usuario.nombre + ' ' + usuario.apellido,
	   COUNT(*),
	   CASE WHEN bono.id_afiliado % 10 = 1 THEN 'No'
			ELSE 'Si' END as es_de_grupo_familiar
FROM SIEGFRIED.BONOS bono
LEFT JOIN SIEGFRIED.USUARIOS usuario on bono.id_afiliado = usuario.id_usuario
GROUP BY usuario.nombre + ' ' + usuario.apellido, bono.id_afiliado
ORDER BY 2 DESC
