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


-- Inserts

insert into ESTADOS_CIVIL(id_estado_civil, descripcion) values
(1, 'Soltero'),
(2, 'Casado')

insert into TIPOS_RESIDENCIAS(id_tipo_residencia, descripcion) values
(1, 'Casa'),
(2, 'Departamento')

insert into PAISES(id_pais, nom_pais) values
(1, 'Argentina'),
(2, 'Chile'),
(3, 'Uruguay')

insert into PROVINCIAS(id_provincia, nom_provincia, id_pais) values
(1, 'Córdoba', 1),
(2, 'Buenos Aires', 1),
(3, 'Santiago de Chile', 2),
(4, 'Montevideo', 3),
(5, 'Entre Rios', 1),
(6, 'Corrientes', 1),
(7, 'Tierra Del Fuego', 1)

insert into LOCALIDADES(id_localidad, nom_localidad, id_provincia) values
(1, 'Córdoba', 1),
(2, 'Alta Gracia', 1),
(3, 'La Plata', 2),
(4, 'Lo Chacon', 3),
(5, 'Montevideo', 4),
(6, 'Paraná', 5),
(7, 'Pueblo Libertador', 6),
(8, 'Ushuaia', 7)


insert into BARRIOS(id_barrio, nom_barrio, id_localidad) values
(1, 'Nueva Córdoba', 1),
(2, 'Centro', 1),
(3, 'San Carlos', 3),
(4, 'Santa Isabel', 4),
(5, 'Barrio Sur', 5),
(6, 'Santa Lucia',6),
(7, 'Pueblo Libertador', 7),
(8, 'Bella Vista', 8)



insert into ALUMNOS(id_alumno, nombre, apellido, dni, mail, telefono, direccion, altura, fecha_nacimiento, id_barrio, trabaja, id_estado_civil, id_tipo_residencia) values
(1, 'Laura', 'Sánchez', 30123456, 'laura.sanchez@example.com', '1123456789', 'Calle Norte', 102, '1992-02-14', 1, 0, 1, 2),
(2, 'Pedro', 'Ramírez', 31234567, 'pedro.ramirez@example.com', '1234567890', 'Avenida Sur', 205, '1996-07-22', 2, 0, 2, 1),
(3, 'Carla', 'Torres', 32345678, 'carla.torres@example.com', '0987654321', 'Calle Este', 58, '2001-11-03', 3, 1, 1, 1),
(4, 'Roberto', 'García', 33456789, 'roberto.garcia@example.com', '3344556677', 'Boulevard Oeste', 220, '1995-05-30', 4, 0, 2, 2),
(5, 'Sofía', 'Martínez', 34567890, 'sofia.martinez@example.com', '5566778899', 'Calle Centro', 301, '1990-01-10', 5, 0, 1, 1),
(6, 'Fernando', 'Pérez', 35678901, 'fernando.perez@example.com', '6677889900', 'Avenida Libertad', 410, '1998-09-12', 6, 0, 2, 1),
(7, 'Camila', 'Fernández', 36789012, 'camila.fernandez@example.com', '9988776655', 'Calle Independencia', 180, '2002-12-24', 7, 1, 1, 2),
(8, 'Daniel', 'López', 37890123, 'daniel.lopez@example.com', '7766554433', 'Boulevard Rivadavia', 77, '1993-03-08', 8, 0, 1, 2),
(9, 'Luciana', 'Gómez', 38901234, 'luciana.gomez@example.com', '8899776655', 'Avenida América', 129, '1994-06-20', 1, 0, 2, 1),
(10, 'Gustavo', 'Álvarez', 39012345, 'gustavo.alvarez@example.com', '9988774411', 'Calle Primavera', 66, '2004-08-15', 2, 1, 2, 2),
(11, 'Julia', 'Morales', 40123456, 'julia.morales@example.com', '8877665544', 'Calle Verano', 305, '1997-10-29', 3, 0, 1, 1),
(12, 'Lucas', 'Vázquez', 41234567, 'lucas.vazquez@example.com', '1234432112', 'Avenida Otoño', 200, '1999-04-02', 4, 0, 2, 2),
(13, 'Marta', 'Ríos', 42345678, 'marta.rios@example.com', '3344221133', 'Boulevard Invierno', 152, '2000-07-18', 5, 1, 1, 2),
(14, 'Alejandro', 'Castro', 43456789, 'alejandro.castro@example.com', '5566443322', 'Nueva', 240, '1991-12-05', 6, 0, 2, 1),
(15, 'Valeria', 'Ruiz', 44567890, 'valeria.ruiz@example.com', '2233445566', 'Antigua', 88, '2005-02-14', 6, 0, 1, 2),
(16, 'Esteban', 'Flores', 45678901, 'esteban.flores@example.com', '6677889900', 'Boulevard Principal', 370, '2003-05-27', 7, 0, 1, 1),
(17, 'Mariana', 'Silva', 46789012, 'mariana.silva@example.com', '3344556677', 'Avenida Secundaria', 190, '1992-03-25', 8, 0, 2, 1),
(18, 'Andrés', 'Reyes', 47890123, 'andres.reyes@example.com', '5566778899', 'Estrella', 99, '1996-11-09', 1, 1, 1, 2),
(19, 'Florencia', 'Méndez', 48901234, 'florencia.mendez@example.com', '8877665544', 'Avenida Luna', 130, '2006-01-31', 2, 0, 2, 1),
(20, 'Diego', 'Ortiz', 49012345, 'diego.ortiz@example.com', '9988776655', 'Sol', 412, '1993-09-16', 3, 0, 1, 2)

