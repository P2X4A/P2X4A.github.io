Bases de Datos I — MER: Evaluación y Corrección 

# **<mark>TALLER 2</mark>** 

### **Sistema de Gestión de una Tienda en Línea (E-commerce)** 

## 1. Reglas de negocio 

- Un cliente puede realizar muchos pedidos, pero cada pedido pertenece a un solo cliente (relación 1:N entre CLIENTE y PEDIDO). 

- Un pedido puede tener varios productos, y un producto puede aparecer en varios pedidos (relación N:M entre PEDIDO y PRODUCTO, resuelta con la entidad asociativa DETALLE_PEDIDO, que registra cantidad, precio unitario y subtotal). 

- Un producto pertenece a una sola categoría, pero una categoría puede tener muchos productos (relación 1:N entre CATEGORIA y PRODUCTO). 

- Un pedido tiene un único pago asociado, y un pago corresponde a un único pedido (relación 1:1 entre PEDIDO y PAGO). 

- Un pedido tiene un único envío asociado, y un envío corresponde a un único pedido (relación 1:1 entre PEDIDO y ENVIO). 

## 2. Imagen del MER evaluado y corregido 



<!-- Start of picture text -->
MER corregido — Sistema de Gestién de una Tienda en Linea (E-commerce)<br>cuenre PeDIDo<br>CCATEGORIA correcclones apteadas<br><!-- End of picture text -->

_MER corregido del sistema de tienda en línea_ 

## 3. Consultas MySQL: creación de la base de datos 

CREATE DATABASE tienda_online; USE tienda_online; CREATE TABLE categoria ( 

Página 6 

Bases de Datos I — MER: Evaluación y Corrección 

id_categoria  INT AUTO_INCREMENT PRIMARY KEY, nombre        VARCHAR(50) NOT NULL, descripcion   TEXT ); CREATE TABLE cliente ( id_cliente      INT AUTO_INCREMENT PRIMARY KEY, nombre          VARCHAR(50) NOT NULL, apellido        VARCHAR(50) NOT NULL, documento       VARCHAR(20) NOT NULL UNIQUE, correo          VARCHAR(100) NOT NULL, telefono        VARCHAR(20), direccion       VARCHAR(150), fecha_registro  DATE ); CREATE TABLE producto ( id_producto   INT AUTO_INCREMENT PRIMARY KEY, nombre        VARCHAR(100) NOT NULL, descripcion   TEXT, precio        DECIMAL(10,2) NOT NULL, stock         INT NOT NULL DEFAULT 0, id_categoria  INT, FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ); 

Página 7 

Bases de Datos I — MER: Evaluación y Corrección 

CREATE TABLE pedido ( id_pedido      INT AUTO_INCREMENT PRIMARY KEY, id_cliente     INT NOT NULL, fecha_pedido   DATETIME NOT NULL, estado         ENUM('Pendiente','Enviado','Entregado','Cancelado') DEFAULT 'Pendiente', total          DECIMAL(10,2), FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ); -- Entidad asociativa: resuelve la relación N:M entre PEDIDO y PRODUCTO CREATE TABLE detalle_pedido ( id_detalle        INT AUTO_INCREMENT PRIMARY KEY, id_pedido         INT NOT NULL, id_producto       INT NOT NULL, cantidad          INT NOT NULL, precio_unitario   DECIMAL(10,2) NOT NULL, subtotal          DECIMAL(10,2), FOREIGN KEY (id_pedido)   REFERENCES pedido(id_pedido), FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ); 

-- id_pedido es UNIQUE: garantiza la cardinalidad 1:1 con PEDIDO CREATE TABLE pago ( id_pago       INT AUTO_INCREMENT PRIMARY KEY, id_pedido     INT NOT NULL UNIQUE, metodo_pago   VARCHAR(50) NOT NULL, fecha_pago    DATETIME, monto         DECIMAL(10,2) NOT NULL, estado        ENUM('Aprobado','Rechazado','Pendiente') DEFAULT 'Pendiente', FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ); 

