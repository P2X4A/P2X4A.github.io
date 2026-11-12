-- SIGEVET - Funciones, procedimientos y disparadores
-- MySQL 8.4, base de datos sigevet. Se ejecuta ANTES de cargar los datos: los disparadores validan cada INSERT.
-- Implementan las reglas de negocio que no se pueden expresar con PK, FK, UNIQUE o CHECK (documento de supuestos).
-- En MySQL un disparador cubre un solo evento, por eso cada regla está en un procedimiento
-- que se llama desde el disparador de INSERT y desde el de UPDATE.
USE sigevet;

DELIMITER $$

-- Edad en años cumplidos (atributo derivado "edad" del MER).
CREATE FUNCTION FN_EDAD_MASCOTA (p_fecha_nacimiento DATE)
RETURNS INT
NOT DETERMINISTIC NO SQL
BEGIN
  IF p_fecha_nacimiento IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END$$

-- Total de una factura (atributo derivado "total").
CREATE FUNCTION FN_TOTAL_FACTURA (p_id_factura INT)
RETURNS DECIMAL(14,2)
READS SQL DATA
BEGIN
  DECLARE v_total DECIMAL(14,2);
  SELECT IFNULL(ROUND(SUM(cantidad * precio_unitario * (1 - descuento_pct / 100)), 2), 0)
    INTO v_total
    FROM DETALLE_FACTURA
   WHERE id_factura = p_id_factura;
  RETURN v_total;
END$$

-- RN-09: el empleado de un subtipo (VETERINARIO o AUXILIAR) debe tener ese tipo en EMPLEADO.
CREATE PROCEDURE PR_VALIDAR_TIPO_EMPLEADO (p_id_empleado INT, p_tipo VARCHAR(3), p_codigo INT)
BEGIN
  DECLARE v_tipo VARCHAR(3);
  DECLARE v_mensaje VARCHAR(200);
  SELECT tipo_empleado INTO v_tipo FROM EMPLEADO WHERE id_empleado = p_id_empleado;
  IF v_tipo <> p_tipo THEN
    SET v_mensaje = CONCAT('El empleado ', p_id_empleado, ' no es de tipo ', p_tipo, '.');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje, MYSQL_ERRNO = p_codigo;
  END IF;
END$$

-- RN-08: el veterinario de una cita debe trabajar en la sede de la cita.
CREATE PROCEDURE PR_VALIDAR_SEDE_VETERINARIO (p_id_veterinario INT, p_id_sede INT)
BEGIN
  DECLARE v_sede INT;
  DECLARE v_mensaje VARCHAR(200);
  SELECT id_sede INTO v_sede FROM EMPLEADO WHERE id_empleado = p_id_veterinario;
  IF v_sede <> p_id_sede THEN
    SET v_mensaje = CONCAT('El veterinario ', p_id_veterinario, ' labora en la sede ', v_sede,
                           ', no en la sede ', p_id_sede, '.');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje, MYSQL_ERRNO = 20003;
  END IF;
END$$

-- Solo una cita en estado ATENDIDA puede tener consulta (supuesto S-28).
CREATE PROCEDURE PR_VALIDAR_CITA_ATENDIDA (p_id_cita INT)
BEGIN
  DECLARE v_estado VARCHAR(12);
  DECLARE v_mensaje VARCHAR(200);
  SELECT estado INTO v_estado FROM CITA WHERE id_cita = p_id_cita;
  IF v_estado <> 'ATENDIDA' THEN
    SET v_mensaje = CONCAT('La cita ', p_id_cita, ' está en estado ', v_estado,
                           '; solo las citas ATENDIDAS generan consulta.');
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje, MYSQL_ERRNO = 20004;
  END IF;
END$$

CREATE TRIGGER TRG_VETERINARIO_TIPO_INS BEFORE INSERT ON VETERINARIO FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_TIPO_EMPLEADO(NEW.id_empleado, 'VET', 20001);
END$$

CREATE TRIGGER TRG_VETERINARIO_TIPO_UPD BEFORE UPDATE ON VETERINARIO FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_TIPO_EMPLEADO(NEW.id_empleado, 'VET', 20001);
END$$

CREATE TRIGGER TRG_AUXILIAR_TIPO_INS BEFORE INSERT ON AUXILIAR FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_TIPO_EMPLEADO(NEW.id_empleado, 'AUX', 20002);
END$$

CREATE TRIGGER TRG_AUXILIAR_TIPO_UPD BEFORE UPDATE ON AUXILIAR FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_TIPO_EMPLEADO(NEW.id_empleado, 'AUX', 20002);
END$$

CREATE TRIGGER TRG_CITA_VETERINARIO_SEDE_INS BEFORE INSERT ON CITA FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_SEDE_VETERINARIO(NEW.id_veterinario, NEW.id_sede);
END$$

-- Una cita que ya tiene consulta debe seguir en estado ATENDIDA.
-- Va en el mismo disparador de UPDATE de CITA que la regla RN-08.
CREATE TRIGGER TRG_CITA_UPD BEFORE UPDATE ON CITA FOR EACH ROW
BEGIN
  DECLARE v_consultas INT;
  DECLARE v_mensaje VARCHAR(200);
  CALL PR_VALIDAR_SEDE_VETERINARIO(NEW.id_veterinario, NEW.id_sede);
  IF OLD.estado = 'ATENDIDA' AND NEW.estado <> 'ATENDIDA' THEN
    SELECT COUNT(*) INTO v_consultas FROM CONSULTA WHERE id_cita = OLD.id_cita;
    IF v_consultas > 0 THEN
      SET v_mensaje = CONCAT('La cita ', OLD.id_cita, ' ya tiene consulta registrada; no puede cambiar a ',
                             NEW.estado, '.');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje, MYSQL_ERRNO = 20006;
    END IF;
  END IF;
END$$

CREATE TRIGGER TRG_CONSULTA_CITA_ATENDIDA_INS BEFORE INSERT ON CONSULTA FOR EACH ROW
BEGIN
  CALL PR_VALIDAR_CITA_ATENDIDA(NEW.id_cita);
END$$

CREATE TRIGGER TRG_CONSULTA_CITA_ATENDIDA_UPD BEFORE UPDATE ON CONSULTA FOR EACH ROW
BEGIN
  IF NEW.id_cita <> OLD.id_cita THEN
    CALL PR_VALIDAR_CITA_ATENDIDA(NEW.id_cita);
  END IF;
END$$

-- No se puede cambiar el tipo de un empleado que ya tiene fila en VETERINARIO o AUXILIAR (RN-09).
CREATE TRIGGER TRG_EMPLEADO_TIPO BEFORE UPDATE ON EMPLEADO FOR EACH ROW
BEGIN
  DECLARE v_filas INT;
  DECLARE v_mensaje VARCHAR(200);
  IF NEW.tipo_empleado <> OLD.tipo_empleado THEN
    SELECT (SELECT COUNT(*) FROM VETERINARIO WHERE id_empleado = OLD.id_empleado)
         + (SELECT COUNT(*) FROM AUXILIAR WHERE id_empleado = OLD.id_empleado)
      INTO v_filas;
    IF v_filas > 0 THEN
      SET v_mensaje = CONCAT('El empleado ', OLD.id_empleado,
                             ' tiene registro de subtipo; elimínelo antes de cambiar tipo_empleado.');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje, MYSQL_ERRNO = 20005;
    END IF;
  END IF;
END$$

DELIMITER ;
