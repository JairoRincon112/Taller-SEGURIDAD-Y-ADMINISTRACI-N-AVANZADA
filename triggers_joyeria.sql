USE jewelry_workshop;

-- 1. Crear la tabla de auditoría si no existe (asumo que ya la creaste en un paso anterior)
CREATE TABLE IF NOT EXISTS pedidos_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido_afectado INT,
    operacion VARCHAR(10) NOT NULL,
    usuario_bd VARCHAR(100) NOT NULL,
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cambios_anteriores JSON
);

-- 2. Cambiar el delimitador (CRÍTICO para Triggers y Stored Procedures)
DELIMITER //

-- 3. Crear el Trigger AFTER INSERT
CREATE TRIGGER trg_pedido_after_insert
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    INSERT INTO pedidos_audit_log (id_pedido_afectado, operacion, usuario_bd, cambios_anteriores)
    VALUES (
        NEW.id_pedido,
        'INSERT',
        USER(),
        JSON_OBJECT('descripcion', NEW.descripcion, 'estado', NEW.estado)
    );
END;
//

-- 4. Crear el Trigger AFTER UPDATE
CREATE TRIGGER trg_pedido_after_update
AFTER UPDATE ON pedido
FOR EACH ROW
BEGIN
    INSERT INTO pedidos_audit_log (id_pedido_afectado, operacion, usuario_bd, cambios_anteriores)
    VALUES (
        NEW.id_pedido,
        'UPDATE',
        USER(),
        JSON_OBJECT(
            'old_estado', OLD.estado,
            'new_estado', NEW.estado,
            'old_descripcion', OLD.descripcion,
            'new_descripcion', NEW.descripcion
        )
    );
END;
//

-- 5. Crear el Trigger AFTER DELETE
CREATE TRIGGER trg_pedido_after_delete
AFTER DELETE ON pedido
FOR EACH ROW
BEGIN
    INSERT INTO pedidos_audit_log (id_pedido_afectado, operacion, usuario_bd, cambios_anteriores)
    VALUES (
        OLD.id_pedido,
        'DELETE',
        USER(),
        JSON_OBJECT(
            'deleted_descripcion', OLD.descripcion,
            'deleted_estado', OLD.estado,
            'deleted_cliente_id', OLD.id_cliente
        )
    );
END;
//

-- 6. Restaurar el delimitador por defecto (;)
DELIMITER;



-- Pruebas. Ejecutarlas una por una

-- 4.5. Realizar operaciones de prueba y verificar en pedidos_audit_log:

INSERT INTO pedido (id_cliente, id_asesor, descripcion, estado) VALUES (1, 1, 'Anillo de prueba audit', 'Creado');
--
SET @last_id = LAST_INSERT_ID();
--
UPDATE pedido SET estado = 'Fabricacion' WHERE id_pedido = @last_id;
--
DELETE FROM pedido WHERE id_pedido = @last_id;
--
SELECT * FROM pedidos_audit_log WHERE id_pedido_afectado = @last_id;