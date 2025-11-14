DROP VIEW IF EXISTS ventas_publico;
DROP VIEW IF EXISTS resumen_ventas_por_producto;
DROP VIEW IF EXISTS ventas_con_tarjeta;

-- Vista "ventas_publico"
-- Equivalente a pedidos_publico: muestra info de ventas sin exponer todo el detalle interno
CREATE OR REPLACE VIEW ventas_publico AS
SELECT
    v.id              AS id_venta,
    p.nombre          AS nombre_producto,
    p.categoria       AS categoria_producto,
    v.fecha_venta,
    v.cantidad,
    v.total,
    v.metodo_pago
FROM
    ventas v
    INNER JOIN productos p ON v.id_producto = p.id;



-- Vista "resumen_ventas_por_producto"
-- Equivalente a resumen_cotizaciones_por_asesor: stats agregadas por producto
CREATE OR REPLACE VIEW resumen_ventas_por_producto AS
SELECT
    p.id                     AS id_producto,
    p.nombre                 AS nombre_producto,
    p.categoria,
    COUNT(v.id)              AS total_ventas,
    IFNULL(SUM(v.cantidad), 0) AS unidades_vendidas,
    IFNULL(SUM(v.total), 0)    AS total_ingresos,
    FORMAT(AVG(v.total), 2)    AS ticket_promedio
FROM
    productos p
    LEFT JOIN ventas v ON p.id = v.id_producto
GROUP BY
    p.id, p.nombre, p.categoria;



-- Vista "ventas_con_tarjeta" con CHECK OPTION
-- Equivalente a pedidos_pendientes_aprobacion: restringe a filas que cumplen el WHERE
CREATE OR REPLACE VIEW ventas_con_tarjeta AS
SELECT
    id,
    id_producto,
    fecha_venta,
    cantidad,
    total,
    metodo_pago
FROM
    ventas
WHERE
    metodo_pago = 'tarjeta'
WITH CHECK OPTION;

-- PROBAR LAS VIEWS

SELECT * FROM ventas_publico LIMIT 5;

SELECT * FROM resumen_ventas_por_producto LIMIT 5;

SELECT * FROM ventas_con_tarjeta LIMIT 5;

-- Probar check option

-- Esto debería funcionar (sigue siendo 'tarjeta')
INSERT INTO ventas_con_tarjeta (id_producto, fecha_venta, cantidad, total, metodo_pago)
VALUES (1, NOW(), 1, 123456.78, 'tarjeta');

-- Esto debería FALLAR (rompe el WHERE de la vista)
INSERT INTO ventas_con_tarjeta (id_producto, fecha_venta, cantidad, total, metodo_pago)
VALUES (1, NOW(), 1, 9999.99, 'efectivo');