INSERT INTO ALUMNOS (id_alumno, nombre, apellido, dni, mail, telefono, direccion, altura, fecha_nacimiento, id_barrio, trabaja, id_estado_civil, id_tipo_residencia) 
VALUES 
(21, 'Ricardo', 'Gutiérrez', '50123456', 'ricardogutierrez@example.com', '2233445566', 'Noche', 150, '1994-04-18', 1, 0, 2, 2),
(22, 'Bárbara', 'Luna', '51234567', 'barbaraluna@example.com', '5566778899', 'Avenida Sol', 160, '2001-06-12', 2, 0, 1, 1),
(23, 'Martín', 'Molina', '52345678', 'martinmolina@example.com', '6677889900', 'Boulevard Sur', 175, '1990-12-30', 3, 0, 2, 1),
(24, 'Paula', 'Díaz', '53456789', 'pauladiaz@example.com', '9988776655', 'Norte', 162, '1992-07-22', 2, 1, 1, 2),
(25, 'Jorge', 'Pérez', '54567890', 'jorgeperez@example.com', '3344556677', 'Avenida Este', 180, '1997-11-06', 2, 0, 1, 1),
(26, 'Esteban', 'Gómez', '55678901', 'estebangomez@example.com', '2233445566', 'Libertad', 190, '1993-10-10', 4, 1, 2, 1),
(27, 'Viviana', 'Serrano', '56789012', 'vivianaserrano@example.com', '3344556677', 'Boulevard Oeste', 170, '2000-02-19', 5, 0, 1, 2),
(28, 'Fernando', 'Paredes', '57890123', 'fernandoparedes@example.com', '5566778899', 'Avenida Sur', 185, '1999-09-11', 2, 1, 2, 2),
(29, 'Gabriela', 'Méndez', '58901234', 'gabrielamendez@example.com', '9988776655', 'Primavera', 155, '2003-03-17', 3, 0, 1, 2),
(30, 'Adrián', 'López', '59012345', 'adrianlopez@example.com', '7766554433', 'Estrella', 168, '1995-05-23', 2, 0, 2, 1),
(31, 'Felipe', 'Monte', '456137235', 'felipemonte@gmail.com', '6380465', 'Entre Rios', 45, '2004-02-28', 1, 0, 1, 1),
(32,'Felipe', 'Varella', '45812946', 'felipevarella@gmail.com', '3854206629', 'Caseros', 142, '2004-12-06', 1, 1, 2,1)


