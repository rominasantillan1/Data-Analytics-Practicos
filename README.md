# Data Analytics – Prácticas y pre-entregas

Repositorio de las prácticas y pre-entregas del curso de Data Analytics.
Proyecto integrador: **RetailPro**, una distribuidora de tecnología.

**Apellido y Nombre:** Santillán Elva Romina

## Contenido

| Carpeta | Entrega | Descripción |
|---|---|---|
| `modulo3` | Pre-entrega Módulo 3 | Script SQL que crea la base `Ventas_Tech_DB`: tablas, claves y carga de datos iniciales |

## Módulo 3 – Script SQL de ingeniería de datos

Archivo: `modulo3/ventas_tech_db.sql`

El script tiene cuatro secciones:

1. **DROP:** elimina las tablas en orden inverso a las dependencias, para que el script se pueda ejecutar varias veces sin errores.
2. **CREATE:** crea las tablas `categorias`, `clientes`, `productos` y `ventas` con sus claves primarias y foráneas.
3. **INSERT:** carga 25 registros (4 categorías, 5 clientes, 6 productos y 10 ventas).
4. **VALIDACIÓN:** cuatro consultas que devuelven 4, 5, 6 y 10 filas.

### Modelo de datos (3FN)

    categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes

Tres tablas de dimensión (`categorias`, `clientes`, `productos`) y una tabla de hechos (`ventas`).

### Cómo ejecutarlo

1. Abrir SQL Server Management Studio (SSMS) y conectarse al servidor.
2. Abrir `ventas_tech_db.sql`.
3. Ejecutar todo con **F5**.

**Herramienta:** SQL Server · SSMS
