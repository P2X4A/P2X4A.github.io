-- SIGEVET - Vistas
-- MySQL 8.4, base de datos sigevet (después de 01_crear_tablas.sql).
-- Las vistas calculan los atributos derivados del MER (total de factura, edad de la mascota)
-- y simplifican las consultas que más usa la aplicación web.
USE sigevet;

-- Total de cada factura (atributo derivado "total"; no se guarda para mantener 3FN).
CREATE OR REPLACE VIEW V_FACTURA_TOTAL AS
SELECT f.id_factura, f.numero_factura, f.fecha_emision, f.estado, f.metodo_pago,
       f.id_cliente, f.id_sede, f.id_empleado,
       ROUND(SUM(d.cantidad * d.precio_unitario * (1 - d.descuento_pct / 100)), 2) AS total
FROM FACTURA f
JOIN DETALLE_FACTURA d ON d.id_factura = f.id_factura
GROUP BY f.id_factura, f.numero_factura, f.fecha_emision, f.estado, f.metodo_pago,
         f.id_cliente, f.id_sede, f.id_empleado;

-- Edad de cada mascota en años cumplidos (atributo derivado "edad").
CREATE OR REPLACE VIEW V_MASCOTA_DETALLE AS
SELECT m.id_mascota, m.nombre, m.sexo, m.estado, m.fecha_nacimiento,
       TIMESTAMPDIFF(YEAR, m.fecha_nacimiento, CURDATE()) AS edad_anios,
       r.nombre AS raza, e.nombre AS especie,
       c.id_cliente, CONCAT(c.nombres, ' ', c.apellidos) AS propietario
FROM MASCOTA m
JOIN RAZA r    ON r.id_raza = m.id_raza
JOIN ESPECIE e ON e.id_especie = r.id_especie
JOIN CLIENTE c ON c.id_cliente = m.id_cliente;

-- Historial clínico: todas las consultas de cada mascota, en cualquier sede.
CREATE OR REPLACE VIEW V_HISTORIAL_CLINICO AS
SELECT h.numero_historia, m.id_mascota, m.nombre AS mascota, k.id_consulta, k.fecha_hora_inicio,
       s.nombre AS sede, CONCAT(e.nombres, ' ', e.apellidos) AS veterinario,
       k.peso_kg, k.temperatura_c, k.diagnostico
FROM CONSULTA k
JOIN CITA ci            ON ci.id_cita = k.id_cita
JOIN MASCOTA m          ON m.id_mascota = ci.id_mascota
JOIN HISTORIA_CLINICA h ON h.id_mascota = m.id_mascota
JOIN SEDE s             ON s.id_sede = ci.id_sede
JOIN EMPLEADO e         ON e.id_empleado = ci.id_veterinario;

-- Agenda de citas con los nombres de todos los participantes.
CREATE OR REPLACE VIEW V_AGENDA AS
SELECT ci.id_cita, ci.fecha_hora, ci.estado, s.nombre AS sede,
       CONCAT(e.nombres, ' ', e.apellidos) AS veterinario, m.nombre AS mascota,
       CONCAT(c.nombres, ' ', c.apellidos) AS cliente, sv.nombre AS servicio
FROM CITA ci
JOIN SEDE s      ON s.id_sede = ci.id_sede
JOIN EMPLEADO e  ON e.id_empleado = ci.id_veterinario
JOIN MASCOTA m   ON m.id_mascota = ci.id_mascota
JOIN CLIENTE c   ON c.id_cliente = m.id_cliente
JOIN SERVICIO sv ON sv.id_servicio = ci.id_servicio;

-- Medicamentos por debajo del punto de reorden en cada sede.
CREATE OR REPLACE VIEW V_STOCK_BAJO AS
SELECT s.nombre AS sede, md.codigo, md.nombre AS medicamento, i.stock_actual, i.stock_minimo,
       i.stock_minimo - i.stock_actual AS faltante
FROM INVENTARIO i
JOIN SEDE s         ON s.id_sede = i.id_sede
JOIN MEDICAMENTO md ON md.id_medicamento = i.id_medicamento
WHERE i.stock_actual < i.stock_minimo;

-- Ingresos mensuales por sede (solo facturas pagadas).
CREATE OR REPLACE VIEW V_INGRESOS_SEDE_MES AS
SELECT s.nombre AS sede, DATE_FORMAT(v.fecha_emision, '%Y-%m') AS mes,
       COUNT(*) AS facturas, SUM(v.total) AS ingresos
FROM V_FACTURA_TOTAL v
JOIN SEDE s ON s.id_sede = v.id_sede
WHERE v.estado = 'PAGADA'
GROUP BY s.nombre, DATE_FORMAT(v.fecha_emision, '%Y-%m');
