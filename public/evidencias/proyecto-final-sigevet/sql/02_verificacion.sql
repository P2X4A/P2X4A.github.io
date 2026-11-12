-- SIGEVET - Verificación de la instalación (se ejecuta como vetdb)
-- Muestra los objetos creados, las restricciones por tipo y los registros por tabla,
-- y prueba que las reglas de negocio rechazan datos incorrectos.
USE sigevet;

SELECT '== Objetos de la base sigevet' AS seccion;
SELECT 'TABLA' AS objeto, COUNT(*) AS cantidad FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'sigevet' AND TABLE_TYPE = 'BASE TABLE'
UNION ALL
SELECT 'VISTA', COUNT(*) FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'sigevet' AND TABLE_TYPE = 'VIEW'
UNION ALL
SELECT ROUTINE_TYPE, COUNT(*) FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA = 'sigevet' GROUP BY ROUTINE_TYPE
UNION ALL
SELECT 'DISPARADOR', COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'sigevet'
UNION ALL
SELECT 'INDICE', COUNT(DISTINCT TABLE_NAME, INDEX_NAME) FROM information_schema.STATISTICS
 WHERE TABLE_SCHEMA = 'sigevet';

SELECT '== Restricciones por tipo' AS seccion;
SELECT CONSTRAINT_TYPE AS tipo, COUNT(*) AS cantidad
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'sigevet'
GROUP BY CONSTRAINT_TYPE ORDER BY CONSTRAINT_TYPE;

SELECT '== Registros por tabla' AS seccion;
SELECT 'DEPARTAMENTO' AS tabla, COUNT(*) AS registros FROM DEPARTAMENTO
UNION ALL SELECT 'CIUDAD', COUNT(*) FROM CIUDAD
UNION ALL SELECT 'SEDE', COUNT(*) FROM SEDE
UNION ALL SELECT 'EMPLEADO', COUNT(*) FROM EMPLEADO
UNION ALL SELECT 'VETERINARIO', COUNT(*) FROM VETERINARIO
UNION ALL SELECT 'AUXILIAR', COUNT(*) FROM AUXILIAR
UNION ALL SELECT 'ESPECIALIDAD', COUNT(*) FROM ESPECIALIDAD
UNION ALL SELECT 'VETERINARIO_ESPECIALIDAD', COUNT(*) FROM VETERINARIO_ESPECIALIDAD
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL SELECT 'TELEFONO_CLIENTE', COUNT(*) FROM TELEFONO_CLIENTE
UNION ALL SELECT 'ESPECIE', COUNT(*) FROM ESPECIE
UNION ALL SELECT 'RAZA', COUNT(*) FROM RAZA
UNION ALL SELECT 'MASCOTA', COUNT(*) FROM MASCOTA
UNION ALL SELECT 'HISTORIA_CLINICA', COUNT(*) FROM HISTORIA_CLINICA
UNION ALL SELECT 'SERVICIO', COUNT(*) FROM SERVICIO
UNION ALL SELECT 'CITA', COUNT(*) FROM CITA
UNION ALL SELECT 'CONSULTA', COUNT(*) FROM CONSULTA
UNION ALL SELECT 'MEDICAMENTO', COUNT(*) FROM MEDICAMENTO
UNION ALL SELECT 'PRESCRIPCION', COUNT(*) FROM PRESCRIPCION
UNION ALL SELECT 'INVENTARIO', COUNT(*) FROM INVENTARIO
UNION ALL SELECT 'FACTURA', COUNT(*) FROM FACTURA
UNION ALL SELECT 'DETALLE_FACTURA', COUNT(*) FROM DETALLE_FACTURA;

-- Cada prueba intenta un cambio que viola una regla. Debe fallar con el código esperado;
-- si por error se aplicara, se deshace con ROLLBACK.
DROP PROCEDURE IF EXISTS PR_PROBAR;
DELIMITER $$
CREATE PROCEDURE PR_PROBAR (p_nombre VARCHAR(60), p_sql VARCHAR(500), p_codigo INT)
BEGIN
  DECLARE v_codigo INT DEFAULT 0;
  DECLARE v_mensaje VARCHAR(300) DEFAULT '';
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    GET DIAGNOSTICS CONDITION 1 v_codigo = MYSQL_ERRNO, v_mensaje = MESSAGE_TEXT;
  SET @prueba = p_sql;
  START TRANSACTION;
  PREPARE sentencia FROM @prueba;
  EXECUTE sentencia;
  DEALLOCATE PREPARE sentencia;
  ROLLBACK;
  SELECT IF(v_codigo = p_codigo, 'OK', 'FALLA') AS resultado, p_nombre AS prueba,
         CONCAT(v_codigo, ': ', LEFT(v_mensaje, 90)) AS error;
END$$
DELIMITER ;

SELECT '== Prueba de reglas de negocio (cada intento debe ser RECHAZADO con el código esperado)' AS seccion;
CALL PR_PROBAR('FK a departamento inexistente', 'INSERT INTO CIUDAD VALUES (999, ''99999'', ''Ciudad X'', 99)', 1452);
CALL PR_PROBAR('CHECK sexo de mascota', 'UPDATE MASCOTA SET sexo = ''X'' WHERE id_mascota = 1', 3819);
CALL PR_PROBAR('UNIQUE documento de cliente', 'UPDATE CLIENTE c JOIN CLIENTE o ON o.id_cliente = 2 SET c.tipo_documento = o.tipo_documento, c.num_documento = o.num_documento WHERE c.id_cliente = 1', 1062);
CALL PR_PROBAR('Arco exclusivo del detalle', 'UPDATE DETALLE_FACTURA SET id_medicamento = 1 WHERE id_servicio IS NOT NULL LIMIT 1', 3819);
CALL PR_PROBAR('RN-09 subtipo VET', 'INSERT INTO VETERINARIO SELECT MIN(id_empleado), ''TP-X'', ''U'', 2020 FROM EMPLEADO WHERE tipo_empleado = ''ADM''', 20001);
CALL PR_PROBAR('RN-08 veterinario de otra sede', 'UPDATE CITA SET id_sede = CASE id_sede WHEN 1 THEN 5 ELSE 1 END WHERE id_cita = 1', 20003);
CALL PR_PROBAR('Consulta de cita no atendida', 'INSERT INTO CONSULTA (id_consulta, id_cita, fecha_hora_inicio, peso_kg, diagnostico) SELECT 9999, MIN(id_cita), NOW(), 5, ''X'' FROM CITA WHERE estado = ''CANCELADA''', 20004);
CALL PR_PROBAR('Mover consulta a cita cancelada', 'UPDATE CONSULTA SET id_cita = (SELECT MIN(id_cita) FROM CITA WHERE estado = ''CANCELADA'') WHERE id_consulta = 1', 20004);
CALL PR_PROBAR('Cambio de tipo con subtipo', 'UPDATE EMPLEADO SET tipo_empleado = ''ADM'' WHERE id_empleado = (SELECT MIN(id_empleado) FROM VETERINARIO)', 20005);
CALL PR_PROBAR('Cita con consulta deja ATENDIDA', 'UPDATE CITA SET estado = ''CANCELADA'' WHERE id_cita = (SELECT MIN(id_cita) FROM CONSULTA)', 20006);
DROP PROCEDURE PR_PROBAR;

SELECT '== Atributos derivados (funciones)' AS seccion;
SELECT numero_factura, FN_TOTAL_FACTURA(id_factura) AS total FROM FACTURA ORDER BY id_factura LIMIT 3;
