
-- Motor utilizado: SQL Server (SSMS)
-- ══════════════════════════════════════════════════════════════════════
-- TechStore — Script de la base Ventas_Tech_DB
-- Proyecto integrador RetailPro · Pre-entrega Módulo 3
-- Script SQL para esquema normalizado y datos iniciales (DDL + DML)
-- Apellido y Nombre: Santillan Elva Romina
-- 
-- ══════════════════════════════════════════════════════════════════════
-- Modelo (3FN):
--   categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes
--   Tres tablas de dimensión (categorias, clientes, productos) y una
--   tabla de hechos (ventas). Las categorías van en su propia tabla y no
--   como texto repetido dentro de productos: eso hace que se cumpla la 3FN.
--
-- El script es repetible: se puede ejecutar completo las veces que haga
-- falta sin errores (crea la base solo si no existe y borra las tablas
-- antes de volver a crearlas).
-- ══════════════════════════════════════════════════════════════════════

-- Crear la base solo si todavía no existe
IF DB_ID('Ventas_Tech_DB') IS NULL
    CREATE DATABASE Ventas_Tech_DB;
GO

-- Seleccionar la base para que todo lo que sigue se cree dentro de ella
USE Ventas_Tech_DB;
GO


-- ── SECCIÓN DDL ───────────────────────────────────────────────────────

-- =====================================================================
-- === SECCIÓN 1: DROP ===
-- Se eliminan las tablas en orden inverso a las dependencias, para no
-- violar las foreign keys: primero las que apuntan a otras (ventas,
-- productos) y al final las que son referenciadas (clientes, categorias).
-- =====================================================================

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
GO


-- =====================================================================
-- === SECCIÓN 2: CREATE ===
-- Se crean primero las tablas que no dependen de nadie (dimensiones) y
-- al final la tabla de hechos (ventas).
-- Las PK y FK se definen dentro de cada CREATE TABLE, con nombre propio
-- (pk_, fk_, uq_, df_) para identificarlas fácilmente si dan error.
-- Toda FK usa el mismo tipo de dato (INT) que la PK a la que apunta.
-- =====================================================================

-- Dimensión: categorias
CREATE TABLE categorias (
    id_categoria     INT           NOT NULL,  -- INT: identificador entero, sin decimales
    nombre_categoria VARCHAR(50)   NOT NULL,  -- VARCHAR(50): texto corto; ocupa solo lo que usa
    descripcion      VARCHAR(200)  NULL,      -- VARCHAR(200): descripción breve; 
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria)
);

-- Dimensión: clientes
CREATE TABLE clientes (
    id_cliente     INT           NOT NULL,  -- INT: identificador entero
    nombre         VARCHAR(100)  NOT NULL,  -- VARCHAR(100): alcanza para nombre y apellido
    email          VARCHAR(100)  NULL,      -- VARCHAR(100): texto; UNIQUE evita mails repetidos
    ciudad         VARCHAR(50)   NULL,      -- VARCHAR(50): nombre de ciudad
    fecha_registro DATE          NOT NULL,  -- DATE: solo la fecha, sin hora; sirve para análisis por período
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_email UNIQUE (email)
);

-- Dimensión: productos (depende de categorias)
CREATE TABLE productos (
    id_producto     INT            NOT NULL,  -- INT: identificador entero
    nombre_producto VARCHAR(100)   NOT NULL,  -- VARCHAR(100): nombre comercial del producto
    id_categoria    INT            NOT NULL,  -- INT: mismo tipo que categorias.id_categoria (FK)
    precio          DECIMAL(10,2)  NOT NULL,  -- DECIMAL(10,2): dinero exacto; nunca FLOAT
    stock           INT            NOT NULL CONSTRAINT df_productos_stock  DEFAULT 0,  -- INT: unidades enteras
    activo          BIT            NOT NULL CONSTRAINT df_productos_activo DEFAULT 1,  -- BIT: 1 = a la venta, 0 = discontinuado
    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT fk_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
);

-- Hechos: ventas (depende de clientes y productos)
CREATE TABLE ventas (
    id_venta        INT            NOT NULL,  -- INT: identificador entero
    id_cliente      INT            NOT NULL,  -- INT: mismo tipo que clientes.id_cliente (FK)
    id_producto     INT            NOT NULL,  -- INT: mismo tipo que productos.id_producto (FK)
    cantidad        INT            NOT NULL,  -- INT: unidades vendidas, siempre enteras
    precio_unitario DECIMAL(10,2)  NOT NULL,  -- DECIMAL(10,2): precio del día de la venta; nunca FLOAT
    fecha_venta     DATE           NOT NULL,  -- DATE: permite agrupar por día, mes o año en Power BI
    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),
    CONSTRAINT fk_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente),
    CONSTRAINT fk_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES productos (id_producto)
);
GO


-- ── SECCIÓN DML ───────────────────────────────────────────────────────

-- =====================================================================
-- === SECCIÓN 3: INSERT ===
-- Se cargan los 25 registros en el mismo orden lógico: primero las
-- tablas sin dependencias (categorias, clientes), después productos y
-- por último ventas. Las columnas van explicitadas en cada INSERT: si
-- mañana se agrega una columna a la tabla, el INSERT sigue funcionando.
-- Textos y fechas van entre comillas simples; los números, sin comillas.
-- =====================================================================

-- categorias: 4 registros
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

-- clientes: 5 registros
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- productos: 6 registros
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ventas: 10 registros
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
    ( 2, 2, 2, 5,   28.00, '2024-03-06'),
    ( 3, 3, 3, 1,  450.00, '2024-03-07'),
    ( 4, 1, 4, 2,  120.00, '2024-03-08'),
    ( 5, 4, 5, 3,  130.00, '2024-03-10'),
    ( 6, 2, 6, 4,   95.00, '2024-03-11'),
    ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
    ( 8, 3, 2, 8,   28.00, '2024-03-13'),
    ( 9, 4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');
GO


-- =====================================================================
-- === SECCIÓN 4: VALIDACIÓN ===
-- Cada consulta tiene que devolver la cantidad de filas indicada.
-- =====================================================================

SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas
