-- Motor utilizado: SQL Server (SSMS)
-- ══════════════════════════════════════════════════════════════════════
-- RetailPro — Consultas con JOINs para el proyecto
-- Pre-entrega Módulo 5: Cruzando tablas para enriquecer el análisis
-- Base de datos: Ventas_Tech_DB (creada en el Módulo 3)
-- Apellido y Nombre: Santillan Elva Romina
-- 
-- ══════════════════════════════════════════════════════════════════════
-- Alias de tabla usados en todo el archivo:
--   v = ventas · c = clientes · p = productos · cat = categorias
-- Dimensiones disponibles en el esquema del Módulo 3:
--   · clientes.ciudad             → dimensión geográfica (para filtrar)
--   · categorias.nombre_categoria → agrupación de productos (para agrupar)
-- ══════════════════════════════════════════════════════════════════════

USE Ventas_Tech_DB;
GO


-- =====================================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: obtener en una sola fila cada venta con el nombre y la
-- ciudad del cliente, el producto y su categoría. Es la fuente de datos
-- principal que se va a conectar a Power BI.
-- · INNER JOIN trae solo las filas que tienen coincidencia en ambas
--   tablas: cada venta con su cliente, su producto y la categoría.
-- · total_venta se calcula como cantidad * precio_unitario.
-- =====================================================================

SELECT
    v.id_venta,
    v.fecha_venta,
    v.id_cliente,
    c.nombre                         AS cliente,
    c.ciudad                         AS ciudad_cliente,
    p.nombre_producto                AS producto,
    cat.nombre_categoria             AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario   AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Hallazgo: las 10 ventas aparecen completas, así que no hay ventas con
-- cliente o producto inexistente. Computación concentra $4.950 de los
-- $6.444 vendidos (76,8%), y los clientes de Buenos Aires y Tucumán
-- explican el 73,6% de la facturación.


-- =====================================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados que nunca compraron, para que
-- el área de CRM los contacte.
-- · LEFT JOIN trae todos los clientes, tengan o no ventas. Si un cliente
--   no tiene ventas, las columnas de ventas quedan en NULL.
-- · WHERE v.id_venta IS NULL se queda solo con esos casos. (Con NULL no
--   se usa "= NULL": se usa IS NULL.)
-- =====================================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;

-- Hallazgo: la consulta devuelve 0 filas: los 5 clientes registrados
-- compraron al menos una vez (de hecho, todos repitieron). Para CRM no hay
-- clientes inactivos que reactivar; el foco puede pasar a aumentar el gasto
-- de los clientes que menos facturan. La consulta queda lista para detectar
-- clientes nuevos que se registren y todavía no compren.


-- =====================================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento, para que
-- el área de producto decida si promocionarlos o discontinuarlos.
-- · INNER JOIN con categorias para mostrar el nombre de la categoría
--   (todo producto tiene categoría, porque id_categoria es NOT NULL).
-- · LEFT JOIN con ventas + WHERE v.id_venta IS NULL deja solo los
--   productos que no aparecen en ninguna venta.
-- =====================================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria  AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN  ventas v       ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.precio DESC;

-- Hallazgo: la consulta devuelve 0 filas: los 6 productos del catálogo
-- tuvieron al menos una venta en marzo. Para el área de producto no hay
-- stock inmovilizado por falta de ventas, aunque el Auriculares BT Pro es
-- el de menor facturación ($360), así que conviene seguirlo de cerca.


-- =====================================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar la facturación de las dos semanas de marzo en las
-- que hubo ventas.
-- · La columna "canal" no existe en las tablas: se crea en cada SELECT
--   como un texto fijo que identifica el origen de las filas.
-- · Criterio: semanas calendario (lunes a domingo).
--   Semana 1 = 04/03 al 10/03 · Semana 2 = 11/03 al 17/03.
-- · Los dos SELECT devuelven las mismas 3 columnas, en el mismo orden y
--   con tipos compatibles.
-- · Se usa UNION ALL y no UNION porque UNION eliminaría filas repetidas,
--   y cada venta tiene que contarse una sola vez aunque coincida con otra.
-- =====================================================================

SELECT
    canal,
    COUNT(*)    AS cantidad_ventas,
    SUM(total)  AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario  AS total,
        'Semana 1 (04 al 10/03)'    AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-04' AND '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario  AS total,
        'Semana 2 (11 al 17/03)'    AS canal
    FROM ventas
    WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-17'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- Hallazgo: la semana 1 facturó $3.620 (56,2%) y la semana 2, $2.824, con
-- 5 ventas cada una. La diferencia se explica casi entera por la venta de
-- 2 Laptop Pro 15 del 05/03. Los totales suman $6.444, igual que en el
-- Módulo 4: ninguna venta se perdió ni se contó dos veces.
