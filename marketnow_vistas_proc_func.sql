-- ============================================================
--  MarketNow — Vistas, Procedimientos Almacenados y Funciones
--  10 ejercicios
-- ============================================================

-- ============================================================
--  VISTAS (1-4)
-- ============================================================

-- 1. Vista: resumen de ventas por mes
CREATE VIEW v_ventas_mensuales AS
SELECT
    DATE_TRUNC('month', p.fecha_pedido) AS mes,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(pa.monto) AS ingresos_totales,
    ROUND(AVG(pa.monto), 2) AS ticket_promedio
FROM pedido p
JOIN pago pa ON p.id_pedido = pa.id_pedido
WHERE pa.estado = 'aprobado'
GROUP BY DATE_TRUNC('month', p.fecha_pedido)
ORDER BY mes;


-- 2. Vista: productos con su vendedor, categoria y stock
CREATE VIEW v_catalogo_productos AS
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.precio,
    p.stock,
    cat.nombre AS categoria,
    v.nombre_tienda AS vendedor
FROM producto p
JOIN categoria cat ON p.id_categoria = cat.id_categoria
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
WHERE p.activo = TRUE
ORDER BY cat.nombre, p.nombre;


-- 3. Vista: detalle completo de pedidos
CREATE VIEW v_detalle_pedidos AS
SELECT
    p.id_pedido,
    c.nombre AS cliente,
    c.email,
    p.fecha_pedido,
    p.estado AS estado_pedido,
    pr.nombre AS producto,
    dp.cantidad,
    dp.precio_unitario,
    (dp.cantidad * dp.precio_unitario) AS subtotal,
    pa.metodo AS metodo_pago,
    pa.estado AS estado_pago,
    e.transportista,
    e.estado AS estado_envio
FROM pedido p
JOIN cliente c ON p.id_cliente = c.id_cliente
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
JOIN producto pr ON dp.id_producto = pr.id_producto
JOIN pago pa ON p.id_pedido = pa.id_pedido
LEFT JOIN envio e ON p.id_pedido = e.id_pedido;


-- 4. Vista: clientes con su gasto total y segmento
CREATE VIEW v_resumen_clientes AS
SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    COUNT(p.id_pedido) AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS gasto_total,
    CASE
        WHEN COUNT(p.id_pedido) >= 3 THEN 'VIP'
        WHEN COUNT(p.id_pedido) = 2  THEN 'Recurrente'
        ELSE 'Nuevo'
    END AS segmento
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
    AND p.estado != 'cancelado'
GROUP BY c.id_cliente, c.nombre, c.email;


-- ============================================================
--  FUNCIONES (5-7)
-- ============================================================

-- 5. Funcion: calcular el total gastado por un cliente
CREATE OR REPLACE FUNCTION fn_total_cliente(p_id_cliente INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(pa.monto), 0)
    INTO v_total
    FROM pedido p
    JOIN pago pa ON p.id_pedido = pa.id_pedido
    WHERE p.id_cliente = p_id_cliente
      AND pa.estado = 'aprobado';

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;


-- 6. Funcion: obtener la calificacion promedio de un producto
CREATE OR REPLACE FUNCTION fn_calificacion_producto(p_id_producto INT)
RETURNS NUMERIC AS $$
DECLARE
    v_promedio NUMERIC;
BEGIN
    SELECT ROUND(AVG(calificacion), 1)
    INTO v_promedio
    FROM resena
    WHERE id_producto = p_id_producto;

    IF v_promedio IS NULL THEN
        RETURN 0;
    END IF;

    RETURN v_promedio;
END;
$$ LANGUAGE plpgsql;


-- 7. Funcion: verificar si un cliente puede reseñar un producto
CREATE OR REPLACE FUNCTION fn_puede_resenar(p_id_cliente INT, p_id_producto INT)
RETURNS BOOLEAN AS $$
DECLARE
    v_compro INT;
    v_ya_reseno INT;
BEGIN
    -- Verificar si compro el producto
    SELECT COUNT(*)
    INTO v_compro
    FROM pedido p
    JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    WHERE p.id_cliente = p_id_cliente
      AND dp.id_producto = p_id_producto
      AND p.estado = 'entregado';

    -- Verificar si ya dejo resena
    SELECT COUNT(*)
    INTO v_ya_reseno
    FROM resena
    WHERE id_cliente = p_id_cliente
      AND id_producto = p_id_producto;

    IF v_compro > 0 AND v_ya_reseno = 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
--  PROCEDIMIENTOS ALMACENADOS (8-10)
-- ============================================================

