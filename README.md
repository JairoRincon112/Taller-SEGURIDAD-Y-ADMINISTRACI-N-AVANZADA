# Taller Práctico Integrador – Bases de Datos

**Tema:** Implementación de Seguridad y Administración Avanzada  
**Proyecto:** *TechStore*  
**Autor:** *Jairo Andrés Rincón Blanco*  
**Docente:** *Hely Suárez Marín*  
**Fecha:** *13 de noviembre de 2025*  
*Fundación de Estudios Superiores Comfanorte*

---

## Introducción

El presente taller práctico aborda la implementación de mecanismos de **seguridad, control de acceso y auditoría** en la base de datos del proyecto *TechStore*, una plataforma orientada al registro y gestión de ventas de productos tecnológicos.

La solución desarrollada incorpora elementos avanzados de MySQL tales como:

- **Gestión granular de usuarios y permisos**  
- **Creación de vistas** para protección y abstracción de datos  
- **Triggers de auditoría** para registrar eventos críticos en la tabla `ventas`

Con estas implementaciones se fortalece la integridad del sistema, se centraliza la trazabilidad de las operaciones y se aplican buenas prácticas de seguridad a nivel de base de datos.

---

## Objetivos

### Objetivo general
Implementar mecanismos avanzados de seguridad, control de acceso y auditoría para garantizar la integridad del sistema de gestión de ventas de *TechStore*.

### Objetivos específicos
- Crear roles de usuario con permisos específicos bajo el principio de “mínimo privilegio”.
- Implementar **vistas** para ocultar información sensible y simplificar consultas.
- Desarrollar **triggers de auditoría** para rastrear modificaciones en la tabla `ventas`.
- Validar el correcto funcionamiento de los permisos, vistas y triggers implementados.

---

## Desarrollo del Taller

### 1. Gestión de Usuarios y Permisos (`usuarios_permisos_techstore.sql`)

Se crearon tres usuarios, cada uno alineado con funciones reales dentro del sistema TechStore:

| Usuario | Función | Permisos Clave | Seguridad |
|--------|---------|----------------|-----------|
| `admin_tech` | Administrador total del sistema | `ALL PRIVILEGES` sobre `techstore.*` | Cuenta desbloqueada, expiración a 90 días |
| `analista_ventas` | Consultas, reportes y análisis | Solo `SELECT` sobre todas las tablas | Contraseña expira en 90 días |
| `vendedor_junior` | Registro y actualización de ventas | `SELECT, INSERT, UPDATE` en `ventas`; `SELECT` en `productos` | Privilegio mínimo |

**Ejemplo real del taller (creación de analista_ventas)**

```sql
CREATE USER 'analista_ventas'@'localhost' IDENTIFIED BY 'AnalisisVentas2025!';
ALTER USER 'analista_ventas'@'localhost'
    ACCOUNT UNLOCK
    PASSWORD EXPIRE INTERVAL 90 DAY;
GRANT SELECT ON techstore.* TO 'analista_ventas'@'localhost';
```

---

### 2. Implementación de Vistas (`views_techstore.sql`)

Tres vistas fueron diseñadas para proteger información, facilitar consultas y aplicar seguridad a nivel de filas.

| Vista | Propósito | Función |
|-------|-----------|---------|
| `ventas_publico` | Proveer información de ventas sin exponer datos internos | Oculta detalles internos y muestra solo datos relevantes para consulta |
| `resumen_ventas_por_producto` | Estadísticas gerenciales de ventas | Calcula unidades vendidas, ingresos y ticket promedio |
| `ventas_con_tarjeta` | Control sobre ventas pagadas con tarjeta | `WITH CHECK OPTION` impide modificar registros que no cumplan la condición |

**Ejemplo real del taller (`ventas_publico`)**

```sql
CREATE OR REPLACE VIEW ventas_publico AS
SELECT
    v.id AS id_venta,
    p.nombre AS nombre_producto,
    p.categoria,
    v.fecha_venta,
    v.cantidad,
    v.total,
    v.metodo_pago
FROM ventas v
JOIN productos p ON v.id_producto = p.id;
```

---

### 3. Triggers de Auditoría (`triggers_techstore.sql`)

Se creó una tabla de auditoría llamada `ventas_audit_log` que registra:

- ID de la venta afectada  
- Tipo de operación (`INSERT`, `UPDATE`, `DELETE`)  
- Usuario que ejecutó la acción  
- Fecha  
- Cambios realizados (en formato JSON)

Luego se implementaron tres triggers:

| Trigger | Evento | Función |
|---------|--------|---------|
| `trg_ventas_after_insert` | AFTER INSERT | Registra toda venta creada |
| `trg_ventas_after_update` | AFTER UPDATE | Guarda valores anteriores y nuevos |
| `trg_ventas_after_delete` | AFTER DELETE | Guarda información eliminada |

**Ejemplo de trigger (AFTER UPDATE)**

```sql
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
            'old_cantidad', OLD.cantidad,
            'new_cantidad', NEW.cantidad,
            'old_total', OLD.total,
            'new_total', NEW.total
        )
    );
END;
```

---

## Estructura Final del Sistema TechStore

| Tablas finales en `techstore` |
|------------------------------|
| productos |
| ventas |
| logs_sistema |
| **ventas_audit_log** |
| **ventas_publico** |
| **resumen_ventas_por_producto** |
| **ventas_con_tarjeta** |

---

## Conclusiones

1. La asignación de permisos bajo el principio de **privilegio mínimo** garantiza la seguridad operacional.  
2. Las **vistas** implementadas ocultan información sensible y aplican reglas de negocio importantes.  
3. Los **triggers de auditoría** permiten trazar cualquier cambio en la tabla `ventas`.  
4. El conjunto de estas herramientas demuestra un manejo correcto de administración avanzada en MySQL.

---

## Reflexión Personal

La implementación de vistas, usuarios y triggers en el proyecto *TechStore* permitió entender en profundidad cómo la seguridad en bases de datos va más allá del almacenamiento de información. Cada vista funciona como un filtro inteligente que protege datos sensibles, mientras que los triggers registran cada cambio importante. Este taller reafirma la importancia de la gobernanza y protección de datos en sistemas modernos.
