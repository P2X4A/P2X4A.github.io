-- SIGEVET - Proyecto final Bases de Datos 1
-- Creación de tablas y restricciones (con los comentarios del diccionario)
-- MySQL 8.4, base de datos sigevet

USE sigevet;

-- DEPARTAMENTO: Departamentos de Colombia donde la red tiene sedes o clientes (codificación DANE).
CREATE TABLE DEPARTAMENTO (
    id_departamento  INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador del departamento.',
    codigo_dane      CHAR(2) NOT NULL COMMENT 'Código DANE de dos dígitos.',
    nombre           VARCHAR(60) NOT NULL COMMENT 'Nombre oficial del departamento.',
    CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY (id_departamento),
    CONSTRAINT UQ_DEPARTAMENTO_CODIGO_DANE UNIQUE (codigo_dane),
    CONSTRAINT UQ_DEPARTAMENTO_NOMBRE UNIQUE (nombre),
    CONSTRAINT CK_DEPARTAMENTO_CODIGO_DANE CHECK (codigo_dane REGEXP '^[0-9]{2}$')
) ENGINE=InnoDB COMMENT='Departamentos de Colombia donde la red tiene sedes o clientes (codificación DANE).';

-- CIUDAD: Municipios donde se ubican sedes y residen clientes.
CREATE TABLE CIUDAD (
    id_ciudad        INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la ciudad.',
    codigo_dane      CHAR(5) NOT NULL COMMENT 'Código DANE del municipio (5 dígitos).',
    nombre           VARCHAR(80) NOT NULL COMMENT 'Nombre del municipio.',
    id_departamento  INT NOT NULL COMMENT 'Departamento al que pertenece la ciudad.',
    CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad),
    CONSTRAINT UQ_CIUDAD_CODIGO_DANE UNIQUE (codigo_dane),
    CONSTRAINT UQ_CIUDAD_NOMBRE_DEPARTAMENTO UNIQUE (nombre, id_departamento),
    CONSTRAINT CK_CIUDAD_CODIGO_DANE CHECK (codigo_dane REGEXP '^[0-9]{5}$'),
    CONSTRAINT FK_CIUDAD_DEPARTAMENTO FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO (id_departamento)
) ENGINE=InnoDB COMMENT='Municipios donde se ubican sedes y residen clientes.';

-- SEDE: Clínica física de la red Huella Sana. Cada sede tiene exactamente un director.
CREATE TABLE SEDE (
    id_sede         INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la sede.',
    nombre          VARCHAR(80) NOT NULL COMMENT 'Nombre comercial de la sede.',
    direccion       VARCHAR(120) NOT NULL COMMENT 'Dirección física.',
    telefono        VARCHAR(20) NOT NULL COMMENT 'Teléfono principal de la sede.',
    email           VARCHAR(100) NOT NULL COMMENT 'Correo electrónico de la sede.',
    fecha_apertura  DATE NOT NULL COMMENT 'Fecha en que la sede inició operación.',
    id_ciudad       INT NOT NULL COMMENT 'Ciudad donde se ubica la sede.',
    id_director     INT COMMENT 'Empleado que dirige la sede (relación 1:1 DIRIGIR).',
    CONSTRAINT PK_SEDE PRIMARY KEY (id_sede),
    CONSTRAINT UQ_SEDE_NOMBRE UNIQUE (nombre),
    CONSTRAINT UQ_SEDE_EMAIL UNIQUE (email),
    CONSTRAINT UQ_SEDE_DIRECTOR UNIQUE (id_director),
    CONSTRAINT FK_SEDE_CIUDAD FOREIGN KEY (id_ciudad) REFERENCES CIUDAD (id_ciudad)
) ENGINE=InnoDB COMMENT='Clínica física de la red Huella Sana. Cada sede tiene exactamente un director.';

