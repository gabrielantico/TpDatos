use SIS_ACADEMICO_DEFINITIVO

-- Profesores que han dictado todos sus exámenes aprobados de los alumnos que no trabajan 
-- y promedio de notas de cada profesor
--(Incluyendo examenes no aprobados y de alumnos que si trabajan)                                  

CREATE PROCEDURE sp_consulta1
@trabaja BIT,
@aprobado BIT,
@fecha1 DATE,
@fecha2 DATE
AS
IF @aprobado = 1
BEGIN 
SELECT p.nombre +' '+ p.apellido AS Profesor, COUNT(e.id_examen) AS exámenes_aprobados,
       (SELECT AVG(e1.nota)
                FROM EXAMENES e1
                WHERE e1.id_profesor = p.id_profesor
                  AND e1.nota >= 6.00
                  AND e1.fecha BETWEEN @fecha1 AND @fecha2
                  AND e1.id_alumno IN (
                      SELECT a.id_alumno
                      FROM ALUMNOS a
                      WHERE a.trabaja = @trabaja)) AS 'nota promedio'
FROM PROFESORES p
JOIN EXAMENES e ON p.id_profesor = e.id_profesor
WHERE e.nota >= 6.00 AND fecha BETWEEN @fecha1 AND @fecha2
AND e.id_alumno IN (
    SELECT a.id_alumno
    FROM ALUMNOS a
    WHERE a.trabaja = @trabaja
)
GROUP BY p.id_profesor, p.nombre, p.apellido
ORDER BY exámenes_aprobados DESC
END
ELSE
BEGIN
SELECT p.nombre +' '+ p.apellido Profesor, COUNT(e.id_examen) AS exámenes_aprobados,
       (SELECT AVG(e1.nota)
                FROM EXAMENES e1
                WHERE e1.id_profesor = p.id_profesor
                  AND e1.nota < 6.00
                  AND e1.fecha BETWEEN @fecha1 AND @fecha2
                  AND e1.id_alumno IN (
                      SELECT a.id_alumno
                      FROM ALUMNOS a
                      WHERE a.trabaja = @trabaja)) AS 'nota promedio'
FROM PROFESORES p
JOIN EXAMENES e ON p.id_profesor = e.id_profesor
WHERE e.nota < 6.00 AND fecha BETWEEN @fecha1 AND @fecha2
AND e.id_alumno IN (
    SELECT a.id_alumno
    FROM ALUMNOS a
    WHERE a.trabaja = @trabaja
)
GROUP BY p.id_profesor, p.nombre, p.apellido
ORDER BY exámenes_aprobados DESC
END

--set dateformat dmy

--Execute sp_consulta1 1, 1, '20/11/2020', '11/11/2024'

-- Alumnos que han aprobado al menos n examenes en un periodo determinado, 
-- que sean de determinada provincia y que su promedio de notas general de
-- de toda la carrera sea mayor a cierto numero elegido por el usuario


--Modificado
--Suponiendo que cada alumno esta inscripto en una sola carrera
CREATE PROCEDURE sp_consulta2
@fecha1 DATE,
@fecha2 DATE,
@provincia INT,
@promedio float,
@aprobados int

AS
BEGIN
SELECT a.nombre +' '+a.apellido 'Alumnos', p.nom_provincia 'Provincia', c.descripcion, (select AVG(e1.nota)
																						from EXAMENES e1
																						join MATERIAS_CARRERAS mc1 on mc1.id_materia_carrera = e1.id_materia_carrera
																						join CARRERAS c1 on c1.id_carrera = mc1.id_carrera
																						where e1.id_alumno = a.id_alumno
																						and c.id_carrera = c1.id_carrera) 'Promedio de carrera',
		COUNT(id_examen) 'Aprobados'
FROM ALUMNOS a
JOIN BARRIOS b ON a.id_barrio = b.id_barrio
JOIN LOCALIDADES l ON b.id_localidad = l.id_localidad
JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
JOIN EXAMENES e on e.id_alumno = a.id_alumno
JOIN MATERIAS_CARRERAS mc on mc.id_materia_carrera = e.id_materia_carrera
JOIN CARRERAS c on c.id_carrera = mc.id_materia_carrera
WHERE e.nota >= 6.00 AND fecha BETWEEN @fecha1 AND @fecha2 

AND p.id_provincia = @provincia  
group by a.id_alumno, a.nombre +' '+a.apellido, c.id_carrera, c.descripcion, p.nom_provincia
having (select AVG(e1.nota)
		from EXAMENES e1
		where e1.id_alumno = a.id_alumno) >= @promedio
