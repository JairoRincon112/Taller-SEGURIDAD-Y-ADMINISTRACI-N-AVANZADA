-- 1. Tabla de auditoría para ventas
CREATE TABLE IF NOT EXISTS ventas_audit_log (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_venta_afectada INT NOT NULL,
    operacion ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    usuario_bd VARCHAR(100) NOT NULL,
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cambios JSON
);

-- 2. Cambiamos delimitador para poder crear los triggers
DELIMITER //

-- (Opcional) por si ya existen triggers viejos, los borramos
DROP TRIGGER IF EXISTS trg_ventas_after_insert;
//
DROP TRIGGER IF EXISTS trg_ventas_after_update;
//
DROP TRIGGER IF EXISTS trg_ventas_after_delete;
//

-- 3. Trigger AFTER INSERT en ventas
CREATE TRIGGER trg_ventas_after_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO ventas_audit_log (id_venta_afectada, operacion, usuario_bd, cambios)
    VALUES (
        NEW.id,
        'INSERT',
        USER(),
        JSON_OBJECT(
            'id_producto', NEW.id_producto,
            'fecha_venta', NEW.fecha_venta,
            'cantidad', NEW.cantidad,
            'total', NEW.total,
            'metodo_pago', NEW.metodo_pago
        )
    );
END;
//

-- 4. Trigger AFTER UPDATE en ventas
CREATE TRIGGER trg_ventas_after_update
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO ventas_audit_log (id_venta_afectada, operacion, usuario_bd, cambios)
    VALUES (
        NEW.id,
        'UPDATE',
        USER(),
        JSON_OBJECT(
            'old_id_producto', OLD.id_producto,
            'new_id_producto', NEW.id_producto,
            'old_fecha_venta', OLD.fecha_venta,
            'new_fecha_venta', NEW.fecha_venta,
            'old_cantidad', OLD.cantidad,
            'new_cantidad', NEW.cantidad,
            'old_total', OLD.total,
            'new_total', NEW.total,
            'old_metodo_pago', OLD.metodo_pago,
            'new_metodo_pago', NEW.metodo_pago
        )
    );
END;
//

-- 5. Trigger AFTER DELETE en ventas
CREATE TRIGGER trg_ventas_after_delete
AFTER DELETE ON ventas
FOR EACH ROW
BEGIN
    INSERT INTO ventas_audit_log (id_venta_afectada, operacion, usuario_bd, cambios)
    VALUES (
        OLD.id,
        'DELETE',
        USER(),
        JSON_OBJECT(
            'id_producto', OLD.id_producto,
            'fecha_venta', OLD.fecha_venta,
            'cantidad', OLD.cantidad,
            'total', OLD.total,
            'metodo_pago', OLD.metodo_pago
        )
    );
END;
//

-- 6. Restauramos el delimitador normal
DELIMITER ;


-- Prueba de los triggers
-- 1. Crear una venta de prueba
INSERT INTO ventas (id_producto, fecha_venta, cantidad, total, metodo_pago)
VALUES (1, NOW(), 2, 123456.78, 'tarjeta');

SET @last_id := LAST_INSERT_ID();

-- 2. Actualizar la venta
UPDATE ventas
SET cantidad = 3,
    total = 200000.00
WHERE id = @last_id;

-- 3. Eliminar la venta
DELETE FROM ventas
WHERE id = @last_id;

-- 4. Ver la auditoría
SELECT * FROM ventas_audit_log
WHERE id_venta_afectada = @last_id;