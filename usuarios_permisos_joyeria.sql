-- Crear usuario admin_taller (Acceso a personal)
CREATE USER 'admin_taller'@'localhost' IDENTIFIED BY 'TallerAdmin2025!'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;
GRANT ALL PRIVILEGES ON jewelry_workshop.asesor TO 'admin_taller'@'localhost';
GRANT ALL PRIVILEGES ON jewelry_workshop.maestro TO 'admin_taller'@'localhost';
GRANT ALL PRIVILEGES ON jewelry_workshop.admin TO 'admin_taller'@'localhost';

-- Crear usuario analista_ventas (Solo lectura)
CREATE USER 'analista_ventas'@'localhost' IDENTIFIED BY 'AnalisisVentas2025!'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;
GRANT SELECT ON jewelry_workshop.* TO 'analista_ventas'@'localhost';

-- Crear usuario asesor_junior (Operaciones de ventas)
-- 1. Crear el usuario solo con la contraseña
CREATE USER 'asesor_junior'@'localhost' IDENTIFIED BY 'AsesorJoven2025!';

-- 2. Configurar la política de expiración y desbloquear la cuenta
-- Esto aborda el error 1064 al separar las cláusulas.
ALTER USER 'asesor_junior'@'localhost'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;

-- 3. Otorgar permisos de SELECT, INSERT y UPDATE en la tabla 'pedido'
GRANT SELECT, INSERT, UPDATE ON jewelry_workshop.pedido TO 'asesor_junior'@'localhost';
-- 4. Otorgar permisos de SELECT, INSERT y UPDATE en la tabla 'cotizacion'
GRANT SELECT, INSERT, UPDATE ON jewelry_workshop.cotizacion TO 'asesor_junior'@'localhost';
-- 5. Otorgar permisos de SOLO LECTURA en tablas de referencia (cliente, diseno)
GRANT SELECT ON jewelry_workshop.cliente TO 'asesor_junior'@'localhost';
GRANT SELECT ON jewelry_workshop.diseno TO 'asesor_junior'@'localhost';

-- Aplicar los cambios de privilegios
FLUSH PRIVILEGES;

-- NOTA: La política de expiración se configura en la sentencia CREATE USER.