-- EMPLEADO: Supertipo de todo el personal. El discriminador tipo_empleado indica el subtipo (VET, AUX) o ADM para personal administrativo que no pertenece a ningún subtipo.
CREATE TABLE EMPLEADO (
    id_empleado       INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador del empleado.',
    tipo_documento    VARCHAR(3) NOT NULL COMMENT 'Tipo de documento de identidad.',
    num_documento     VARCHAR(15) NOT NULL COMMENT 'Número del documento de identidad.',
    nombres           VARCHAR(60) NOT NULL COMMENT 'Nombres del empleado (parte del atributo compuesto nombre_completo).',
    apellidos         VARCHAR(60) NOT NULL COMMENT 'Apellidos del empleado.',
    fecha_nacimiento  DATE NOT NULL COMMENT 'Fecha de nacimiento.',
    telefono          VARCHAR(20) NOT NULL COMMENT 'Teléfono de contacto.',
    email             VARCHAR(100) NOT NULL COMMENT 'Correo corporativo.',
    tipo_empleado     CHAR(3) NOT NULL COMMENT 'Discriminador de la especialización: VET, AUX o ADM.',
    fecha_ingreso     DATE NOT NULL COMMENT 'Fecha de vinculación a la red.',
    salario           DECIMAL(12,2) NOT NULL COMMENT 'Salario mensual en pesos colombianos.',
    estado            VARCHAR(10) NOT NULL DEFAULT 'ACTIVO' COMMENT 'Estado laboral.',
    id_sede           INT NOT NULL COMMENT 'Sede donde labora el empleado (relación LABORAR).',
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (id_empleado),
    CONSTRAINT UQ_EMPLEADO_TIPO_DOCUMENTO_NUM_DOCUMENTO UNIQUE (tipo_documento, num_documento),
    CONSTRAINT UQ_EMPLEADO_EMAIL UNIQUE (email),
    CONSTRAINT CK_EMPLEADO_TIPO_DOCUMENTO CHECK (tipo_documento IN ('CC','CE','PA','PPT')),
    CONSTRAINT CK_EMPLEADO_TIPO_EMPLEADO CHECK (tipo_empleado IN ('VET','AUX','ADM')),
    CONSTRAINT CK_EMPLEADO_SALARIO CHECK (salario > 0),
    CONSTRAINT CK_EMPLEADO_ESTADO CHECK (estado IN ('ACTIVO','INACTIVO')),
    CONSTRAINT FK_EMPLEADO_SEDE FOREIGN KEY (id_sede) REFERENCES SEDE (id_sede)
) ENGINE=InnoDB COMMENT='Supertipo de todo el personal. El discriminador tipo_empleado indica el subtipo (VET, AUX) o ADM para personal administrativo que no pertenece a ningún subtipo.';

