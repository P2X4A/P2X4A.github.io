-- SIGEVET - Consultas SQL de los 55 ejercicios de álgebra relacional (Fase 1)
-- MySQL 8.4, base de datos sigevet.
USE sigevet;

-- ======================================================================
-- Selección (σ) y proyección (π)
-- ======================================================================

-- Ejercicio 1. Servicios de vacunación
-- Listar el nombre y el precio de los servicios de la categoría VACUNACION.
SELECT nombre, precio
FROM SERVICIO
WHERE categoria = 'VACUNACION';

-- Ejercicio 2. Hembras esterilizadas activas
-- Obtener el identificador, el nombre y el color de las mascotas hembra, esterilizadas y activas.
SELECT id_mascota, nombre, color
FROM MASCOTA
WHERE sexo = 'H' AND esterilizado = 'S' AND estado = 'ACTIVA';

-- Ejercicio 3. Empleados con salario alto
-- Mostrar nombres, apellidos y salario de los empleados que ganan más de $5.000.000.
SELECT nombres, apellidos, salario
FROM EMPLEADO
WHERE salario > 5000000;

-- Ejercicio 4. Medicamentos con fórmula de bajo costo
-- Listar código, nombre y precio de los medicamentos que requieren fórmula y cuestan menos de $10.000.
SELECT codigo, nombre, precio_venta
FROM MEDICAMENTO
WHERE requiere_formula = 'S' AND precio_venta < 10000;

-- Ejercicio 5. Citas perdidas
-- Listar las citas canceladas o a las que el cliente no asistió.
SELECT id_cita, fecha_hora, estado
FROM CITA
WHERE estado = 'CANCELADA' OR estado = 'NO_ASISTIO';

-- Ejercicio 6. Razas de tamaño grande
-- Obtener el nombre de las razas cuyo tamaño típico es GRANDE.
SELECT nombre
FROM RAZA
WHERE tamano = 'GRANDE';

-- Ejercicio 7. Teléfonos fijos
-- Listar el cliente y el número de los teléfonos de tipo FIJO.
SELECT id_cliente, telefono
FROM TELEFONO_CLIENTE
WHERE tipo = 'FIJO';

-- Ejercicio 8. Clientes sin correo electrónico
-- Obtener los clientes que no tienen correo electrónico registrado (selección sobre valores nulos).
SELECT id_cliente, nombres, apellidos
FROM CLIENTE
WHERE email IS NULL;

-- Ejercicio 9. Consultas con fiebre
-- Listar las consultas en las que la temperatura fue igual o superior a 39,5 °C y su diagnóstico.
SELECT id_consulta, temperatura_c, diagnostico
FROM CONSULTA
WHERE temperatura_c >= 39.5;

-- Ejercicio 10. Categorías de servicio
-- Obtener las categorías de servicio existentes. La proyección del álgebra elimina duplicados; en SQL se requiere DISTINCT.
SELECT DISTINCT categoria
FROM SERVICIO;

-- Ejercicio 11. Agenda futura
-- Listar las citas programadas desde el 9 de octubre de 2026 (selección por fecha).
SELECT id_cita, fecha_hora, id_veterinario, id_sede
FROM CITA
WHERE estado = 'PROGRAMADA' AND fecha_hora >= DATE '2026-10-09';

-- Ejercicio 12. Inventario bajo el mínimo
-- Encontrar los registros de inventario cuyo stock actual es menor que el stock mínimo (comparación entre dos atributos de la misma tupla).
SELECT id_sede, id_medicamento, stock_actual, stock_minimo
FROM INVENTARIO
WHERE stock_actual < stock_minimo;

-- ======================================================================
-- Producto cartesiano (×)
-- ======================================================================

-- Ejercicio 13. Tabla de precios de vacunación por especie
-- Generar todas las combinaciones entre especies y servicios de vacunación para construir una tabla de precios (producto cartesiano).
SELECT e.id_especie, e.nombre AS especie, s.nombre AS servicio, s.precio
FROM ESPECIE e CROSS JOIN SERVICIO s
WHERE s.categoria = 'VACUNACION';

-- Ejercicio 14. Razas felinas mediante producto y selección
-- Obtener el nombre de cada raza felina junto al nombre de su especie, usando producto cartesiano seguido de selección (equivalente a una reunión).
SELECT r.nombre AS raza, e.nombre AS especie
FROM RAZA r, ESPECIE e
WHERE r.id_especie = e.id_especie AND e.nombre = 'Felino';

-- ======================================================================
-- Renombramiento (ρ)
-- ======================================================================

-- Ejercicio 15. Veterinarios graduados el mismo año
-- Encontrar las parejas de veterinarios que se graduaron el mismo año. Se necesita renombrar la relación para compararla consigo misma.
SELECT v1.id_empleado AS veterinario_1, v2.id_empleado AS veterinario_2, v1.anio_graduacion
FROM VETERINARIO v1 JOIN VETERINARIO v2
  ON v1.anio_graduacion = v2.anio_graduacion AND v1.id_empleado < v2.id_empleado;

-- Ejercicio 16. Ciudades con su departamento
-- Listar cada ciudad con el nombre de su departamento. Ambas relaciones tienen un atributo «nombre», por lo que se renombran los atributos antes de la reunión natural.
SELECT c.id_ciudad, c.nombre AS ciudad, d.nombre AS departamento
FROM CIUDAD c JOIN DEPARTAMENTO d USING (id_departamento);

-- ======================================================================
-- Reunión natural y reunión theta (⋈)
-- ======================================================================

-- Ejercicio 17. Datos completos de los veterinarios
-- Mostrar nombres, apellidos, tarjeta profesional y universidad de los veterinarios (reunión natural entre el subtipo y el supertipo por id_empleado).
SELECT nombres, apellidos, tarjeta_profesional, universidad
FROM VETERINARIO NATURAL JOIN EMPLEADO;

-- Ejercicio 18. Existencias de la sede Usaquén
-- Listar los medicamentos que maneja la sede 1 (Usaquén) con su presentación y stock actual.
SELECT nombre, presentacion, stock_actual
FROM (SELECT * FROM INVENTARIO WHERE id_sede = 1) i NATURAL JOIN MEDICAMENTO;

-- Ejercicio 19. Mascotas con alergias
-- Obtener el nombre de la mascota, el número de historia clínica y las alergias registradas.
SELECT m.nombre, h.numero_historia, h.alergias
FROM HISTORIA_CLINICA h JOIN MASCOTA m ON m.id_mascota = h.id_mascota
WHERE h.alergias IS NOT NULL;

-- Ejercicio 20. Gatos y sus propietarios
-- Listar las mascotas felinas con su raza y el nombre de su propietario (reunión de tres relaciones).
SELECT m.nombre AS mascota, r.nombre AS raza, c.nombres, c.apellidos
FROM MASCOTA m
  JOIN RAZA r ON r.id_raza = m.id_raza
  JOIN CLIENTE c ON c.id_cliente = m.id_cliente
WHERE r.id_especie = 2;

-- Ejercicio 21. Sedes, ubicación y director
-- Mostrar cada sede con su ciudad, su departamento y el nombre de su director (reunión por la llave foránea de rol id_director).
SELECT s.nombre AS sede, c.nombre AS ciudad, d.nombre AS departamento, e.nombres, e.apellidos
FROM SEDE s
  JOIN CIUDAD c ON c.id_ciudad = s.id_ciudad
  JOIN DEPARTAMENTO d ON d.id_departamento = c.id_departamento
  JOIN EMPLEADO e ON e.id_empleado = s.id_director;

-- Ejercicio 22. Especialidades de cada veterinario
-- Listar los veterinarios con cada especialidad certificada y su fecha (reunión a través de la tabla de la relación N:M).
SELECT e.nombres, e.apellidos, es.nombre AS especialidad, ve.fecha_certificacion
FROM EMPLEADO e
  JOIN VETERINARIO_ESPECIALIDAD ve ON ve.id_empleado = e.id_empleado
  JOIN ESPECIALIDAD es ON es.id_especialidad = ve.id_especialidad;

-- Ejercicio 23. Fórmula médica de una consulta
-- Mostrar los medicamentos formulados en la consulta 4 con dosis, frecuencia y duración.
SELECT m.nombre, m.presentacion, p.dosis, p.frecuencia_horas, p.duracion_dias
FROM PRESCRIPCION p JOIN MEDICAMENTO m ON m.id_medicamento = p.id_medicamento
WHERE p.id_consulta = 4;

-- Ejercicio 24. Historia clínica de una mascota
-- Reconstruir la historia de atenciones de la mascota 17: fecha de la consulta, veterinario y diagnóstico, en cualquier sede.
SELECT k.fecha_hora_inicio, ci.id_sede, e.nombres, e.apellidos, k.diagnostico
FROM CONSULTA k
  JOIN CITA ci ON ci.id_cita = k.id_cita
  JOIN EMPLEADO e ON e.id_empleado = ci.id_veterinario
WHERE ci.id_mascota = 17
ORDER BY k.fecha_hora_inicio;

-- Ejercicio 25. Citas atendidas en la sede Chía
-- Listar las citas atendidas en la sede 3 (Chía) con el nombre de la mascota y el apellido del veterinario.
SELECT ci.id_cita, ci.fecha_hora, m.nombre AS mascota, e.apellidos AS veterinario
FROM CITA ci
  JOIN MASCOTA m ON m.id_mascota = ci.id_mascota
  JOIN EMPLEADO e ON e.id_empleado = ci.id_veterinario
WHERE ci.id_sede = 3 AND ci.estado = 'ATENDIDA'
ORDER BY ci.fecha_hora;

-- ======================================================================
-- Reuniones externas (⟕, ⟖, ⟗)
-- ======================================================================

-- Ejercicio 26. Clientes sin mascotas
-- Encontrar los clientes que no tienen mascotas, usando una reunión externa izquierda y seleccionando las tuplas completadas con nulos.
SELECT c.id_cliente, c.nombres, c.apellidos
FROM CLIENTE c LEFT OUTER JOIN MASCOTA m ON m.id_cliente = c.id_cliente
WHERE m.id_mascota IS NULL;

-- Ejercicio 27. Especialidades con o sin veterinarios
-- Listar todas las especialidades con los veterinarios certificados; las especialidades sin veterinarios deben aparecer con nulos.
SELECT es.nombre AS especialidad, ve.id_empleado
FROM ESPECIALIDAD es
  LEFT OUTER JOIN VETERINARIO_ESPECIALIDAD ve ON ve.id_especialidad = es.id_especialidad
ORDER BY es.nombre;

-- Ejercicio 28. Todas las citas de una mascota, con o sin consulta
-- Para la mascota 17, listar todas sus citas y, cuando exista, la consulta que generaron (reunión externa derecha: se conservan todas las citas).
SELECT ci.id_cita, ci.estado, k.id_consulta, k.diagnostico
FROM CONSULTA k
  RIGHT OUTER JOIN (SELECT * FROM CITA WHERE id_mascota = 17) ci ON ci.id_cita = k.id_cita
ORDER BY ci.id_cita;

-- Ejercicio 29. Comparación de inventarios entre sedes
-- Comparar el inventario de la sede 1 (Usaquén) y la sede 3 (Chía) por medicamento, mostrando también los medicamentos que solo maneja una de las dos (reunión externa completa).
SELECT a.id_medicamento AS med_usaquen, a.stock_actual AS stock_usaquen,
       b.id_medicamento AS med_chia, b.stock_actual AS stock_chia
FROM (SELECT * FROM INVENTARIO WHERE id_sede = 1) a
  LEFT JOIN (SELECT * FROM INVENTARIO WHERE id_sede = 3) b ON a.id_medicamento = b.id_medicamento
UNION
SELECT a.id_medicamento, a.stock_actual, b.id_medicamento, b.stock_actual
FROM (SELECT * FROM INVENTARIO WHERE id_sede = 1) a
  RIGHT JOIN (SELECT * FROM INVENTARIO WHERE id_sede = 3) b ON a.id_medicamento = b.id_medicamento
ORDER BY COALESCE(med_usaquen, med_chia);

-- ======================================================================
-- Semirreunión (⋉) y antirreunión (▷)
-- ======================================================================

-- Ejercicio 30. Clientes con facturas anuladas
-- Obtener los clientes que tienen al menos una factura anulada. La semirreunión conserva solo los atributos de CLIENTE.
SELECT c.id_cliente, c.nombres, c.apellidos
FROM CLIENTE c
WHERE EXISTS (SELECT 1 FROM FACTURA f WHERE f.id_cliente = c.id_cliente AND f.estado = 'ANULADA');

-- Ejercicio 31. Mascotas sin atenciones
-- Listar las mascotas activas que nunca han tenido una cita atendida (antirreunión).
SELECT m.id_mascota, m.nombre
FROM MASCOTA m
WHERE m.estado = 'ACTIVA'
  AND NOT EXISTS (SELECT 1 FROM CITA ci WHERE ci.id_mascota = m.id_mascota AND ci.estado = 'ATENDIDA');

-- Ejercicio 32. Veterinarios que atendieron urgencias
-- Obtener los veterinarios que tienen al menos una cita del servicio de urgencias (servicio 3), sin repetir veterinarios ni mostrar atributos de la cita (semirreunión).
SELECT e.id_empleado, e.nombres, e.apellidos
FROM EMPLEADO e
WHERE EXISTS (SELECT 1 FROM CITA ci WHERE ci.id_veterinario = e.id_empleado AND ci.id_servicio = 3);

-- ======================================================================
-- Operaciones de conjuntos (∪, ∩, −)
-- ======================================================================

-- Ejercicio 33. Personas registradas en Chía
-- Obtener nombres y apellidos de las personas relacionadas con Chía: clientes que viven allí o empleados de la sede Chía (unión de relaciones compatibles).
SELECT nombres, apellidos FROM CLIENTE WHERE id_ciudad = 2
UNION
SELECT nombres, apellidos FROM EMPLEADO WHERE id_sede = 3;

-- Ejercicio 34. Mascotas vacunadas u operadas
-- Listar las mascotas que han tenido cita de vacunación o de cirugía.
SELECT m.id_mascota, m.nombre
FROM MASCOTA m
WHERE m.id_mascota IN (
  SELECT ci.id_mascota FROM CITA ci JOIN SERVICIO s ON s.id_servicio = ci.id_servicio WHERE s.categoria = 'VACUNACION'
  UNION
  SELECT ci.id_mascota FROM CITA ci JOIN SERVICIO s ON s.id_servicio = ci.id_servicio WHERE s.categoria = 'CIRUGIA')
ORDER BY m.id_mascota;

-- Ejercicio 35. Medicamentos comunes a dos sedes
-- Encontrar los medicamentos que maneja la sede 1 (Usaquén) y también la sede 4 (Laureles).
SELECT m.id_medicamento, m.nombre
FROM MEDICAMENTO m
WHERE m.id_medicamento IN (
  SELECT id_medicamento FROM INVENTARIO WHERE id_sede = 1
  INTERSECT
  SELECT id_medicamento FROM INVENTARIO WHERE id_sede = 4)
ORDER BY m.id_medicamento;

-- Ejercicio 36. Clientes con perro y gato
-- Obtener los clientes que tienen al menos un canino y al menos un felino.
SELECT c.id_cliente, c.nombres, c.apellidos
FROM CLIENTE c
WHERE c.id_cliente IN (
  SELECT m.id_cliente FROM MASCOTA m JOIN RAZA r ON r.id_raza = m.id_raza WHERE r.id_especie = 1
  INTERSECT
  SELECT m.id_cliente FROM MASCOTA m JOIN RAZA r ON r.id_raza = m.id_raza WHERE r.id_especie = 2);

-- Ejercicio 37. Medicamentos nunca formulados
-- Listar los medicamentos del catálogo que nunca se han formulado (diferencia).
SELECT m.id_medicamento, m.nombre, m.presentacion
FROM MEDICAMENTO m
WHERE m.id_medicamento IN (
  SELECT id_medicamento FROM MEDICAMENTO
  EXCEPT
  SELECT id_medicamento FROM PRESCRIPCION);

-- Ejercicio 38. Veterinarios sin especialidad
-- Obtener los veterinarios que no tienen ninguna especialidad certificada.
SELECT e.id_empleado, e.nombres, e.apellidos
FROM EMPLEADO e
WHERE e.id_empleado IN (
  SELECT id_empleado FROM VETERINARIO
  EXCEPT
  SELECT id_empleado FROM VETERINARIO_ESPECIALIDAD);

-- Ejercicio 39. Medicamentos que no maneja la sede Chía
-- Listar los medicamentos del catálogo que no están en el inventario de la sede 3 (Chía).
SELECT id_medicamento, nombre
FROM MEDICAMENTO
WHERE id_medicamento NOT IN (
  SELECT id_medicamento FROM INVENTARIO WHERE id_sede = 3);

-- Ejercicio 40. Clientes de mostrador
-- Encontrar los clientes que tienen facturas pero no tienen mascotas registradas (compras de mostrador).
SELECT c.id_cliente, c.nombres, c.apellidos
FROM CLIENTE c
WHERE c.id_cliente IN (
  SELECT id_cliente FROM FACTURA
  EXCEPT
  SELECT id_cliente FROM MASCOTA);

-- ======================================================================
-- División (÷)
-- ======================================================================

-- Ejercicio 41. Medicamentos disponibles en todas las sedes
-- Encontrar los medicamentos que están en el inventario de todas las sedes.
SELECT m.id_medicamento, m.nombre
FROM MEDICAMENTO m
WHERE NOT EXISTS (
  SELECT s.id_sede FROM SEDE s
  WHERE NOT EXISTS (
    SELECT 1 FROM INVENTARIO i WHERE i.id_sede = s.id_sede AND i.id_medicamento = m.id_medicamento));

-- Ejercicio 42. Veterinarios con un conjunto de especialidades
-- Encontrar los veterinarios certificados en todas las especialidades del conjunto {Medicina interna, Medicina felina}.
SELECT e.id_empleado, e.nombres, e.apellidos
FROM EMPLEADO e
WHERE e.id_empleado IN (SELECT id_empleado FROM VETERINARIO)
  AND NOT EXISTS (
    SELECT es.id_especialidad FROM ESPECIALIDAD es
    WHERE es.nombre IN ('Medicina interna', 'Medicina felina')
      AND NOT EXISTS (
        SELECT 1 FROM VETERINARIO_ESPECIALIDAD ve
        WHERE ve.id_empleado = e.id_empleado AND ve.id_especialidad = es.id_especialidad));

-- Ejercicio 43. Clientes atendidos en todas las sedes de Bogotá
-- Encontrar los clientes que tienen facturas en todas las sedes ubicadas en Bogotá D.C.
SELECT c.id_cliente, c.nombres, c.apellidos
FROM CLIENTE c
WHERE NOT EXISTS (
  SELECT s.id_sede FROM SEDE s WHERE s.id_ciudad = 1
  AND NOT EXISTS (
    SELECT 1 FROM FACTURA f WHERE f.id_cliente = c.id_cliente AND f.id_sede = s.id_sede));

-- ======================================================================
-- Agregación y agrupamiento (γ)
-- ======================================================================

-- Ejercicio 44. Mascotas por especie
-- Contar cuántas mascotas hay de cada especie.
SELECT e.nombre AS especie, COUNT(m.id_mascota) AS total
FROM MASCOTA m
  JOIN RAZA r ON r.id_raza = m.id_raza
  JOIN ESPECIE e ON e.id_especie = r.id_especie
GROUP BY e.nombre
ORDER BY total DESC;

-- Ejercicio 45. Citas por estado
-- Obtener el número de citas en cada estado.
SELECT estado, COUNT(id_cita) AS cantidad
FROM CITA
GROUP BY estado
ORDER BY cantidad DESC;

-- Ejercicio 46. Ingresos por sede
-- Calcular los ingresos de cada sede a partir de las facturas pagadas. El valor de cada línea es un atributo calculado (proyección generalizada).
SELECT s.nombre AS sede,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento_pct / 100.0)), 2) AS ingresos
FROM FACTURA f
  JOIN DETALLE_FACTURA d ON d.id_factura = f.id_factura
  JOIN SEDE s ON s.id_sede = f.id_sede
WHERE f.estado = 'PAGADA'
GROUP BY s.nombre
ORDER BY ingresos DESC;

-- Ejercicio 47. Salarios por tipo de empleado
-- Calcular el salario promedio, mínimo y máximo por tipo de empleado.
SELECT tipo_empleado, ROUND(AVG(salario), 0) AS promedio, MIN(salario) AS minimo, MAX(salario) AS maximo
FROM EMPLEADO
GROUP BY tipo_empleado
ORDER BY tipo_empleado;

-- Ejercicio 48. Veterinario con más citas atendidas
-- Encontrar el o los veterinarios con el mayor número de citas atendidas (agregación seguida de selección con el máximo).
SELECT e.nombres, e.apellidos, COUNT(ci.id_cita) AS atendidas
FROM CITA ci JOIN EMPLEADO e ON e.id_empleado = ci.id_veterinario
WHERE ci.estado = 'ATENDIDA'
GROUP BY e.id_empleado, e.nombres, e.apellidos
HAVING COUNT(ci.id_cita) = (
  SELECT MAX(n) FROM (SELECT COUNT(*) AS n FROM CITA WHERE estado = 'ATENDIDA' GROUP BY id_veterinario) t);

-- Ejercicio 49. Medicamentos más formulados
-- Obtener las unidades formuladas de cada medicamento, de mayor a menor (se muestran los 5 primeros).
SELECT m.nombre, SUM(p.cantidad) AS unidades
FROM PRESCRIPCION p JOIN MEDICAMENTO m ON m.id_medicamento = p.id_medicamento
GROUP BY m.nombre
ORDER BY unidades DESC
LIMIT 5;

-- Ejercicio 50. Clientes con más de dos mascotas
-- Listar los clientes que tienen más de dos mascotas registradas (selección sobre un resultado agregado).
SELECT c.id_cliente, c.nombres, c.apellidos, COUNT(m.id_mascota) AS mascotas
FROM CLIENTE c JOIN MASCOTA m ON m.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombres, c.apellidos
HAVING COUNT(m.id_mascota) > 2;

-- Ejercicio 51. Facturación mensual de 2026
-- Calcular el valor facturado (facturas pagadas) por mes durante 2026.
SELECT DATE_FORMAT(f.fecha_emision, '%Y-%m') AS mes,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento_pct / 100.0)), 2) AS facturado,
       COUNT(DISTINCT f.id_factura) AS facturas
FROM FACTURA f JOIN DETALLE_FACTURA d ON d.id_factura = f.id_factura
WHERE f.estado = 'PAGADA' AND EXTRACT(YEAR FROM f.fecha_emision) = 2026
GROUP BY DATE_FORMAT(f.fecha_emision, '%Y-%m')
ORDER BY mes;

-- Ejercicio 52. Valor del inventario por sede
-- Calcular el valor del inventario de cada sede (existencias × precio de venta).
SELECT s.nombre AS sede, SUM(i.stock_actual * m.precio_venta) AS valor_inventario
FROM INVENTARIO i
  JOIN MEDICAMENTO m ON m.id_medicamento = i.id_medicamento
  JOIN SEDE s ON s.id_sede = i.id_sede
GROUP BY s.nombre
ORDER BY valor_inventario DESC;

-- Ejercicio 53. Edad promedio por especie
-- Calcular la edad promedio (en años) de las mascotas activas por especie al 9 de octubre de 2026. La edad es un atributo derivado de fecha_nacimiento.
SELECT e.nombre AS especie, ROUND(AVG(DATEDIFF(DATE '2026-10-09', m.fecha_nacimiento) / 365.25), 1) AS edad_promedio
FROM MASCOTA m
  JOIN RAZA r ON r.id_raza = m.id_raza
  JOIN ESPECIE e ON e.id_especie = r.id_especie
WHERE m.estado = 'ACTIVA' AND m.fecha_nacimiento IS NOT NULL
GROUP BY e.nombre
ORDER BY edad_promedio DESC;

-- Ejercicio 54. Ticket promedio por medio de pago
-- Calcular el valor promedio de las facturas pagadas según el medio de pago.
SELECT metodo_pago, ROUND(AVG(total), 0) AS ticket_promedio, COUNT(*) AS facturas
FROM (
  SELECT f.id_factura, f.metodo_pago,
         SUM(d.cantidad * d.precio_unitario * (1 - d.descuento_pct / 100.0)) AS total
  FROM FACTURA f JOIN DETALLE_FACTURA d ON d.id_factura = f.id_factura
  WHERE f.estado = 'PAGADA'
  GROUP BY f.id_factura, f.metodo_pago) t
GROUP BY metodo_pago
ORDER BY ticket_promedio DESC;

-- Ejercicio 55. Servicios que más ingresos generan
-- Obtener los 5 servicios con mayores ingresos en facturas pagadas, con el número de veces que se cobraron.
SELECT s.nombre AS servicio, COUNT(*) AS veces,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento_pct / 100.0)), 2) AS ingresos
FROM FACTURA f
  JOIN DETALLE_FACTURA d ON d.id_factura = f.id_factura
  JOIN SERVICIO s ON s.id_servicio = d.id_servicio
WHERE f.estado = 'PAGADA'
GROUP BY s.nombre
ORDER BY ingresos DESC
LIMIT 5;
