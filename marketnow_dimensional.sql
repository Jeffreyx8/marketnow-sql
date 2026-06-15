-- ============================================================
--  MarketNow — Modelo Dimensional (Estrella)
--  Tablas de dimensiones + tabla de hechos + datos
-- ============================================================

-- ============================================================
--  DIMENSIONES
-- ============================================================

-- Dimension Tiempo
CREATE TABLE dim_tiempo (
    id_tiempo       SERIAL PRIMARY KEY,
    fecha           DATE NOT NULL,
    anio            INT,
    trimestre       INT,
    mes             INT,
    nombre_mes      VARCHAR(20),
    semana          INT,
    dia             INT,
    nombre_dia      VARCHAR(20),
    es_fin_semana   BOOLEAN
);

INSERT INTO dim_tiempo (fecha, anio, trimestre, mes, nombre_mes, semana, dia, nombre_dia, es_fin_semana)
SELECT
    d::DATE,
    EXTRACT(YEAR FROM d),
    EXTRACT(QUARTER FROM d),
    EXTRACT(MONTH FROM d),
    TO_CHAR(d, 'TMMonth'),
    EXTRACT(WEEK FROM d),
    EXTRACT(DAY FROM d),
    TO_CHAR(d, 'TMDay'),
    EXTRACT(ISODOW FROM d) IN (6, 7)
FROM generate_series('2025-01-01'::DATE, '2025-12-31'::DATE, '1 day') AS d;


-- Dimension Cliente
CREATE TABLE dim_cliente (
    id_dim_cliente  SERIAL PRIMARY KEY,
    id_cliente      INT,
    nombre          VARCHAR(120),
    email           VARCHAR(150),
    ciudad          VARCHAR(80),
    pais            VARCHAR(60),
    fecha_registro  DATE
);

INSERT INTO dim_cliente (id_cliente, nombre, email, ciudad, pais, fecha_registro)
SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    d.ciudad,
    d.pais,
    c.fecha_registro
FROM cliente c
LEFT JOIN direccion d ON c.id_cliente = d.id_cliente AND d.es_principal = TRUE;


-- Dimension Producto
CREATE TABLE dim_producto (
    id_dim_producto SERIAL PRIMARY KEY,
    id_producto     INT,
    nombre          VARCHAR(200),
    categoria       VARCHAR(80),
    subcategoria    VARCHAR(80),
    vendedor        VARCHAR(100),
    precio_actual   NUMERIC(10,2)
);

INSERT INTO dim_producto (id_producto, nombre, categoria, subcategoria, vendedor, precio_actual)
SELECT
    p.id_producto,
    p.nombre,
    CASE WHEN cat.id_categoria_padre IS NULL THEN cat.nombre ELSE cat_padre.nombre END AS categoria,
    CASE WHEN cat.id_categoria_padre IS NOT NULL THEN cat.nombre ELSE NULL END AS subcategoria,
    v.nombre_tienda,
    p.precio
FROM producto p
JOIN categoria cat ON p.id_categoria = cat.id_categoria
LEFT JOIN categoria cat_padre ON cat.id_categoria_padre = cat_padre.id_categoria
JOIN vendedor v ON p.id_vendedor = v.id_vendedor;


-- Dimension Vendedor
CREATE TABLE dim_vendedor (
    id_dim_vendedor SERIAL PRIMARY KEY,
    id_vendedor     INT,
    nombre_tienda   VARCHAR(100),
    ruc             VARCHAR(20),
    fecha_registro  DATE
);

INSERT INTO dim_vendedor (id_vendedor, nombre_tienda, ruc, fecha_registro)
SELECT id_vendedor, nombre_tienda, ruc, fecha_registro
FROM vendedor;


-- Dimension Metodo de Pago
CREATE TABLE dim_pago (
    id_dim_pago     SERIAL PRIMARY KEY,
    metodo          VARCHAR(30),
    tipo            VARCHAR(30)
);

INSERT INTO dim_pago (metodo, tipo) VALUES
('tarjeta',           'Pago electronico'),
('transferencia',     'Pago bancario'),
('billetera_digital', 'Pago electronico');


-- ============================================================
--  TABLA DE HECHOS
-- ============================================================

CREATE TABLE fact_ventas (
    id_fact             SERIAL PRIMARY KEY,
    id_tiempo           INT REFERENCES dim_tiempo(id_tiempo),
    id_dim_cliente      INT REFERENCES dim_cliente(id_dim_cliente),
    id_dim_producto     INT REFERENCES dim_producto(id_dim_producto),
    id_dim_vendedor     INT REFERENCES dim_vendedor(id_dim_vendedor),
    id_dim_pago         INT REFERENCES dim_pago(id_dim_pago),
    id_pedido           INT,
    cantidad            INT,
    precio_unitario     NUMERIC(10,2),
    subtotal            NUMERIC(12,2),
    descuento           NUMERIC(10,2) DEFAULT 0,
    total_neto          NUMERIC(12,2)
);

INSERT INTO fact_ventas (
    id_tiempo, id_dim_cliente, id_dim_producto,
    id_dim_vendedor, id_dim_pago, id_pedido,
    cantidad, precio_unitario, subtotal, descuento, total_neto
)
SELECT
    t.id_tiempo,
    dc.id_dim_cliente,
    dp.id_dim_producto,
    dv.id_dim_vendedor,
    dpago.id_dim_pago,
    ped.id_pedido,
    det.cantidad,
    det.precio_unitario,
    det.cantidad * det.precio_unitario AS subtotal,
    0 AS descuento,
    det.cantidad * det.precio_unitario AS total_neto
FROM detalle_pedido det
JOIN pedido ped ON det.id_pedido = ped.id_pedido
JOIN pago pa ON ped.id_pedido = pa.id_pedido
JOIN dim_tiempo t ON t.fecha = ped.fecha_pedido::DATE
JOIN dim_cliente dc ON dc.id_cliente = ped.id_cliente
JOIN dim_producto dp ON dp.id_producto = det.id_producto
JOIN producto pr ON det.id_producto = pr.id_producto
JOIN dim_vendedor dv ON dv.id_vendedor = pr.id_vendedor
JOIN dim_pago dpago ON dpago.metodo = pa.metodo
WHERE pa.estado = 'aprobado';


-- ============================================================
--  CONSULTAS ANALITICAS SOBRE EL MODELO DIMENSIONAL
-- ============================================================

-- Ventas totales por trimestre
SELECT
    t.anio,
    t.trimestre,
    COUNT(f.id_fact) AS transacciones,
    SUM(f.total_neto) AS ingresos
FROM fact_ventas f
JOIN dim_tiempo t ON f.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.trimestre
ORDER BY t.anio, t.trimestre;

-- Top categorias por ingreso
SELECT
    dp.categoria,
    SUM(f.cantidad) AS unidades,
    SUM(f.total_neto) AS ingresos_totales
FROM fact_ventas f
JOIN dim_producto dp ON f.id_dim_producto = dp.id_dim_producto
GROUP BY dp.categoria
ORDER BY ingresos_totales DESC;

-- Ingresos por metodo de pago y mes
SELECT
    t.nombre_mes,
    dpago.metodo,
    SUM(f.total_neto) AS total
FROM fact_ventas f
JOIN dim_tiempo t ON f.id_tiempo = t.id_tiempo
JOIN dim_pago dpago ON f.id_dim_pago = dpago.id_dim_pago
GROUP BY t.mes, t.nombre_mes, dpago.metodo
ORDER BY t.mes, total DESC;