insert into profesores(id_profesor, nombre, apellido, dni, mail, telefono, direccion, altura, fecha_nacimiento, id_barrio) values
(1, 'Carlos', 'Ramírez', 30123456, 'carlos.ramirez@example.com', '1122334455', 'Calle Buenos Aires', 178, '1985-08-14', 1),
(2, 'Ana', 'Martínez', 31234567, 'ana.martinez@example.com', '2233445566', 'Avenida Libertad', 165, '1990-05-23', 2),
(3, 'Luis', 'González', 32345678, 'luis.gonzalez@example.com', '3344556677', 'Calle Rosario', 172, '1988-03-12', 3),
(4, 'María', 'López', 33456789, 'maria.lopez@example.com', '4455667788', 'Boulevard San Martín', 160, '1995-02-20', 1),
(5, 'Ricardo', 'Fernández', 34567890, 'ricardo.fernandez@example.com', '5566778899', 'Avenida Este', 180, '1992-07-30', 2),
(6, 'Laura', 'Sánchez', 35678901, 'laura.sanchez@example.com', '6677889900', 'Calle Montevideo', 155, '1993-09-14', 1),
(7, 'Felipe', 'Gómez', 36789012, 'felipe.gomez@example.com', '7788990011', 'Calle del Sol', 170, '1989-11-02', 1),
(8, 'Beatriz', 'Torres', 37890123, 'beatriz.torres@example.com', '8899001122', 'Avenida Belgrano', 168, '1991-01-28', 2),
(9, 'Pedro', 'Vázquez', 38901234, 'pedro.vazquez@example.com', '9900112233', 'Calle del Río', 175, '1994-06-19', 1),
(10, 'Sandra', 'Díaz', 39012345, 'sandra.diaz@example.com', '1100223344', 'Avenida Norte', 162, '1996-10-11', 1)

insert into TIPOS_CARRERAS(id_tipo_carrera, descripcion) values
(1, 'Grado'),
(2, 'Tecnicatura'),
(3, 'Licenciatura')

insert into CARRERAS(id_carrera, descripcion, duracion, cant_materias, id_tipo_carrera) values
(1, 'Ingeniería Civil', 5, 42, 1),
(2, 'Ingeniería Industrial', 5, 42, 1),
(3, 'Ingeniería Química', 5, 42, 1),
(4, 'Tecnicatura en Programación', 2, 17, 2),
(5, 'Licenciatura en Comercio Electrónico', 4, 38, 3)

insert into MATERIAS(id_materia, descripcion) values 
(1, 'Cálculo Diferencial'), (2, 'Física I'), 
(3, 'Estudio de Operaciones'), (4, 'Estadística Aplicada'), 
(5, 'Termodinámica'), (6, 'Química Orgánica'), 
(7, 'Programación Básica'), (8, 'Bases de Datos'), 
(9, 'Marketing Digital'), (10, 'E-commerce y Logística')

insert into MATERIAS_CARRERAS(id_materia, id_carrera) values 
(1, 1), (2, 1), 
(3, 2), (4, 2), 
(5, 3), (6, 3), 
(7, 4), (8, 4), 
(9, 5), (10, 5);

insert into COMISIONES(id_comision, descripcion, año, semestre, cant_inscriptos, id_carrera) values
(1, '1w1', 1, 1, 124, 1),
(2, '1q1', 1, 1, 90, 2),
(3, '1m1', 1, 1, 78, 3),
(4, '1h1', 1, 1, 108, 4),
(5, '1c1', 1, 1, 111, 5)

insert into ESTADO_ACADEMICO(id_estado, descripcion) values
(1, 'Promocionado'),
(2, 'Regular'),
(3, 'Libre')

insert into PROFESORES_COMISIONES(id_profesor_comision, id_profesor, id_comision) values 
(1, 1, 1), (2, 2, 1), (3, 3, 1), 
(4, 4, 2), (5, 5, 2), (6, 6, 2),
(7, 7, 3), (8, 8, 3), 
(9, 9, 4), (10, 10, 5)

insert into TIPOS_EXAMENES(id_tipo_examen, descripcion) values
(1, 'Parcial'),
(2, 'Recuperatorio'),
(3, 'Final')

ALTER TABLE EXAMENES ALTER COLUMN nota int