and Count(id_examen) >= @aprobados
END

select * from EXAMENES e
join ALUMNOS a on a.id_alumno = e.id_alumno

/*MODIFICAR PARA FILTRAR POR N EXAMENES*/

--create PROCEDURE sp_consulta2
--@fecha1 DATE,
--@fecha2 DATE,
--@provincia INT,
--@promedio double
--as
--BEGIN
--SELECT a.nombre +' '+a.apellido 'Alumnos', p.nom_provincia 'Provincia', AVG(e.nota) 'Promedio de carrera'
--FROM ALUMNOS a
--JOIN BARRIOS b ON a.id_barrio = b.id_barrio
--JOIN LOCALIDADES l ON b.id_localidad = l.id_localidad
--JOIN PROVINCIAS p ON l.id_provincia = p.id_provincia
--join EXAMENES e on e.id_alumno = a.id_alumno
--WHERE a.id_alumno IN (
--    SELECT e.id_alumno
--    FROM EXAMENES e1
--    WHERE e1.nota >= 6.00
--   AND fecha BETWEEN @fecha1 AND @fecha2 
--)
--AND p.id_provincia = @provincia  
--group by a.id_alumno, a.nombre +' '+a.apellido, p.nom_provincia
--having AVG(e.nota) > @promedio
--END

-- Listar los profesores que enseñen el tipo de carrera ingresada, 
-- con sus respectivas materias, en las que sus alumnos
-- tengan mayor promedio de notas en sus exámenes de este año que en un año ingresado por el usuario. 
-- (Promedio de examenes en carreras de grado).

create procedure sp_consulta3
@tipoCarrera int, --cambiar por INT y usar un ComboBox
@mayorPromedio bit,
@anio INT
as
 if @mayorPromedio=1
  begin
   select p.apellido+', '+p.nombre 'Profesor', c.descripcion 'Carrera', AVG(e.nota) 'Promedio de notas', (select AVG(nota)
	   				   from EXAMENES e1
		   			   join MATERIAS_CARRERAS mc1 on mc1.id_materia_carrera = e1.id_materia_carrera
					   join CARRERAS c1 on c1.id_carrera = mc1.id_carrera
					   join TIPOS_CARRERAS tc1 on tc1.id_tipo_carrera = c1.id_tipo_carrera
					   where year(fecha)= year(getdate())
					   and p.id_profesor = e1.id_profesor
					   and tc1.id_tipo_carrera = @tipoCarrera) 'Promedio de este año'
   from PROFESORES p
   join EXAMENES e on e.id_profesor=p.id_profesor
   join MATERIAS_CARRERAS mc on mc.id_materia_carrera=e.id_materia_carrera
   join CARRERAS c on c.id_carrera=mc.id_carrera
   join MATERIAS m on m.id_materia=mc.id_materia
   join TIPOS_CARRERAS tc on tc.id_tipo_carrera=c.id_tipo_carrera
   where tc.id_tipo_carrera = @tipoCarrera 
   and year(fecha)=@anio
   group by p.id_profesor, c.descripcion, p.apellido+', '+p.nombre
   having AVG(e.nota)<(select AVG(nota)
	   				   from EXAMENES e1
		   			   join MATERIAS_CARRERAS mc1 on mc1.id_materia_carrera = e1.id_materia_carrera
					   join CARRERAS c1 on c1.id_carrera = mc1.id_carrera
					   join TIPOS_CARRERAS tc1 on tc1.id_tipo_carrera = c1.id_tipo_carrera
					   where year(fecha)= year(getdate())
					   and p.id_profesor = e1.id_profesor
					   and tc1.id_tipo_carrera = @tipoCarrera)
  end
 else
  begin
   select p.apellido+', '+p.nombre 'Profesor', c.descripcion 'Carrera', 
   AVG(e.nota) 'Promedio de notas', (select AVG(nota)
	   				   from EXAMENES e1
		   			   join MATERIAS_CARRERAS mc1 on mc1.id_materia_carrera = e1.id_materia_carrera
					   join CARRERAS c1 on c1.id_carrera = mc1.id_carrera
					   join TIPOS_CARRERAS tc1 on tc1.id_tipo_carrera = c1.id_tipo_carrera
					   where year(fecha)= year(getdate())
					   and p.id_profesor = e1.id_profesor
					   and tc1.id_tipo_carrera = @tipoCarrera) 'Promedio de este año'
   from PROFESORES p
   join EXAMENES e on e.id_profesor=p.id_profesor
   join MATERIAS_CARRERAS mc on mc.id_materia_carrera=e.id_materia_carrera
   join CARRERAS c on c.id_carrera=mc.id_carrera
   join MATERIAS m on m.id_materia=mc.id_materia
   join TIPOS_CARRERAS tc on tc.id_tipo_carrera=c.id_tipo_carrera
   where tc.id_tipo_carrera = @tipoCarrera
   and year(fecha)=@anio
   group by p.id_profesor, c.descripcion, p.apellido+', '+p.nombre
   having AVG(e.nota)>(select AVG(nota)
	   				   from EXAMENES e1
		   			   join MATERIAS_CARRERAS mc1 on mc1.id_materia_carrera = e1.id_materia_carrera
					   join CARRERAS c1 on c1.id_carrera = mc1.id_carrera
					   join TIPOS_CARRERAS tc1 on tc1.id_tipo_carrera = c1.id_tipo_carrera
					   where year(fecha)= year(getdate())
					   and p.id_profesor = e1.id_profesor
					   and tc1.id_tipo_carrera = @tipoCarrera)
  end

exec sp_consulta3 1, 1, 2021

select * from EXAMENES
select * from MATERIAS_CARRERAS mc
join CARRERAS c on c.id_carrera = mc.id_carrera

--mostrar las materias con mas inasistencias en un periodo determinado, dictadas por profes cuyos examenes promedien mas de cierto número
CREATE PROCEDURE sp_consulta4
    @promedioMinimo float,  -- Promedio mínimo para el filtro
    @fecha1 date,                 -- Mes inicial para el rango de fechas
    @fecha2 date                     -- Mes final para el rango de fechas
AS
BEGIN
    -- Crear una tabla temporal para almacenar los resultados de la consulta intermedia
    CREATE TABLE #ConsultaTemporal (
        Profesor VARCHAR(100),
        Materia VARCHAR(100),
        Asistencias INT,
        PROMEDIO DECIMAL(5, 2)
    );

    -- Insertar los datos en la tabla temporal con el filtro de fechas y el cálculo de promedio
    INSERT INTO #ConsultaTemporal (Profesor, Materia, Asistencias, PROMEDIO)
    SELECT 
        p.apellido + ' ' + p.nombre AS Profesor,
        m.descripcion AS Materia,
        COUNT(a.presente) AS Asistencias,
        AVG(e.nota) AS PROMEDIO
    FROM 
        MATERIAS m
        JOIN MATERIAS_CARRERAS mc ON mc.id_materia = m.id_materia
        JOIN ASISTENCIAS a ON a.id_materia_carrera = mc.id_materia_carrera
        JOIN COMISIONES c ON c.id_carrera = mc.id_carrera
        JOIN PROFESORES_COMISIONES pc ON pc.id_comision = c.id_comision
        JOIN PROFESORES p ON p.id_profesor = pc.id_profesor
        JOIN EXAMENES e ON e.id_profesor = p.id_profesor
    WHERE 
        a.fecha BETWEEN @fecha1 AND @fecha2
        AND a.presente = 1
    GROUP BY 
        p.apellido +' '+ p.nombre, m.descripcion;

    -- Seleccionar las materias con el mínimo de asistencias y un promedio superior al ingresado
    SELECT 
        Profesor, 
        Materia, 
        MIN(Asistencias) AS Min_Asistencias,
		PROMEDIO
    FROM 
        #ConsultaTemporal
    WHERE 
        PROMEDIO >= @promedioMinimo
    GROUP BY 
        Profesor, 
        Materia,
		PROMEDIO;

    -- Limpiar la tabla temporal
    DROP TABLE #ConsultaTemporal;
END;

--CREATE PROCEDURE sp_consulta5
--    @carrera int,
--    @fecha_inicio DATE,
--    @fecha_fin DATE

--AS
--BEGIN
--    -- Primera consulta: Profesores
--    SELECT P.nombre +' '+ P.apellido Persona, C.descripcion AS Carrera, COUNT(E.id_examen) AS Total_Examenes, 'Profesor'
--    FROM PROFESORES P
--    JOIN EXAMENES E ON P.id_profesor = E.id_profesor
--    JOIN MATERIAS_CARRERAS MC ON E.id_materia_carrera = MC.id_materia_carrera
--    JOIN CARRERAS C ON MC.id_carrera = C.id_carrera
--    WHERE C.id_carrera = @carrera
--    AND E.fecha BETWEEN @fecha_inicio AND @fecha_fin
--    GROUP BY P.id_profesor, P.nombre, P.apellido, C.descripcion
--    HAVING COUNT(DISTINCT MC.id_carrera) > 1

--    UNION

--    -- Segunda consulta: Alumnos
--    SELECT A.nombre +' '+ A.apellido, C.descripcion AS Carrera, COUNT(E.id_examen) AS Total_Examenes, 'Alumno'
--    FROM ALUMNOS A
--    JOIN EXAMENES E ON E.id_alumno = A.id_alumno
--    JOIN INSCRIPCIONES I ON A.id_alumno = I.id_alumno
--    JOIN MATERIAS_CARRERAS MC ON I.id_materia_carrera = MC.id_materia_carrera
--    JOIN CARRERAS C ON MC.id_carrera = C.id_carrera
--    WHERE C.id_carrera = @carrera
--    AND E.fecha BETWEEN @fecha_inicio AND @fecha_fin
--    GROUP BY A.id_alumno, A.nombre, A.apellido, C.descripcion;
--END

--Consulta para obtener los profesores que han tomado exámenes en más de una carrera, mostrando la carrera, el profesor y el total
--de exámenes por carrera. En la misma tabla de resultado mostrar los alumnos que estan inscriptos en mas de una carrera y cuantos examenes rindio
CREATE PROCEDURE sp_consulta5
    @carrera INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    -- Primera consulta: Profesores
    SELECT 
        P.nombre + ' ' + P.apellido AS Persona,
        COUNT(E.id_examen) AS Total_Examenes,
        -- Subconsulta para contar las carreras en las que el profesor ha dictado exámenes
        (SELECT COUNT(DISTINCT MC.id_carrera)
         FROM MATERIAS_CARRERAS MC
         JOIN EXAMENES E1 ON E1.id_materia_carrera = MC.id_materia_carrera
         WHERE E1.id_profesor = P.id_profesor) AS Total_Carreras, -- Cantidad de carreras en las que ha dictado exámenes
		 C.descripcion Carrera,
        'Profesor' AS Rol
    FROM PROFESORES P
    JOIN EXAMENES E ON P.id_profesor = E.id_profesor
    JOIN MATERIAS_CARRERAS MC ON E.id_materia_carrera = MC.id_materia_carrera
    JOIN CARRERAS C ON MC.id_carrera = C.id_carrera
    WHERE C.id_carrera = @carrera -- Solo los exámenes para la carrera seleccionada
    AND E.fecha BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY P.id_profesor, P.nombre + ' ' + P.apellido, c.descripcion
    HAVING (SELECT COUNT(DISTINCT MC.id_carrera)
            FROM MATERIAS_CARRERAS MC
            JOIN EXAMENES E1 ON E1.id_materia_carrera = MC.id_materia_carrera
            WHERE E1.id_profesor = P.id_profesor) > 1 -- Profesores que han dictado exámenes en más de una carrera

    UNION

    -- Segunda consulta: Alumnos
    SELECT 
        A.nombre + ' ' + A.apellido AS Persona,
        COUNT(E.id_examen) AS Total_Examenes,
        -- Subconsulta para contar las carreras en las que el alumno está inscrito
        (SELECT COUNT(DISTINCT MC.id_carrera)
         FROM MATERIAS_CARRERAS MC
         JOIN INSCRIPCIONES I1 ON I1.id_materia_carrera = MC.id_materia_carrera
         WHERE I1.id_alumno = A.id_alumno) AS Total_Carreras, -- Cantidad de carreras en las que está inscrito
		 C.descripcion Carrera,
        'Alumno' AS Rol
    FROM ALUMNOS A
    JOIN EXAMENES E ON E.id_alumno = A.id_alumno
    JOIN INSCRIPCIONES I ON A.id_alumno = I.id_alumno
    JOIN MATERIAS_CARRERAS MC ON I.id_materia_carrera = MC.id_materia_carrera
    JOIN CARRERAS C ON MC.id_carrera = C.id_carrera
    WHERE C.id_carrera = @carrera -- Solo los exámenes para la carrera seleccionada
    AND E.fecha BETWEEN @fecha_inicio AND @fecha_fin
    GROUP BY A.id_alumno, A.nombre + ' ' + A.apellido, c.descripcion
    HAVING (SELECT COUNT(DISTINCT MC.id_carrera)
            FROM MATERIAS_CARRERAS MC
            JOIN INSCRIPCIONES I1 ON I1.id_materia_carrera = MC.id_materia_carrera
            WHERE I1.id_alumno = A.id_alumno) > 1 -- Alumnos inscritos en más de una carrera
END
