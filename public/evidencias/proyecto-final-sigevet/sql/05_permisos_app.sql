-- SIGEVET - Permisos de escritura de la aplicación web
-- Se ejecuta como root DESPUÉS de crear las tablas (01_crear_tablas.sql), porque MySQL solo concede permisos
-- de tabla sobre tablas que ya existen, y vetdb no puede conceder permisos a otros usuarios.
--   mysql -u root -p < 01_ddl/05_permisos_app.sql
--
-- Principio de mínimo privilegio: vet_app conserva la lectura de toda la base (rol_sigevet_lectura) y recibe
-- escritura SOLO en las tablas que la aplicación modifica, y solo con las operaciones que usa:
--   - Sin DROP, ALTER, CREATE ni permisos sobre catálogos (SERVICIO, MEDICAMENTO, ESPECIE, RAZA, CIUDAD...).
--   - DELETE solo donde hay borrado físico: teléfonos, inventario y especialidades de un veterinario, y
--     clientes sin historial. Mascotas, empleados, citas y facturas nunca se borran: cambian de estado.
-- Las reglas de negocio siguen en la base: los disparadores RN-08, RN-09 y de consulta se ejecutan con los
-- permisos de quien los creó (vetdb), así que vet_app no necesita permisos sobre los procedimientos.

USE sigevet;

CREATE ROLE IF NOT EXISTS 'rol_sigevet_escritura';

-- Clientes y sus teléfonos (atributo multivaluado)
GRANT INSERT, UPDATE, DELETE ON sigevet.CLIENTE          TO 'rol_sigevet_escritura';
GRANT INSERT, UPDATE, DELETE ON sigevet.TELEFONO_CLIENTE TO 'rol_sigevet_escritura';

-- Mascotas e historia clínica (1:1): se crean juntas; la mascota se "elimina" cambiando su estado
GRANT INSERT, UPDATE ON sigevet.MASCOTA          TO 'rol_sigevet_escritura';
GRANT INSERT, UPDATE ON sigevet.HISTORIA_CLINICA TO 'rol_sigevet_escritura';

-- Agenda: crear citas y cambiar su estado
GRANT INSERT, UPDATE ON sigevet.CITA TO 'rol_sigevet_escritura';

-- Facturación: crear facturas con sus líneas y anularlas (las líneas nunca se modifican)
GRANT INSERT, UPDATE ON sigevet.FACTURA         TO 'rol_sigevet_escritura';
GRANT INSERT         ON sigevet.DETALLE_FACTURA TO 'rol_sigevet_escritura';

-- Inventario por sede (la venta de un medicamento descuenta existencias)
GRANT INSERT, UPDATE, DELETE ON sigevet.INVENTARIO TO 'rol_sigevet_escritura';

-- Personal: supertipo, subtipos y especialidades (N:M CERTIFICAR); el empleado se inactiva, no se borra
GRANT INSERT, UPDATE         ON sigevet.EMPLEADO                 TO 'rol_sigevet_escritura';
GRANT INSERT, UPDATE         ON sigevet.VETERINARIO              TO 'rol_sigevet_escritura';
GRANT INSERT, UPDATE         ON sigevet.AUXILIAR                 TO 'rol_sigevet_escritura';
GRANT INSERT, DELETE         ON sigevet.VETERINARIO_ESPECIALIDAD TO 'rol_sigevet_escritura';

-- vet_app tiene los dos roles activos al conectarse
GRANT 'rol_sigevet_escritura' TO 'vet_app'@'%';
SET DEFAULT ROLE 'rol_sigevet_lectura', 'rol_sigevet_escritura' TO 'vet_app'@'%';

SELECT 'Permisos de escritura de vet_app concedidos (rol_sigevet_escritura)' AS resultado;
SHOW GRANTS FOR 'rol_sigevet_escritura';
