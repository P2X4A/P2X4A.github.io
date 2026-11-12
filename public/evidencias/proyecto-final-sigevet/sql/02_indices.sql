-- SIGEVET - Índices de búsqueda
-- MySQL 8.4, base de datos sigevet
USE sigevet;
-- InnoDB ya crea un índice por cada llave primaria, única y foránea.
-- Estos son para las columnas por las que más se busca u ordena en la aplicación.

CREATE INDEX IX_CLIENTE_APELLIDOS ON CLIENTE (apellidos);
CREATE INDEX IX_MASCOTA_NOMBRE ON MASCOTA (nombre);
CREATE INDEX IX_CITA_FECHA_HORA ON CITA (fecha_hora);
CREATE INDEX IX_FACTURA_FECHA_EMISION ON FACTURA (fecha_emision);
CREATE INDEX IX_EMPLEADO_APELLIDOS ON EMPLEADO (apellidos);