insert into EXAMENES (id_examen, id_materia, id_profesor, id_alumno, id_tipo_examen, nota, fecha) VALUES
(1, 1, 1, 1, 1, 6, '2024/08/10'),
(1, 1, 1, 2, 1, 5, '2024/08/10'),
(1, 1, 1, 3, 1, 8, '2024/08/10'),
(1, 1, 1, 4, 1, 8, '2024/08/10'),
(1, 1, 1, 5, 1, 10, '2024/08/10'),
(1, 1, 1, 6, 1, 2, '2024/08/10'),
(1, 1, 1, 7, 1, 4, '2024/08/10'),
(1, 1, 1, 8, 1, 10, '2024/08/10'),
(1, 1, 1, 9, 1, 7, '2024/08/10')

--------------------------------------------------------------------

insert into INSCRIPCIONES(id_inscripcion, id_comision, id_materia_carrera, id_alumno, horario_entrada, horario_salida, fecha_inscripcion, id_estado) values
(1, 1, 1, 1, '08:00:00', '12:00:00', '2024-03-01', 1),
(2, 1, 2, 2, '08:00:00', '12:00:00', '2024-03-01', 2),
(3, 2, 3, 3, '09:00:00', '13:00:00', '2024-03-02', 2),
(4, 2, 4, 4, '09:00:00', '13:00:00', '2024-03-02', 2),
(5, 2, 5, 5, '09:00:00', '13:00:00', '2024-03-02', 2),
(6, 3, 6, 6, '10:00:00', '14:00:00', '2024-03-03', 3),
(7, 3, 7, 7, '10:00:00', '14:00:00', '2024-03-03', 3),
(8, 4, 8, 8, '08:30:00', '12:30:00', '2024-03-04', 2),
(9, 4, 9, 9, '08:30:00', '12:30:00', '2024-03-04', 3),
(10, 4, 10, 10, '08:30:00', '12:30:00', '2024-03-04', 2),
(11, 5, 1, 11, '11:00:00', '15:00:00', '2024-03-05', 3),
(12, 5, 2, 12, '11:00:00', '15:00:00', '2024-03-05', 3),
(13, 1, 3, 13, '08:00:00', '12:00:00', '2024-03-06', 1),
(14, 1, 4, 14, '08:00:00', '12:00:00', '2024-03-06', 1),
(15, 2, 5, 15, '09:00:00', '13:00:00', '2024-03-07', 2),
(16, 2, 6, 16, '09:00:00', '13:00:00', '2024-03-07', 2),
(17, 3, 7, 17, '10:00:00', '14:00:00', '2024-03-08', 2),
(18, 3, 8, 18, '10:00:00', '14:00:00', '2024-03-08', 2),
(19, 4, 9, 19, '08:30:00', '12:30:00', '2024-03-09', 2),
(20, 4, 10, 20, '08:30:00', '12:30:00', '2024-03-09', 2),
(21, 5, 1, 21, '11:00:00', '15:00:00', '2024-03-10', 3),
(22, 5, 2, 22, '11:00:00', '15:00:00', '2024-03-10', 3),
(23, 1, 3, 23, '08:00:00', '12:00:00', '2024-03-11', 1),
(24, 1, 4, 24, '08:00:00', '12:00:00', '2024-03-11', 1),
(25, 2, 5, 25, '09:00:00', '13:00:00', '2024-03-12', 2),
(26, 2, 6, 26, '09:00:00', '13:00:00', '2024-03-12', 2),
(27, 3, 7, 27, '10:00:00', '14:00:00', '2024-03-13', 2),
(28, 3, 8, 28, '10:00:00', '14:00:00', '2024-03-13', 2),
(29, 4, 9, 29, '08:30:00', '12:30:00', '2024-03-14', 2),
(30, 4, 10, 30, '08:30:00', '12:30:00', '2024-03-14', 2),
(31, 5, 1, 31, '10:30:00', '13:30:00', '2024-03-15', 1),
(32, 5, 2, 32, '11:15:00', '14:15:00', '2024-03-16', 2),
(33, 5, 3, 33, '09:45:00', '12:45:00', '2024-03-17', 3),
(34, 4, 4, 34, '08:50:00', '11:50:00', '2024-03-18', 1),
(35, 4, 5, 35, '09:00:00', '12:00:00', '2024-03-19', 2),
(36, 3, 6, 36, '11:00:00', '14:00:00', '2024-03-20', 3),
(37, 3, 7, 37, '10:15:00', '13:15:00', '2024-03-21', 2),
(38, 2, 8, 38, '09:30:00', '12:30:00', '2024-03-22', 1),
(39, 2, 9, 39, '10:45:00', '13:45:00', '2024-03-23', 3),
(40, 1, 10, 40, '08:15:00', '11:15:00', '2024-03-24', 2),
(41, 1, 1, 41, '08:00:00', '12:00:00', '2024-03-25', 1),
(42, 2, 2, 42, '09:30:00', '13:30:00', '2024-03-26', 2),
(43, 3, 3, 43, '10:00:00', '14:00:00', '2024-03-27', 3),
(44, 4, 4, 44, '11:30:00', '15:30:00', '2024-03-28', 1),
(45, 5, 5, 45, '08:45:00', '12:45:00', '2024-03-29', 2),
(46, 1, 6, 46, '09:15:00', '13:15:00', '2024-03-30', 3),
(47, 1, 7, 47, '08:00:00', '11:00:00', '2024-04-01', 1),
(48, 2, 8, 48, '10:30:00', '13:30:00', '2024-04-02', 2),
(49, 3, 9, 49, '11:00:00', '14:00:00', '2024-04-03', 3),
(50, 4, 10, 50, '09:30:00', '12:30:00', '2024-04-04', 1),
(51, 5, 1, 51, '10:00:00', '13:00:00', '2024-04-05', 2),
(52, 5, 2, 52, '11:15:00', '14:15:00', '2024-04-06', 3),
(53, 4, 3, 53, '09:45:00', '12:45:00', '2024-04-07', 1),
(54, 3, 4, 54, '08:50:00', '11:50:00', '2024-04-08', 2),
(55, 2, 5, 55, '10:00:00', '13:00:00', '2024-04-09', 3),
(56, 1, 6, 56, '11:30:00', '14:30:00', '2024-04-10', 1),
(57, 1, 7, 57, '08:15:00', '11:15:00', '2024-04-11', 2),
(58, 2, 8, 58, '09:30:00', '12:30:00', '2024-04-12', 3),
(59, 3, 9, 59, '10:45:00', '13:45:00', '2024-04-13', 1),
(60, 4, 10, 60, '08:00:00', '11:00:00', '2024-04-14', 2);


insert into ASISTENCIAS(id_asistencia, id_alumno, id_materia_carrera, id_comision, presente, fecha) values
(1, 1, 1, 1, 1, '2024-01-10'),
(2, 1, 1, 1, 1, '2024-02-12'),
(3, 1, 1, 1, 0, '2024-03-05'),

(4, 2, 2, 1, 1, '2024-01-08'),
(5, 2, 2, 1, 1, '2024-02-03'),
(6, 2, 2, 1, 1, '2024-03-15'),

(7, 3, 3, 2, 1, '2024-01-18'),
(8, 3, 3, 2, 0, '2024-02-22'),
(9, 3, 3, 2, 1, '2024-03-10'),

(10, 4, 4, 2, 1, '2024-01-23'),
(11, 4, 4, 2, 1, '2024-02-11'),
(12, 4, 4, 2, 1, '2024-03-17'),

(13, 5, 5, 3, 1, '2024-01-05'),
(14, 5, 5, 3, 0, '2024-02-09'),
(15, 5, 5, 3, 1, '2024-03-12'),

(16, 6, 6, 3, 1, '2024-01-15'),
(17, 6, 6, 3, 1, '2024-02-17'),
(18, 6, 6, 3, 1, '2024-03-09'),

(19, 7, 7, 4, 1, '2024-01-22'),
(20, 7, 7, 4, 0, '2024-02-25'),
(21, 7, 7, 4, 1, '2024-03-02'),

