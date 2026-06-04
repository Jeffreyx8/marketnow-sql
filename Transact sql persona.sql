-- ============================================================
--  MarketNow — 20 Consultas Transact-SQL
-- ============================================================

-- ============================================================
--  BASICAS E INTERMEDIAS (1-10)
-- ============================================================

-- 1. Listar todos los clientes registrados
SELECT
    id_cliente,
    nombre,
    email,
    telefono,
    fecha_registro
FROM cliente
ORDER BY fecha_registro ASC;

-- 2. Productos con stock menor a 30 unidades
SELECT
    id_producto,
    nombre,
    precio,
    stock
FROM producto
WHERE stock < 30 AND activo = TRUE
ORDER BY stock ASC;

-- 3. Total de pedidos por estado
SELECT
    estado,
    COUNT(*) AS cantidad_pedidos,
    SUM(total) AS monto_total
FROM pedido
GROUP BY estado
ORDER BY cantidad_pedidos DESC;

-- 4. Clientes con su cantidad de pedidos
SELECT
    c.nombre,
    c.email,
    COUNT(p.id_pedido) AS total_pedidos
FROM cliente c
LEFT JOIN pedido p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre, c.email
ORDER BY total_pedidos DESC;

-- 5. Productos mas caros por categoria
SELECT
    cat.nombre AS categoria,
    p.nombre AS producto,
    p.precio
FROM producto p
JOIN categoria cat ON p.id_categoria = cat.id_categoria
WHERE cat.id_categoria_padre IS NOT NULL
ORDER BY cat.nombre, p.precio DESC;

-- 6. Pedidos entregados en el primer trimestre 2025
SELECT
    p.id_pedido,
    c.nombre AS cliente,
    p.fecha_pedido,
    p.total
FROM pedido p
JOIN cliente c ON p.id_cliente = c.id_cliente
WHERE p.estado = 'entregado'
  AND p.fecha_pedido BETWEEN '2025-01-01' AND '2025-03-31'
ORDER BY p.fecha_pedido;

-- 7. Ingresos totales por metodo de pago
SELECT
    pa.metodo,
    COUNT(*) AS cantidad_pagos,
    SUM(pa.monto) AS ingreso_total
FROM pago pa
WHERE pa.estado = 'aprobado'
GROUP BY pa.metodo
ORDER BY ingreso_total DESC;

-- 8. Clientes que tienen mas de una direccion registrada
SELECT
    c.nombre,
    c.email,
    COUNT(d.id_direccion) AS total_direcciones
FROM cliente c
JOIN direccion d ON c.id_cliente = d.id_cliente
GROUP BY c.id_cliente, c.nombre, c.email
HAVING COUNT(d.id_direccion) > 1
ORDER BY total_direcciones DESC;

-- 9. Productos vendidos con su vendedor y categoria
SELECT DISTINCT
    v.nombre_tienda AS vendedor,
    cat.nombre AS categoria,
    p.nombre AS producto,
    p.precio
FROM detalle_pedido dp
JOIN producto p ON dp.id_producto = p.id_producto
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
JOIN categoria cat ON p.id_categoria = cat.id_categoria
ORDER BY v.nombre_tienda, cat.nombre;

-- 10. Resumen mensual de ventas 2025
SELECT
    DATE_TRUNC('month', p.fecha_pedido) AS mes,
    COUNT(p.id_pedido) AS pedidos,
    SUM(pa.monto) AS ingresos
FROM pedido p
JOIN pago pa ON p.id_pedido = pa.id_pedido
WHERE pa.estado = 'aprobado'
  AND EXTRACT(YEAR FROM p.fecha_pedido) = 2025
GROUP BY DATE_TRUNC('month', p.fecha_pedido)
ORDER BY mes;

-- ============================================================
--  AVANZADAS Y EXPERTAS (11-20)
-- ============================================================

-- 11. Top 5 clientes por monto gastado

SELECT
    c.nombre,
    c.email,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(pa.monto) AS total_gastado
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
JOIN pago pa ON p.id_pedido = pa.id_pedido
WHERE pa.estado = 'aprobado'
  AND p.estado IN ('pagado', 'enviado', 'entregado')
GROUP BY c.id_cliente, c.nombre, c.email
ORDER BY total_gastado DESC
LIMIT 5;

-- 12. Top 10 productos mas vendidos por unidades
SELECT
    p.nombre AS producto,
    v.nombre_tienda AS vendedor,
    SUM(dp.cantidad) AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio_unitario) AS ingreso_generado
FROM detalle_pedido dp
JOIN producto p ON dp.id_producto = p.id_producto
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
GROUP BY p.id_producto, p.nombre, v.nombre_tienda
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 13. Vendedores que no tienen ninguna venta registrada
SELECT
    v.id_vendedor,
    v.nombre_tienda,
    v.email,
    v.fecha_registro
FROM vendedor v
LEFT JOIN producto p ON v.id_vendedor = p.id_vendedor
LEFT JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
WHERE dp.id_detalle IS NULL
ORDER BY v.fecha_registro;

-- 14. Ticket promedio de compra por cliente
SELECT
    c.nombre,
    COUNT(p.id_pedido) AS pedidos_realizados,
    ROUND(AVG(p.total), 2) AS ticket_promedio,
    SUM(p.total) AS gasto_total
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
WHERE p.estado != 'cancelado'
GROUP BY c.id_cliente, c.nombre
ORDER BY ticket_promedio DESC;

