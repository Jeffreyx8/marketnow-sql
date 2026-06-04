-- ============================================================
--  MarketNow - Script MySQL Workbench
-- ============================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS marketnow;
USE marketnow;

-- ============================================================
--  1. TABLA VENDEDOR
-- ============================================================
CREATE TABLE vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tienda VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    ruc VARCHAR(20) NOT NULL UNIQUE,
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- ============================================================
--  2. TABLA CATEGORIA
-- ============================================================
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria_padre INT,
    nombre VARCHAR(80) NOT NULL,
    descripcion TEXT,

    CONSTRAINT fk_categoria_padre
        FOREIGN KEY (id_categoria_padre)
        REFERENCES categoria(id_categoria)
        ON DELETE SET NULL
);

-- ============================================================
--  3. TABLA PRODUCTO
-- ============================================================
CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,

    id_vendedor INT NOT NULL,
    id_categoria INT,

    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,

    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,

    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_producto_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id_vendedor)
        ON DELETE CASCADE,

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria(id_categoria)
        ON DELETE SET NULL
);

-- ============================================================
--  4. TABLA CLIENTE
-- ============================================================
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- ============================================================
--  5. TABLA DIRECCION
-- ============================================================
CREATE TABLE direccion (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL,

    calle VARCHAR(200) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    pais VARCHAR(60) NOT NULL,
    codigo_postal VARCHAR(10),

    es_principal BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_direccion_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
);

-- ============================================================
--  6. TABLA PEDIDO
-- ============================================================
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL,
    id_direccion INT NOT NULL,

    fecha_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',

    total DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pedido_direccion
        FOREIGN KEY (id_direccion)
        REFERENCES direccion(id_direccion)
        ON DELETE RESTRICT
);

-- ============================================================
--  7. TABLA DETALLE_PEDIDO
-- ============================================================
CREATE TABLE detalle_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,

    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto)
        ON DELETE RESTRICT,

    CONSTRAINT uq_detalle
        UNIQUE (id_pedido, id_producto)
);

-- ============================================================
--  8. TABLA PAGO
-- ============================================================
CREATE TABLE pago (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL,

    metodo VARCHAR(30) NOT NULL,
    monto DECIMAL(12,2) NOT NULL,

    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',

    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pago_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
);

-- ============================================================
--  9. TABLA ENVIO
-- ============================================================
CREATE TABLE envio (
    id_envio INT AUTO_INCREMENT PRIMARY KEY,

    id_pedido INT NOT NULL,

    transportista VARCHAR(80) NOT NULL,
    numero_guia VARCHAR(60),

    fecha_despacho DATE,
    fecha_entrega_estimada DATE,

    estado VARCHAR(20) NOT NULL DEFAULT 'preparando',

    CONSTRAINT fk_envio_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
);

-- ============================================================
--  10. TABLA RESENA
-- ============================================================
CREATE TABLE resena (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,

    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,

    calificacion INT NOT NULL,
    comentario TEXT,

    fecha_resena TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resena_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE CASCADE,

    CONSTRAINT fk_resena_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto)
        ON DELETE CASCADE,

    CONSTRAINT uq_resena
        UNIQUE (id_cliente, id_producto)
);

-- ============================================================
--  INDICES
-- ============================================================
CREATE INDEX idx_producto_vendedor
ON producto(id_vendedor);

CREATE INDEX idx_producto_categoria
ON producto(id_categoria);

CREATE INDEX idx_pedido_cliente
ON pedido(id_cliente);

CREATE INDEX idx_detalle_pedido
ON detalle_pedido(id_pedido);

CREATE INDEX idx_detalle_producto
ON detalle_pedido(id_producto);

CREATE INDEX idx_pago_pedido
ON pago(id_pedido);

CREATE INDEX idx_envio_pedido
ON envio(id_pedido);

CREATE INDEX idx_resena_producto
ON resena(id_producto);