(22, 8, 8, 4, 1, '2024-01-30'),
(23, 8, 8, 4, 1, '2024-02-10'),
(24, 8, 8, 4, 0, '2024-03-07'),

(25, 9, 9, 5, 1, '2024-01-03'),
(26, 9, 9, 5, 1, '2024-02-21'),
(27, 9, 9, 5, 1, '2024-03-22'),

(28, 10, 10, 5, 1, '2024-01-12'),
(29, 10, 10, 5, 1, '2024-02-08'),
(30, 10, 10, 5, 1, '2024-03-19'),

(31, 11, 1, 1, 1, '2024-01-25'),
(32, 11, 1, 1, 0, '2024-02-01'),
(33, 11, 1, 1, 1, '2024-03-14'),

(34, 12, 2, 1, 1, '2024-01-29'),
(35, 12, 2, 1, 1, '2024-02-18'),
(36, 12, 2, 1, 1, '2024-03-04'),

(37, 13, 3, 2, 1, '2024-01-06'),
(38, 13, 3, 2, 1, '2024-02-14'),
(39, 13, 3, 2, 0, '2024-03-11'),

(40, 14, 4, 2, 1, '2024-01-17'),
(41, 14, 4, 2, 1, '2024-02-06'),
(42, 14, 4, 2, 0, '2024-03-01'),

(43, 15, 5, 3, 1, '2024-01-09'),
(44, 15, 5, 3, 1, '2024-02-02'),
(45, 15, 5, 3, 1, '2024-03-23'),

(46, 16, 6, 3, 1, '2024-01-11'),
(47, 16, 6, 3, 1, '2024-02-05'),
(48, 16, 6, 3, 0, '2024-03-08'),

(49, 17, 7, 4, 1, '2024-01-19'),
(50, 17, 7, 4, 0, '2024-02-07'),
(51, 17, 7, 4, 1, '2024-03-03'),

(52, 18, 8, 4, 1, '2024-01-27'),
(53, 18, 8, 4, 1, '2024-02-15'),
(54, 18, 8, 4, 1, '2024-03-25'),

(55, 19, 9, 5, 1, '2024-01-21'),
(56, 19, 9, 5, 1, '2024-02-19'),
(57, 19, 9, 5, 1, '2024-03-27'),

(58, 20, 10, 5, 1, '2024-01-04'),
(59, 20, 10, 5, 1, '2024-02-12'),
(60, 20, 10, 5, 0, '2024-03-06'),

(61, 21, 1, 1, 1, '2024-02-15'),
(62, 21, 1, 1, 1, '2024-02-28'),
(63, 21, 1, 1, 0, '2024-03-10'),

(64, 22, 2, 1, 1, '2024-01-12'),
(65, 22, 2, 1, 1, '2024-03-01'),
(66, 22, 2, 1, 1, '2024-03-14'),

(67, 23, 3, 2, 1, '2024-01-18'),
(68, 23, 3, 2, 0, '2024-02-22'),
(69, 23, 3, 2, 1, '2024-03-20'),

(70, 24, 4, 2, 1, '2024-01-25'),
(71, 24, 4, 2, 1, '2024-02-10'),
(72, 24, 4, 2, 1, '2024-03-05'),

(73, 25, 5, 3, 1, '2024-01-07'),
(74, 25, 5, 3, 0, '2024-02-13'),
(75, 25, 5, 3, 0, '2024-03-17'),

(76, 26, 6, 3, 1, '2024-01-21'),
(77, 26, 6, 3, 1, '2024-02-07'),
(78, 26, 6, 3, 1, '2024-03-12'),

(79, 27, 7, 4, 1, '2024-01-08'),
(80, 27, 7, 4, 0, '2024-02-03'),
(81, 27, 7, 4, 1, '2024-03-19'),

(82, 28, 8, 4, 1, '2024-01-15'),
(83, 28, 8, 4, 1, '2024-02-12'),
(84, 28, 8, 4, 0, '2024-03-28'),

(85, 29, 9, 5, 1, '2024-01-09'),
(86, 29, 9, 5, 1, '2024-02-06'),
(87, 29, 9, 5, 0, '2024-03-15'),

(88, 30, 10, 5, 1, '2024-01-11'),
(89, 30, 10, 5, 1, '2024-02-19'),
(90, 30, 10, 5, 1, '2024-03-23'),

(91, 31, 1, 1, 1, '2024-01-20'),
(92, 31, 1, 1, 0, '2024-02-15'),
(93, 31, 1, 1, 1, '2024-03-18'),

(94, 32, 2, 1, 1, '2024-01-22'),
(95, 32, 2, 1, 1, '2024-02-20'),
(96, 32, 2, 1, 0, '2024-03-10'),

(97, 1, 3, 2, 1, '2024-01-29'),
(98, 1, 3, 2, 0, '2024-02-16'),
(99, 1, 3, 2, 1, '2024-03-08'),

(100, 2, 4, 2, 1, '2024-01-19'),
(101, 2, 4, 2, 1, '2024-02-18'),
(102, 2, 4, 2, 0, '2024-03-15'),

(103, 3, 5, 3, 1, '2024-01-11'),
(104, 3, 5, 3, 1, '2024-02-14'),
(105, 3, 5, 3, 1, '2024-03-20'),

(106, 4, 6, 3, 0, '2024-01-16'),
(107, 4, 6, 3, 1, '2024-02-17'),
(108, 4, 6, 3, 1, '2024-03-25'),

(109, 5, 7, 4, 1, '2024-01-24'),
(110, 5, 7, 4, 0, '2024-02-04'),
(111, 5, 7, 4, 1, '2024-03-14'),

(112, 6, 8, 4, 1, '2024-01-27'),
(113, 6, 8, 4, 1, '2024-02-20'),
(114, 6, 8, 4, 0, '2024-03-22'),

(115, 7, 9, 5, 1, '2024-01-30'),
(116, 7, 9, 5, 1, '2024-02-13'),
(117, 7, 9, 5, 1, '2024-03-24'),

(118, 8, 10, 5, 1, '2024-01-18'),
(119, 8, 10, 5, 1, '2024-02-09'),
(120, 8, 10, 5, 1, '2024-03-28'),

(121, 8, 1, 1, 1, '2024-01-25'),
(122, 8, 1, 1, 0, '2024-02-11'),
(123, 8, 1, 1, 1, '2024-03-30'),

(124, 9, 2, 1, 1, '2024-01-28'),
(125, 9, 2, 1, 1, '2024-02-27'),
(126, 9, 2, 1, 0, '2024-03-16'),

(127, 10, 3, 2, 1, '2024-01-14'),
(128, 10, 3, 2, 1, '2024-02-22'),
(129, 10, 3, 2, 1, '2024-03-21'),

(130, 11, 4, 2, 1, '2024-01-12'),
(131, 11, 4, 2, 1, '2024-02-02'),
(132, 11, 4, 2, 0, '2024-03-19'),

(133, 12, 5, 3, 1, '2024-01-31'),
(134, 12, 5, 3, 1, '2024-02-07'),
(135, 12, 5, 3, 1, '2024-03-29');

--------------------------------------------------------------

INSERT INTO EXAMENES (id_examen, id_materia_carrera, id_profesor, id_alumno, id_tipo_examen, id_comision, nota, fecha)
VALUES
-- Primer conjunto de 30 registros
(1, 1, 1, 1, 1, 1, 8.50, '2021-03-10'),
(2, 2, 2, 2, 2, 2, 7.25, '2022-05-20'),
(3, 3, 3, 3, 1, 3, 9.00, '2023-06-15'),
(4, 4, 4, 4, 2, 4, 6.75, '2023-07-10'),
(5, 5, 5, 5, 1, 5, 8.00, '2024-01-05'),
(6, 6, 6, 6, 2, 1, 5.50, '2024-02-28'),
(7, 7, 7, 7, 1, 2, 7.90, '2022-08-15'),
(8, 8, 8, 8, 2, 3, 6.50, '2023-09-18'),
(9, 9, 9, 9, 1, 4, 9.50, '2021-12-25'),
(10, 1, 10, 10, 1, 5, 7.60, '2022-11-12'),
(11, 2, 1, 11, 2, 1, 6.25, '2024-04-18'),
(12, 3, 2, 12, 2, 2, 5.40, '2023-02-10'),
(13, 4, 3, 13, 1, 3, 8.70, '2021-05-22'),
(14, 5, 4, 14, 1, 4, 9.20, '2024-03-10'),
(15, 6, 5, 15, 2, 5, 7.80, '2023-10-07'),
(16, 7, 6, 16, 2, 1, 6.00, '2024-05-25'),
(17, 8, 7, 17, 1, 2, 8.30, '2021-06-15'),
(18, 9, 8, 18, 1, 3, 5.90, '2023-08-22'),
(19, 10, 9, 19, 2, 4, 7.50, '2022-09-09'),
(20, 1, 10, 20, 2, 5, 8.10, '2024-07-10'),
(21, 2, 1, 21, 1, 1, 9.10, '2021-02-18'),
(22, 3, 2, 22, 1, 2, 8.50, '2022-10-30'),
(23, 4, 3, 23, 2, 3, 7.60, '2023-11-17'),
(24, 5, 4, 24, 2, 4, 6.80, '2023-01-11'),
(25, 6, 5, 25, 1, 5, 8.90, '2024-01-01'),
(26, 7, 6, 26, 1, 1, 7.10, '2022-06-30'),
(27, 8, 7, 27, 2, 2, 6.90, '2024-02-02'),
(28, 9, 8, 28, 2, 3, 9.40, '2022-07-15'),
(29, 10, 9, 29, 1, 4, 7.20, '2021-01-10'),
(30, 1, 10, 30, 1, 5, 8.80, '2024-05-18'),

-- Segundo conjunto de 30 registros adicionales
(31, 1, 1, 31, 1, 1, 8.60, '2020-11-10'),
(32, 2, 2, 32, 2, 2, 7.50, '2021-02-01'),
(33, 3, 3, 1, 1, 3, 9.10, '2022-04-22'),
(34, 4, 4, 2, 2, 4, 6.80, '2022-05-15'),
(35, 5, 5, 3, 1, 5, 8.00, '2023-03-08'),
(36, 6, 6, 4, 2, 1, 7.40, '2023-04-12'),
(37, 7, 7, 5, 1, 2, 9.00, '2024-01-30'),
(38, 8, 8, 6, 2, 3, 6.60, '2024-02-05'),
(39, 9, 9, 7, 1, 4, 8.90, '2021-06-20'),
(40, 10, 10, 8, 1, 5, 7.30, '2021-07-25'),
(41, 1, 1, 9, 2, 1, 5.80, '2023-08-19'),
(42, 2, 2, 10, 2, 2, 6.00, '2023-09-15'),
(43, 3, 3, 11, 1, 3, 8.50, '2022-07-10'),
(44, 4, 4, 12, 1, 4, 9.20, '2022-11-22'),
(45, 5, 5, 13, 2, 5, 7.60, '2024-03-13'),
(46, 6, 6, 14, 2, 1, 6.70, '2023-10-18'),
(47, 7, 7, 15, 1, 2, 8.40, '2022-08-30'),
(48, 8, 8, 16, 1, 3, 9.30, '2024-04-02'),
(49, 9, 9, 17, 2, 4, 7.10, '2024-05-09'),
(50, 10, 10, 18, 2, 5, 6.90, '2024-06-01'),
(51, 1, 1, 19, 1, 1, 8.80, '2023-03-25'),
(52, 2, 2, 20, 1, 2, 7.40, '2022-10-12'),
(53, 3, 3, 21, 2, 3, 5.70, '2023-12-03'),
(54, 4, 4, 22, 2, 4, 6.50, '2024-02-15'),
(55, 5, 5, 23, 1, 5, 9.00, '2021-04-18'),
(56, 6, 6, 24, 1, 1, 7.80, '2022-05-24'),
(57, 7, 7, 25, 2, 2, 6.40, '2023-06-05'),
(58, 8, 8, 26, 2, 3, 9.10, '2024-07-10'),
(59, 9, 9, 27, 1, 4, 8.50, '2023-04-22');