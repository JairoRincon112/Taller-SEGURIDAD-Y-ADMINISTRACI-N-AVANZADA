-- =========================
-- USUARIO 1: admin_tech
-- =========================
DROP USER IF EXISTS 'admin_tech'@'localhost';

-- 1. Crear usuario solo con contraseña
CREATE USER 'admin_tech'@'localhost' IDENTIFIED BY 'AdminTech2025!';

-- 2. Configurar expiración y desbloqueo
ALTER USER 'admin_tech'@'localhost'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;

-- 3. Otorgar privilegios sobre tablas clave
GRANT ALL PRIVILEGES ON techstore.* TO 'admin_tech'@'localhost';

-- =========================
-- USUARIO 2: analista_ventas
-- =========================
DROP USER IF EXISTS 'analista_ventas'@'localhost';

-- 1. Crear usuario
CREATE USER 'analista_ventas'@'localhost' IDENTIFIED BY 'AnalisisVentas2025!';

-- 2. Política de contraseña
ALTER USER 'analista_ventas'@'localhost'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;

-- 3. Solo lectura de toda la BD
GRANT SELECT ON techstore.* TO 'analista_ventas'@'localhost';



-- =========================
-- USUARIO 3: vendedor_junior
-- =========================
DROP USER IF EXISTS 'vendedor_junior'@'localhost';

-- 1. Crear usuario solo con contraseña
CREATE USER 'vendedor_junior'@'localhost' IDENTIFIED BY 'VendedorJoven2025!';

-- 2. Configurar expiración y desbloqueo
ALTER USER 'vendedor_junior'@'localhost'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;

-- 3. Permisos:
--    - ver productos
--    - crear y actualizar ventas
GRANT SELECT ON techstore.productos TO 'vendedor_junior'@'localhost';
GRANT SELECT, INSERT, UPDATE ON techstore.ventas TO 'vendedor_junior'@'localhost';



-- Aplicar cambios
FLUSH PRIVILEGES;