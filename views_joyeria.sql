-- 3.1. Vista 'pedidos_publico' (Oculta datos sensibles/internos como las cédulas)
CREATE OR REPLACE VIEW pedidos_publico AS
SELECT
    p.id_pedido,
    c.nombres AS nombre_cliente,
    c.apellidos AS apellido_cliente,
    p.descripcion,
    p.estado,
    p.fecha_creacion,
    a.nombres AS nombre_asesor
FROM
    pedido p
JOIN
    cliente c ON p.id_cliente = c.id_cliente
JOIN
    asesor a ON p.id_asesor = a.id_asesor;

-- 3.2. Vista 'resumen_cotizaciones_por_asesor' (Estadísticas agregadas)
CREATE OR REPLACE VIEW resumen_cotizaciones_por_asesor AS
SELECT
    a.nombres,
    a.apellidos,
    COUNT(c.id_cotizacion) AS total_cotizaciones,
    SUM(CASE WHEN c.estado = 'Aprobada' THEN 1 ELSE 0 END) AS cotizaciones_aprobadas,
    -- Usamos FORMAT(AVG(), 0) para redondear el monto promedio a un entero legible
    FORMAT(AVG(c.monto), 0) AS monto_promedio_cotizacion 
FROM
    asesor a
LEFT JOIN
    pedido p ON a.id_asesor = p.id_asesor
LEFT JOIN
    cotizacion c ON p.id_pedido = c.id_pedido
GROUP BY
    a.id_asesor, a.nombres, a.apellidos;

-- 3.3. Vista 'pedidos_pendientes_aprobacion' (con CHECK OPTION para validar inserciones/actualizaciones)
-- Solo se pueden ver/modificar pedidos en estado 'Creado' o 'Cotizado'
CREATE OR REPLACE VIEW pedidos_pendientes_aprobacion AS
SELECT
    id_pedido, id_cliente, id_asesor, descripcion, estado
FROM
    pedido
WHERE
    estado IN ('Creado', 'Cotizado')
WITH CHECK OPTION;