-- id_pedido es UNIQUE: garantiza la cardinalidad 1:1 con PEDIDO CREATE TABLE envio ( id_envio        INT AUTO_INCREMENT PRIMARY KEY, id_pedido       INT NOT NULL UNIQUE, empresa         VARCHAR(50), numero_guia     VARCHAR(30), fecha_envio     DATE, fecha_entrega   DATE, estado          ENUM('En camino','Entregado','En espera') DEFAULT 'En espera', FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ); 

Página 8 

Bases de Datos I — MER: Evaluación y Corrección 

## 4. Inserción de datos (mínimo 5 registros por tabla) 

INSERT INTO categoria (nombre, descripcion) VALUES 

- ('Electrónica','Dispositivos electrónicos'), 

- ('Ropa','Ropa y accesorios'), 

- ('Hogar','Productos para el hogar'), 

- ('Deportes','Artículos deportivos'), 

- ('Libros','Libros y material de lectura'); 

INSERT INTO cliente (nombre, apellido, documento, correo, telefono, direccion, fecha_registro) VALUES ('Juan','Pérez','2001112233','juan.perez@correo.com','3101112233','Calle 10 #5-20, Bogotá','2023-01-10'), ('María','López','2002223344','maria.lopez@correo.com','3102223344','Carrera 15 #40-30, Medellín','2023-02-15'), ('Andrés','Castro','2003334455','andres.castro@correo.com','3103334455','Av. Siempreviva 45, Cali','2022-11-20'), ('Sofía','Rojas','2004445566','sofia.rojas@correo.com','3104445566','Calle 80 #12-15, Barranquilla','2023-05-05'), ('Diego','Morales','2005556677','diego.morales@correo.com','3105556677','Carrera 7 #22-10, Bucaramanga','202307-18'); 

INSERT INTO producto (nombre, descripcion, precio, stock, id_categoria) VALUES 

('Audífonos Bluetooth','Audífonos inalámbricos con cancelación de ruido',150000.00,50,1), 

- ('Camiseta deportiva','Camiseta transpirable talla M',45000.00,100,2), 

- ('Juego de sábanas','Juego de sábanas 100% algodón',90000.00,30,3), 

- ('Balón de fútbol','Balón profesional talla 5',70000.00,40,4), ('Novela: Cien años de soledad','Edición de tapa dura',55000.00,25,5); 

Página 9 

Bases de Datos I — MER: Evaluación y Corrección 

INSERT INTO pedido (id_cliente, fecha_pedido, estado, total) VALUES (1,'2024-03-01 10:15:00','Entregado',195000.00), (2,'2024-03-05 14:30:00','Enviado',45000.00), (3,'2024-03-10 09:00:00','Pendiente',70000.00), (4,'2024-03-12 16:45:00','Cancelado',90000.00), (5,'2024-03-15 11:20:00','Entregado',55000.00); 

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES (1,1,1,150000.00,150000.00), (1,2,1,45000.00,45000.00), (2,2,1,45000.00,45000.00), (3,4,1,70000.00,70000.00), (4,3,1,90000.00,90000.00), (5,5,1,55000.00,55000.00); 

Página 10 

Bases de Datos I — MER: Evaluación y Corrección 

INSERT INTO pago (id_pedido, metodo_pago, fecha_pago, monto, estado) VALUES (1,'Tarjeta de crédito','2024-03-01 10:20:00',195000.00,'Aprobado'), (2,'PSE','2024-03-05 14:35:00',45000.00,'Aprobado'), (3,'Tarjeta de débito','2024-03-10 09:05:00',70000.00,'Pendiente'), (4,'Tarjeta de crédito','2024-03-12 16:50:00',90000.00,'Rechazado'), (5,'PSE','2024-03-15 11:25:00',55000.00,'Aprobado'); 

INSERT INTO envio (id_pedido, empresa, numero_guia, fecha_envio, fecha_entrega, estado) VALUES (1,'Servientrega','SE123456789','2024-03-02','2024-03-05','Entregado'), (2,'Coordinadora','CO987654321','2024-03-06',NULL,'En camino'), 

(3,'Interrapidísimo','IR555666777',NULL,NULL,'En espera'), (4,'Servientrega','SE000000000',NULL,NULL,'En espera'), 

(5,'Coordinadora','CO111222333','2024-03-16','2024-03-19','Entregado'); 

Página 11 

