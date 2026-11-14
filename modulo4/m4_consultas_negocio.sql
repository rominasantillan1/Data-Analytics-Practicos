-- Motor utilizado: SQL Server (SSMS)
-- ══════════════════════════════════════════════════════════════════════
-- RetailPro — Consultas SQL de negocio
-- Pre-entrega Módulo 4: Extrayendo métricas clave con SQL
-- Base de datos: Ventas_Tech_DB (creada en el Módulo 3)
-- Apellido y Nombre: Santillan Elva Romina
-- 
-- ══════════════════════════════════════════════════════════════════════
-- Todas las consultas trabajan solo sobre la tabla ventas
-- (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta).
-- El importe de cada venta se calcula como cantidad * precio_unitario.
-- Los nombres de productos y clientes se van a traer con JOIN en el
-- Módulo 5; por ahora se trabaja con los IDs.
-- ══════════════════════════════════════════════════════════════════════

USE Ventas_Tech_DB;
GO


-- =====================================================================
-- CONSULTA 1 — Resumen ejecutivo mensual
-- Pregunta: ¿cuánto se facturó, cuántos pedidos hubo y cuál fue el
-- ticket promedio en cada mes?
-- · MONTH(fecha_venta) extrae el número de mes para agrupar.
-- · En el GROUP BY se repite MONTH(fecha_venta) porque el alias "mes"
--   todavía no existe cuando se procesa el GROUP BY; en el ORDER BY sí
--   se puede usar el alias.
-- · Todas las ventas cargadas son de marzo de 2024, así que el
--   resultado tiene una sola fila (es lo esperado).
-- =====================================================================

SELECT
    MONTH(fecha_venta)               AS mes,
    SUM(cantidad * precio_unitario)  AS total_facturado,
    COUNT(*)                         AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)  AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;


-- =====================================================================
-- CONSULTA 2 — Ranking de productos
-- Pregunta: ¿cuáles son los 5 productos que más facturaron?
-- · SUM(cantidad) da las unidades vendidas de cada producto.
-- · ORDER BY ... DESC ordena de mayor a menor facturación y TOP 5 se
--   queda con los cinco primeros. TOP siempre va con ORDER BY: sin
--   ORDER BY el "top" sería cualquier fila.
-- =====================================================================

SELECT TOP 5
    id_producto,
    SUM(cantidad)                    AS unidades_vendidas,
    SUM(cantidad * precio_unitario)  AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- =====================================================================
-- CONSULTA 3 — Clientes recurrentes
-- Pregunta: ¿qué clientes hicieron más de un pedido y cuánto gastaron?
-- · HAVING filtra grupos (clientes) después de agrupar; WHERE no sirve
--   acá porque se procesa antes de que existan los grupos.
-- · En el HAVING se repite COUNT(*) porque el alias cantidad_pedidos
--   todavía no existe en ese paso.
-- =====================================================================

SELECT
    id_cliente,
    COUNT(*)                         AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)  AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- =====================================================================
-- CONSULTA 4 — Productos por encima / por debajo del promedio
-- Pregunta: ¿qué productos facturaron más que el promedio de
-- facturación por producto?
-- · Paso 1 (WITH): se calcula el total facturado de cada producto y se
--   guarda como una tabla temporal llamada ventas_por_producto.
-- · Paso 2: la subconsulta (SELECT AVG(total_producto) ...) calcula el
--   promedio de esos totales y CASE WHEN etiqueta cada producto.
-- · Ojo: es el promedio de los totales por producto, no el promedio de
--   las filas de ventas (eso sería el ticket promedio de la Consulta 1).
-- · La consulta anterior termina en ";", como exige SQL Server antes
--   de un WITH.
-- =====================================================================

WITH ventas_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_producto AS total_facturado,
    CASE
        WHEN total_producto > (SELECT AVG(total_producto) FROM ventas_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_producto
ORDER BY total_facturado DESC;


-- =====================================================================
-- HALLAZGOS
-- =====================================================================
-- 1. La facturación está muy concentrada: el producto 1 genera $3.600 de
--    los $6.444 facturados en marzo (55,9%). Junto con el producto 3
--    ($1.350) suman el 76,8% del total, y son los únicos dos productos
--    por encima del promedio por producto ($1.074).
--
-- 2. Vender muchas unidades no implica facturar mucho: el producto 2 es
--    el más vendido en unidades (13, más que el triple que cualquier
--    otro), pero solo factura $364 (5,6% del total) porque su precio
--    unitario es de $28. Queda quinto en el ranking de facturación.
--
-- 3. Los 5 clientes son recurrentes (todos hicieron 2 pedidos), pero el
--    gasto es muy desigual: los clientes 1 ($2.640) y 5 ($2.100) suman el
--    73,6% de la facturación, porque ambos compraron el producto 1;
--    los clientes 2 y 4 gastaron alrededor de $500 cada uno. Con la
--    misma cantidad de pedidos, lo que marca la diferencia es qué
--    producto compra cada cliente.
-- =====================================================================