-- 8. Procedimiento: registrar un nuevo pedido completo
CREATE OR REPLACE PROCEDURE sp_registrar_pedido(
    p_id_cliente    INT,
    p_id_direccion  INT,
    p_id_producto   INT,
    p_cantidad      INT,
    p_metodo_pago   VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE
    v_precio        NUMERIC;
    v_stock         INT;
    v_id_pedido     INT;
    v_total         NUMERIC;
BEGIN
    -- Verificar stock disponible
    SELECT precio, stock INTO v_precio, v_stock
    FROM producto
    WHERE id_producto = p_id_producto AND activo = TRUE;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Producto no encontrado o inactivo';
    END IF;

    IF v_stock < p_cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %', v_stock;
    END IF;

    v_total := v_precio * p_cantidad;

    -- Crear el pedido
    INSERT INTO pedido (id_cliente, id_direccion, fecha_pedido, estado, total)
    VALUES (p_id_cliente, p_id_direccion, CURRENT_TIMESTAMP, 'pendiente', v_total)
    RETURNING id_pedido INTO v_id_pedido;

    -- Agregar el detalle
    INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    VALUES (v_id_pedido, p_id_producto, p_cantidad, v_precio);

    -- Registrar el pago
    INSERT INTO pago (id_pedido, metodo, monto, estado, fecha_pago)
    VALUES (v_id_pedido, p_metodo_pago, v_total, 'aprobado', CURRENT_TIMESTAMP);

    -- Descontar stock
    UPDATE producto
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;

    RAISE NOTICE 'Pedido % registrado correctamente por S/ %', v_id_pedido, v_total;
END;
$$;



-- 9. Procedimiento: actualizar estado de un envio
CREATE OR REPLACE PROCEDURE sp_actualizar_envio(
    p_id_pedido     INT,
    p_nuevo_estado  VARCHAR,
    p_numero_guia   VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_estado_actual VARCHAR;
BEGIN
    SELECT estado INTO v_estado_actual
    FROM envio
    WHERE id_pedido = p_id_pedido;

    IF v_estado_actual IS NULL THEN
        RAISE EXCEPTION 'No existe envio para el pedido %', p_id_pedido;
    END IF;

    -- Actualizar envio
    UPDATE envio
    SET estado = p_nuevo_estado,
        numero_guia = COALESCE(p_numero_guia, numero_guia),
        fecha_despacho = CASE
            WHEN p_nuevo_estado = 'despachado' THEN CURRENT_DATE
            ELSE fecha_despacho
        END,
        fecha_entrega_est = CASE
            WHEN p_nuevo_estado = 'despachado' THEN CURRENT_DATE + 3
            ELSE fecha_entrega_est
        END
    WHERE id_pedido = p_id_pedido;

    -- Si se entrego, actualizar tambien el pedido
    IF p_nuevo_estado = 'entregado' THEN
        UPDATE pedido
        SET estado = 'entregado'
        WHERE id_pedido = p_id_pedido;
    END IF;

    RAISE NOTICE 'Envio del pedido % actualizado a: %', p_id_pedido, p_nuevo_estado;
END;
$$;


-- 10. Procedimiento: reporte de ventas por vendedor en un rango de fechas
CREATE OR REPLACE PROCEDURE sp_reporte_vendedor(
    p_id_vendedor   INT,
    p_fecha_inicio  DATE,
    p_fecha_fin     DATE
)
LANGUAGE plpgsql AS $$
DECLARE
    v_nombre_tienda VARCHAR;
    v_total_ventas  NUMERIC;
    v_total_pedidos INT;
    v_producto_top  VARCHAR;
BEGIN
    SELECT nombre_tienda INTO v_nombre_tienda
    FROM vendedor WHERE id_vendedor = p_id_vendedor;

    IF v_nombre_tienda IS NULL THEN
        RAISE EXCEPTION 'Vendedor % no encontrado', p_id_vendedor;
    END IF;

    SELECT
        COUNT(DISTINCT ped.id_pedido),
        SUM(dp.cantidad * dp.precio_unitario)
    INTO v_total_pedidos, v_total_ventas
    FROM vendedor v
    JOIN producto p ON v.id_vendedor = p.id_vendedor
    JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
    JOIN pedido ped ON dp.id_pedido = ped.id_pedido
    WHERE v.id_vendedor = p_id_vendedor
      AND ped.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
      AND ped.estado != 'cancelado';

    SELECT p.nombre INTO v_producto_top
    FROM producto p
    JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
    JOIN pedido ped ON dp.id_pedido = ped.id_pedido
    WHERE p.id_vendedor = p_id_vendedor
      AND ped.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY p.id_producto, p.nombre
    ORDER BY SUM(dp.cantidad) DESC
    LIMIT 1;

    RAISE NOTICE '====== Reporte de Ventas ======';
    RAISE NOTICE 'Vendedor    : %', v_nombre_tienda;
    RAISE NOTICE 'Periodo     : % al %', p_fecha_inicio, p_fecha_fin;
    RAISE NOTICE 'Pedidos     : %', COALESCE(v_total_pedidos, 0);
    RAISE NOTICE 'Total ventas: S/ %', COALESCE(v_total_ventas, 0);
    RAISE NOTICE 'Producto top: %', COALESCE(v_producto_top, 'Sin ventas');
    RAISE NOTICE '================================';
END;
$$;