-- VETERINARIO: Subtipo de EMPLEADO: médico veterinario habilitado para atender citas y prescribir.
CREATE TABLE VETERINARIO (
    id_empleado          INT NOT NULL COMMENT 'Identificador heredado del supertipo EMPLEADO.',
    tarjeta_profesional  VARCHAR(20) NOT NULL COMMENT 'Número de tarjeta profesional (COMVEZCOL).',
    universidad          VARCHAR(100) NOT NULL COMMENT 'Universidad que otorgó el título.',
    anio_graduacion      INT NOT NULL COMMENT 'Año de graduación.',
    CONSTRAINT PK_VETERINARIO PRIMARY KEY (id_empleado),
    CONSTRAINT UQ_VETERINARIO_TARJETA_PROFESIONAL UNIQUE (tarjeta_profesional),
    CONSTRAINT CK_VETERINARIO_ANIO_GRADUACION CHECK (anio_graduacion BETWEEN 1970 AND 2026),
    CONSTRAINT FK_VETERINARIO_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Subtipo de EMPLEADO: médico veterinario habilitado para atender citas y prescribir.';

-- AUXILIAR: Subtipo de EMPLEADO: auxiliar veterinario que asiste las consultas.
CREATE TABLE AUXILIAR (
    id_empleado    INT NOT NULL COMMENT 'Identificador heredado del supertipo EMPLEADO.',
    area           VARCHAR(20) NOT NULL COMMENT 'Área de desempeño.',
    certificacion  VARCHAR(100) COMMENT 'Título técnico o tecnológico.',
    turno          VARCHAR(10) NOT NULL COMMENT 'Turno habitual.',
    CONSTRAINT PK_AUXILIAR PRIMARY KEY (id_empleado),
    CONSTRAINT CK_AUXILIAR_AREA CHECK (area IN ('CLINICA','CIRUGIA','LABORATORIO','ESTETICA','HOSPITALIZACION')),
    CONSTRAINT CK_AUXILIAR_TURNO CHECK (turno IN ('MANANA','TARDE','NOCHE')),
    CONSTRAINT FK_AUXILIAR_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Subtipo de EMPLEADO: auxiliar veterinario que asiste las consultas.';

-- ESPECIALIDAD: Áreas de especialización médica veterinaria.
CREATE TABLE ESPECIALIDAD (
    id_especialidad  INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la especialidad.',
    nombre           VARCHAR(60) NOT NULL COMMENT 'Nombre de la especialidad.',
    descripcion      VARCHAR(200) COMMENT 'Descripción breve.',
    CONSTRAINT PK_ESPECIALIDAD PRIMARY KEY (id_especialidad),
    CONSTRAINT UQ_ESPECIALIDAD_NOMBRE UNIQUE (nombre)
) ENGINE=InnoDB COMMENT='Áreas de especialización médica veterinaria.';

-- VETERINARIO_ESPECIALIDAD: Resuelve la relación N:M CERTIFICAR entre VETERINARIO y ESPECIALIDAD.
CREATE TABLE VETERINARIO_ESPECIALIDAD (
    id_empleado          INT NOT NULL COMMENT 'Veterinario certificado.',
    id_especialidad      INT NOT NULL COMMENT 'Especialidad certificada.',
    fecha_certificacion  DATE NOT NULL COMMENT 'Fecha en que obtuvo la certificación.',
    CONSTRAINT PK_VETERINARIO_ESPECIALIDAD PRIMARY KEY (id_empleado, id_especialidad),
    CONSTRAINT FK_VETERINARIO_ESPECIALIDAD_VETERINARIO FOREIGN KEY (id_empleado) REFERENCES VETERINARIO (id_empleado) ON DELETE CASCADE,
    CONSTRAINT FK_VETERINARIO_ESPECIALIDAD_ESPECIALIDAD FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD (id_especialidad)
) ENGINE=InnoDB COMMENT='Resuelve la relación N:M CERTIFICAR entre VETERINARIO y ESPECIALIDAD.';

-- CLIENTE: Persona propietaria de una o más mascotas; es quien paga los servicios.
CREATE TABLE CLIENTE (
    id_cliente      INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador del cliente.',
    tipo_documento  VARCHAR(3) NOT NULL COMMENT 'Tipo de documento de identidad.',
    num_documento   VARCHAR(15) NOT NULL COMMENT 'Número del documento de identidad.',
    nombres         VARCHAR(60) NOT NULL COMMENT 'Nombres del cliente.',
    apellidos       VARCHAR(60) NOT NULL COMMENT 'Apellidos del cliente.',
    email           VARCHAR(100) COMMENT 'Correo electrónico.',
    direccion       VARCHAR(120) NOT NULL COMMENT 'Dirección de residencia.',
    id_ciudad       INT NOT NULL COMMENT 'Ciudad de residencia.',
    fecha_registro  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de registro en el sistema.',
    CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_CLIENTE_TIPO_DOCUMENTO_NUM_DOCUMENTO UNIQUE (tipo_documento, num_documento),
    CONSTRAINT UQ_CLIENTE_EMAIL UNIQUE (email),
    CONSTRAINT CK_CLIENTE_TIPO_DOCUMENTO CHECK (tipo_documento IN ('CC','CE','PA','PPT')),
    CONSTRAINT FK_CLIENTE_CIUDAD FOREIGN KEY (id_ciudad) REFERENCES CIUDAD (id_ciudad)
) ENGINE=InnoDB COMMENT='Persona propietaria de una o más mascotas; es quien paga los servicios.';

-- TELEFONO_CLIENTE: Atributo multivaluado teléfono de CLIENTE llevado a tabla (Primera Forma Normal).
CREATE TABLE TELEFONO_CLIENTE (
    id_cliente  INT NOT NULL COMMENT 'Cliente dueño del teléfono.',
    telefono    VARCHAR(20) NOT NULL COMMENT 'Número telefónico.',
    tipo        VARCHAR(10) NOT NULL COMMENT 'Tipo de línea.',
    CONSTRAINT PK_TELEFONO_CLIENTE PRIMARY KEY (id_cliente, telefono),
    CONSTRAINT CK_TELEFONO_CLIENTE_TIPO CHECK (tipo IN ('MOVIL','FIJO','TRABAJO')),
    CONSTRAINT FK_TELEFONO_CLIENTE_CLIENTE FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Atributo multivaluado teléfono de CLIENTE llevado a tabla (Primera Forma Normal).';

-- ESPECIE: Especie animal atendida por la red.
CREATE TABLE ESPECIE (
    id_especie  INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la especie.',
    nombre      VARCHAR(40) NOT NULL COMMENT 'Nombre común de la especie.',
    CONSTRAINT PK_ESPECIE PRIMARY KEY (id_especie),
    CONSTRAINT UQ_ESPECIE_NOMBRE UNIQUE (nombre)
) ENGINE=InnoDB COMMENT='Especie animal atendida por la red.';

-- RAZA: Raza de una especie. Separarla de MASCOTA elimina la dependencia transitiva raza → especie (3FN).
CREATE TABLE RAZA (
    id_raza     INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la raza.',
    nombre      VARCHAR(60) NOT NULL COMMENT 'Nombre de la raza.',
    tamano      VARCHAR(10) NOT NULL COMMENT 'Tamaño típico de la raza.',
    id_especie  INT NOT NULL COMMENT 'Especie a la que pertenece la raza.',
    CONSTRAINT PK_RAZA PRIMARY KEY (id_raza),
    CONSTRAINT UQ_RAZA_NOMBRE_ESPECIE UNIQUE (nombre, id_especie),
    CONSTRAINT CK_RAZA_TAMANO CHECK (tamano IN ('PEQUENO','MEDIANO','GRANDE','NA')),
    CONSTRAINT FK_RAZA_ESPECIE FOREIGN KEY (id_especie) REFERENCES ESPECIE (id_especie)
) ENGINE=InnoDB COMMENT='Raza de una especie. Separarla de MASCOTA elimina la dependencia transitiva raza → especie (3FN).';

-- MASCOTA: Paciente de la red. La edad es un atributo derivado de fecha_nacimiento (no se almacena).
CREATE TABLE MASCOTA (
    id_mascota        INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la mascota.',
    nombre            VARCHAR(40) NOT NULL COMMENT 'Nombre de la mascota.',
    fecha_nacimiento  DATE COMMENT 'Fecha de nacimiento (aproximada si se desconoce).',
    sexo              CHAR(1) NOT NULL COMMENT 'M = macho, H = hembra.',
    color             VARCHAR(40) COMMENT 'Color o patrón del pelaje/plumaje.',
    microchip         VARCHAR(15) COMMENT 'Código del microchip de identificación (15 dígitos ISO).',
    esterilizado      CHAR(1) NOT NULL DEFAULT 'N' COMMENT 'S si está esterilizada, N si no.',
    estado            VARCHAR(10) NOT NULL DEFAULT 'ACTIVA' COMMENT 'Estado del paciente.',
    id_raza           INT NOT NULL COMMENT 'Raza de la mascota (determina la especie).',
    id_cliente        INT NOT NULL COMMENT 'Cliente propietario.',
    fecha_registro    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de registro en la red.',
    CONSTRAINT PK_MASCOTA PRIMARY KEY (id_mascota),
    CONSTRAINT UQ_MASCOTA_MICROCHIP UNIQUE (microchip),
    CONSTRAINT CK_MASCOTA_SEXO CHECK (sexo IN ('M','H')),
    CONSTRAINT CK_MASCOTA_ESTERILIZADO CHECK (esterilizado IN ('S','N')),
    CONSTRAINT CK_MASCOTA_ESTADO CHECK (estado IN ('ACTIVA','FALLECIDA','TRASLADADA')),
    CONSTRAINT FK_MASCOTA_RAZA FOREIGN KEY (id_raza) REFERENCES RAZA (id_raza),
    CONSTRAINT FK_MASCOTA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente)
) ENGINE=InnoDB COMMENT='Paciente de la red. La edad es un atributo derivado de fecha_nacimiento (no se almacena).';

-- HISTORIA_CLINICA: Historia clínica única de cada mascota (relación 1:1 TENER), compartida por todas las sedes.
CREATE TABLE HISTORIA_CLINICA (
    id_historia            INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la historia clínica.',
    numero_historia        VARCHAR(12) NOT NULL COMMENT 'Número legible de la historia.',
    id_mascota             INT NOT NULL COMMENT 'Mascota a la que pertenece (UNIQUE: garantiza 1:1).',
    fecha_apertura         DATE NOT NULL COMMENT 'Fecha de apertura de la historia.',
    grupo_sanguineo        VARCHAR(10) COMMENT 'Grupo sanguíneo si se conoce.',
    alergias               VARCHAR(200) COMMENT 'Alergias conocidas.',
    enfermedades_cronicas  VARCHAR(200) COMMENT 'Enfermedades crónicas diagnosticadas.',
    observaciones          VARCHAR(400) COMMENT 'Notas generales.',
    CONSTRAINT PK_HISTORIA_CLINICA PRIMARY KEY (id_historia),
    CONSTRAINT UQ_HISTORIA_CLINICA_NUMERO_HISTORIA UNIQUE (numero_historia),
    CONSTRAINT UQ_HISTORIA_CLINICA_MASCOTA UNIQUE (id_mascota),
    CONSTRAINT FK_HISTORIA_CLINICA_MASCOTA FOREIGN KEY (id_mascota) REFERENCES MASCOTA (id_mascota) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Historia clínica única de cada mascota (relación 1:1 TENER), compartida por todas las sedes.';

-- SERVICIO: Catálogo de servicios ofrecidos con su precio vigente y duración estimada.
CREATE TABLE SERVICIO (
    id_servicio   INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador del servicio.',
    codigo        VARCHAR(10) NOT NULL COMMENT 'Código interno del servicio.',
    nombre        VARCHAR(80) NOT NULL COMMENT 'Nombre del servicio.',
    categoria     VARCHAR(20) NOT NULL COMMENT 'Categoría del servicio.',
    precio        DECIMAL(10,2) NOT NULL COMMENT 'Precio vigente en pesos (IVA incluido).',
    duracion_min  INT NOT NULL COMMENT 'Duración estimada en minutos.',
    CONSTRAINT PK_SERVICIO PRIMARY KEY (id_servicio),
    CONSTRAINT UQ_SERVICIO_CODIGO UNIQUE (codigo),
    CONSTRAINT UQ_SERVICIO_NOMBRE UNIQUE (nombre),
    CONSTRAINT CK_SERVICIO_CATEGORIA CHECK (categoria IN ('CONSULTA','VACUNACION','CIRUGIA','LABORATORIO','ESTETICA','IMAGENOLOGIA','HOSPITALIZACION')),
    CONSTRAINT CK_SERVICIO_PRECIO CHECK (precio > 0),
    CONSTRAINT CK_SERVICIO_DURACION_MIN CHECK (duracion_min > 0)
) ENGINE=InnoDB COMMENT='Catálogo de servicios ofrecidos con su precio vigente y duración estimada.';

-- CITA: Reserva de atención de una mascota con un veterinario, en una sede, para un servicio.
CREATE TABLE CITA (
    id_cita         BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la cita.',
    fecha_hora      DATETIME NOT NULL COMMENT 'Fecha y hora programada de la cita.',
    motivo          VARCHAR(200) COMMENT 'Motivo de la cita informado por el cliente.',
    estado          VARCHAR(12) NOT NULL DEFAULT 'PROGRAMADA' COMMENT 'Estado de la cita.',
    id_mascota      INT NOT NULL COMMENT 'Mascota que será atendida.',
    id_veterinario  INT NOT NULL COMMENT 'Veterinario asignado.',
    id_sede         INT NOT NULL COMMENT 'Sede donde se realiza la cita.',
    id_servicio     INT NOT NULL COMMENT 'Servicio solicitado.',
    CONSTRAINT PK_CITA PRIMARY KEY (id_cita),
    CONSTRAINT UQ_CITA_VETERINARIO_FECHA_HORA UNIQUE (id_veterinario, fecha_hora),
    CONSTRAINT CK_CITA_ESTADO CHECK (estado IN ('PROGRAMADA','ATENDIDA','CANCELADA','NO_ASISTIO')),
    CONSTRAINT FK_CITA_MASCOTA FOREIGN KEY (id_mascota) REFERENCES MASCOTA (id_mascota),
    CONSTRAINT FK_CITA_VETERINARIO FOREIGN KEY (id_veterinario) REFERENCES VETERINARIO (id_empleado),
    CONSTRAINT FK_CITA_SEDE FOREIGN KEY (id_sede) REFERENCES SEDE (id_sede),
    CONSTRAINT FK_CITA_SERVICIO FOREIGN KEY (id_servicio) REFERENCES SERVICIO (id_servicio)
) ENGINE=InnoDB COMMENT='Reserva de atención de una mascota con un veterinario, en una sede, para un servicio.';

-- CONSULTA: Registro clínico de una cita atendida (relación 1:1 GENERAR con CITA).
CREATE TABLE CONSULTA (
    id_consulta          BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la consulta.',
    id_cita              BIGINT NOT NULL COMMENT 'Cita que originó la consulta (UNIQUE: garantiza 1:1).',
    id_auxiliar          INT COMMENT 'Auxiliar que asistió la consulta (opcional).',
    fecha_hora_inicio    DATETIME NOT NULL COMMENT 'Fecha y hora real de inicio de la atención.',
    peso_kg              DECIMAL(5,2) NOT NULL COMMENT 'Peso registrado en kilogramos.',
    temperatura_c        DECIMAL(4,1) COMMENT 'Temperatura corporal en °C.',
    frecuencia_cardiaca  INT COMMENT 'Latidos por minuto.',
    sintomas             VARCHAR(400) COMMENT 'Signos y síntomas observados.',
    diagnostico          VARCHAR(400) NOT NULL COMMENT 'Diagnóstico del veterinario.',
    observaciones        VARCHAR(400) COMMENT 'Indicaciones y notas.',
    CONSTRAINT PK_CONSULTA PRIMARY KEY (id_consulta),
    CONSTRAINT UQ_CONSULTA_CITA UNIQUE (id_cita),
    CONSTRAINT CK_CONSULTA_PESO_KG CHECK (peso_kg > 0),
    CONSTRAINT CK_CONSULTA_TEMPERATURA_C CHECK (temperatura_c BETWEEN 30 AND 45),
    CONSTRAINT CK_CONSULTA_FRECUENCIA_CARDIACA CHECK (frecuencia_cardiaca BETWEEN 20 AND 300),
    CONSTRAINT FK_CONSULTA_CITA FOREIGN KEY (id_cita) REFERENCES CITA (id_cita),
    CONSTRAINT FK_CONSULTA_AUXILIAR FOREIGN KEY (id_auxiliar) REFERENCES AUXILIAR (id_empleado)
) ENGINE=InnoDB COMMENT='Registro clínico de una cita atendida (relación 1:1 GENERAR con CITA).';

-- MEDICAMENTO: Catálogo de medicamentos e insumos veterinarios con su precio de venta vigente.
CREATE TABLE MEDICAMENTO (
    id_medicamento    INT NOT NULL AUTO_INCREMENT COMMENT 'Identificador del medicamento.',
    codigo            VARCHAR(12) NOT NULL COMMENT 'Código interno (SKU).',
    nombre            VARCHAR(80) NOT NULL COMMENT 'Nombre comercial.',
    principio_activo  VARCHAR(80) NOT NULL COMMENT 'Principio activo.',
    presentacion      VARCHAR(40) NOT NULL COMMENT 'Forma farmacéutica y concentración.',
    laboratorio       VARCHAR(60) NOT NULL COMMENT 'Laboratorio fabricante.',
    precio_venta      DECIMAL(10,2) NOT NULL COMMENT 'Precio de venta unitario vigente (IVA incluido).',
    requiere_formula  CHAR(1) NOT NULL DEFAULT 'N' COMMENT 'S si solo se vende con fórmula médica.',
    CONSTRAINT PK_MEDICAMENTO PRIMARY KEY (id_medicamento),
    CONSTRAINT UQ_MEDICAMENTO_CODIGO UNIQUE (codigo),
    CONSTRAINT UQ_MEDICAMENTO_NOMBRE_PRESENTACION UNIQUE (nombre, presentacion),
    CONSTRAINT CK_MEDICAMENTO_PRECIO_VENTA CHECK (precio_venta > 0),
    CONSTRAINT CK_MEDICAMENTO_REQUIERE_FORMULA CHECK (requiere_formula IN ('S','N'))
) ENGINE=InnoDB COMMENT='Catálogo de medicamentos e insumos veterinarios con su precio de venta vigente.';

-- PRESCRIPCION: Resuelve la relación N:M PRESCRIBIR entre CONSULTA y MEDICAMENTO (fórmula médica).
CREATE TABLE PRESCRIPCION (
    id_consulta       BIGINT NOT NULL COMMENT 'Consulta en la que se formula.',
    id_medicamento    INT NOT NULL COMMENT 'Medicamento formulado.',
    dosis             VARCHAR(60) NOT NULL COMMENT 'Dosis por toma.',
    frecuencia_horas  INT NOT NULL COMMENT 'Cada cuántas horas se administra.',
    duracion_dias     INT NOT NULL COMMENT 'Días de tratamiento.',
    cantidad          INT NOT NULL COMMENT 'Unidades a dispensar.',
    indicaciones      VARCHAR(200) COMMENT 'Indicaciones adicionales.',
    CONSTRAINT PK_PRESCRIPCION PRIMARY KEY (id_consulta, id_medicamento),
    CONSTRAINT CK_PRESCRIPCION_FRECUENCIA_HORAS CHECK (frecuencia_horas > 0),
    CONSTRAINT CK_PRESCRIPCION_DURACION_DIAS CHECK (duracion_dias > 0),
    CONSTRAINT CK_PRESCRIPCION_CANTIDAD CHECK (cantidad > 0),
    CONSTRAINT FK_PRESCRIPCION_CONSULTA FOREIGN KEY (id_consulta) REFERENCES CONSULTA (id_consulta) ON DELETE CASCADE,
    CONSTRAINT FK_PRESCRIPCION_MEDICAMENTO FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO (id_medicamento)
) ENGINE=InnoDB COMMENT='Resuelve la relación N:M PRESCRIBIR entre CONSULTA y MEDICAMENTO (fórmula médica).';

-- INVENTARIO: Resuelve la relación N:M ALMACENAR entre SEDE y MEDICAMENTO: existencias por sede.
CREATE TABLE INVENTARIO (
    id_sede              INT NOT NULL COMMENT 'Sede que almacena.',
    id_medicamento       INT NOT NULL COMMENT 'Medicamento almacenado.',
    stock_actual         INT NOT NULL COMMENT 'Unidades disponibles.',
    stock_minimo         INT NOT NULL COMMENT 'Punto de reorden.',
    fecha_actualizacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha del último movimiento o conteo.',
    CONSTRAINT PK_INVENTARIO PRIMARY KEY (id_sede, id_medicamento),
    CONSTRAINT CK_INVENTARIO_STOCK_ACTUAL CHECK (stock_actual >= 0),
    CONSTRAINT CK_INVENTARIO_STOCK_MINIMO CHECK (stock_minimo >= 0),
    CONSTRAINT FK_INVENTARIO_SEDE FOREIGN KEY (id_sede) REFERENCES SEDE (id_sede),
    CONSTRAINT FK_INVENTARIO_MEDICAMENTO FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO (id_medicamento)
) ENGINE=InnoDB COMMENT='Resuelve la relación N:M ALMACENAR entre SEDE y MEDICAMENTO: existencias por sede.';

-- FACTURA: Documento de venta emitido a un cliente en una sede. El total es derivado (vista V_FACTURA_TOTAL).
CREATE TABLE FACTURA (
    id_factura      BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Identificador de la factura.',
    numero_factura  VARCHAR(15) NOT NULL COMMENT 'Consecutivo legible de facturación.',
    fecha_emision   DATETIME NOT NULL COMMENT 'Fecha y hora de emisión.',
    metodo_pago     VARCHAR(16) NOT NULL COMMENT 'Medio de pago.',
    estado          VARCHAR(10) NOT NULL DEFAULT 'PAGADA' COMMENT 'Estado de la factura.',
    id_cliente      INT NOT NULL COMMENT 'Cliente al que se factura.',
    id_sede         INT NOT NULL COMMENT 'Sede que emite la factura.',
    id_empleado     INT NOT NULL COMMENT 'Empleado que emite la factura.',
    CONSTRAINT PK_FACTURA PRIMARY KEY (id_factura),
    CONSTRAINT UQ_FACTURA_NUMERO_FACTURA UNIQUE (numero_factura),
    CONSTRAINT CK_FACTURA_METODO_PAGO CHECK (metodo_pago IN ('EFECTIVO','TARJETA_DEBITO','TARJETA_CREDITO','TRANSFERENCIA')),
    CONSTRAINT CK_FACTURA_ESTADO CHECK (estado IN ('PAGADA','PENDIENTE','ANULADA')),
    CONSTRAINT FK_FACTURA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente),
    CONSTRAINT FK_FACTURA_SEDE FOREIGN KEY (id_sede) REFERENCES SEDE (id_sede),
    CONSTRAINT FK_FACTURA_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado)
) ENGINE=InnoDB COMMENT='Documento de venta emitido a un cliente en una sede. El total es derivado (vista V_FACTURA_TOTAL).';

-- DETALLE_FACTURA: Entidad débil de FACTURA: cada línea cobra un servicio O un medicamento (arco exclusivo).
CREATE TABLE DETALLE_FACTURA (
    id_factura       BIGINT NOT NULL COMMENT 'Factura a la que pertenece la línea (parte de la llave).',
    num_linea        INT NOT NULL COMMENT 'Número de línea dentro de la factura (llave parcial).',
    id_servicio      INT COMMENT 'Servicio cobrado (excluyente con id_medicamento).',
    id_medicamento   INT COMMENT 'Medicamento vendido (excluyente con id_servicio).',
    cantidad         INT NOT NULL COMMENT 'Cantidad facturada.',
    precio_unitario  DECIMAL(10,2) NOT NULL COMMENT 'Precio aplicado en la fecha de la venta (histórico, no derivado).',
    descuento_pct    DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT 'Porcentaje de descuento aplicado.',
    CONSTRAINT PK_DETALLE_FACTURA PRIMARY KEY (id_factura, num_linea),
    CONSTRAINT CK_DETALLE_FACTURA_NUM_LINEA CHECK (num_linea > 0),
    CONSTRAINT CK_DETALLE_FACTURA_CANTIDAD CHECK (cantidad > 0),
    CONSTRAINT CK_DETALLE_FACTURA_PRECIO_UNITARIO CHECK (precio_unitario >= 0),
    CONSTRAINT CK_DETALLE_FACTURA_DESCUENTO_PCT CHECK (descuento_pct BETWEEN 0 AND 100),
    CONSTRAINT CK_DETALLE_FACTURA_ITEM CHECK ((id_servicio IS NOT NULL AND id_medicamento IS NULL) OR (id_servicio IS NULL AND id_medicamento IS NOT NULL)),
    CONSTRAINT FK_DETALLE_FACTURA_FACTURA FOREIGN KEY (id_factura) REFERENCES FACTURA (id_factura) ON DELETE CASCADE,
    CONSTRAINT FK_DETALLE_FACTURA_SERVICIO FOREIGN KEY (id_servicio) REFERENCES SERVICIO (id_servicio),
    CONSTRAINT FK_DETALLE_FACTURA_MEDICAMENTO FOREIGN KEY (id_medicamento) REFERENCES MEDICAMENTO (id_medicamento)
) ENGINE=InnoDB COMMENT='Entidad débil de FACTURA: cada línea cobra un servicio O un medicamento (arco exclusivo).';

-- Relación circular SEDE - EMPLEADO: se agrega cuando las dos tablas ya existen.
ALTER TABLE SEDE ADD CONSTRAINT FK_SEDE_DIRECTOR FOREIGN KEY (id_director) REFERENCES EMPLEADO (id_empleado);