-- 15. Productos sin ventas (nunca aparecieron en un pedido)
SELECT
    p.id_producto,
    p.nombre,
    p.precio,
    p.stock,
    v.nombre_tienda
FROM producto p
LEFT JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
WHERE dp.id_detalle IS NULL AND p.activo = TRUE
ORDER BY p.id_producto;

-- 16. Calificacion promedio por producto (con total de resenas)
SELECT
    p.nombre AS producto,
    v.nombre_tienda AS vendedor,
    COUNT(r.id_resena) AS total_resenas,
    ROUND(AVG(r.calificacion), 1) AS calificacion_promedio
FROM producto p
JOIN resena r ON p.id_producto = r.id_producto
JOIN vendedor v ON p.id_vendedor = v.id_vendedor
GROUP BY p.id_producto, p.nombre, v.nombre_tienda
HAVING COUNT(r.id_resena) >= 1
ORDER BY calificacion_promedio DESC, total_resenas DESC;

-- 17. Clientes que compraron en mas de una categoria distinta
SELECT
    c.nombre,
    c.email,
    COUNT(DISTINCT cat.id_categoria) AS categorias_distintas,
    STRING_AGG(DISTINCT cat.nombre, ', ') AS categorias
FROM cliente c
JOIN pedido p ON c.id_cliente = p.id_cliente
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
JOIN producto pr ON dp.id_producto = pr.id_producto
JOIN categoria cat ON pr.id_categoria = cat.id_categoria
GROUP BY c.id_cliente, c.nombre, c.email
HAVING COUNT(DISTINCT cat.id_categoria) > 1
ORDER BY categorias_distintas DESC;

-- 18. Ingreso total por vendedor con su producto estrella
WITH ventas_por_producto AS (
    SELECT
        v.id_vendedor,
        v.nombre_tienda,
        p.nombre AS producto,
        SUM(dp.cantidad * dp.precio_unitario) AS ingreso_producto,
        RANK() OVER (
            PARTITION BY v.id_vendedor
            ORDER BY SUM(dp.cantidad * dp.precio_unitario) DESC
        ) AS ranking
    FROM vendedor v
    JOIN producto p ON v.id_vendedor = p.id_vendedor
    JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
    JOIN pedido ped ON dp.id_pedido = ped.id_pedido
    WHERE ped.estado != 'cancelado'
    GROUP BY v.id_vendedor, v.nombre_tienda, p.id_producto, p.nombre
),
ingreso_total AS (
    SELECT
        v.id_vendedor,
        SUM(dp.cantidad * dp.precio_unitario) AS total_vendido
    FROM vendedor v
    JOIN producto p ON v.id_vendedor = p.id_vendedor
    JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
    JOIN pedido ped ON dp.id_pedido = ped.id_pedido
    WHERE ped.estado != 'cancelado'
    GROUP BY v.id_vendedor
)
SELECT
    vp.nombre_tienda AS vendedor,
    it.total_vendido AS ingreso_total,
    vp.producto AS producto_estrella,
    vp.ingreso_producto AS ingreso_producto_estrella
FROM ventas_por_producto vp
JOIN ingreso_total it ON vp.id_vendedor = it.id_vendedor
WHERE vp.ranking = 1
ORDER BY ingreso_total DESC;

-- 19. Evolucion acumulada de ingresos mes a mes (running total)
WITH ingresos_mensuales AS (
    SELECT
        DATE_TRUNC('month', p.fecha_pedido) AS mes,
        SUM(pa.monto) AS ingreso_mes
    FROM pedido p
    JOIN pago pa ON p.id_pedido = pa.id_pedido
    WHERE pa.estado = 'aprobado'
    GROUP BY DATE_TRUNC('month', p.fecha_pedido)
)
SELECT
    TO_CHAR(mes, 'Month YYYY') AS periodo,
    ingreso_mes,
    SUM(ingreso_mes) OVER (ORDER BY mes) AS ingreso_acumulado
FROM ingresos_mensuales
ORDER BY mes;

-- 20. Clientes con comportamiento VIP
--     (mas de 2 pedidos Y gasto mayor al promedio general)
WITH promedio_general AS (
    SELECT AVG(total) AS promedio
    FROM pedido
    WHERE estado != 'cancelado'
),
resumen_cliente AS (
    SELECT
        c.id_cliente,
        c.nombre,
        c.email,
        COUNT(p.id_pedido) AS total_pedidos,
        SUM(p.total) AS gasto_total,
        ROUND(AVG(p.total), 2) AS ticket_promedio
    FROM cliente c
    JOIN pedido p ON c.id_cliente = p.id_cliente
    WHERE p.estado != 'cancelado'
    GROUP BY c.id_cliente, c.nombre, c.email
)
SELECT
    rc.nombre,
    rc.email,
    rc.total_pedidos,
    rc.gasto_total,
    rc.ticket_promedio,
    CASE
        WHEN rc.total_pedidos >= 3 AND rc.gasto_total > pg.promedio THEN 'VIP Premium'
        WHEN rc.total_pedidos >= 2 AND rc.gasto_total > pg.promedio THEN 'VIP'
        ELSE 'Regular'
    END AS segmento
FROM resumen_cliente rc
CROSS JOIN promedio_general pg
WHERE rc.gasto_total > pg.promedio
ORDER BY rc.gasto_total DESC;

