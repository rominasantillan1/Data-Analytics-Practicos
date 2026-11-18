RetailPro – Proyecto integrador de Data Analytics
Repositorio con las pre-entregas del curso de Data Analytics. El proyecto analiza las ventas de TechStore, una empresa de retail de tecnología, para responder una pregunta de negocio: por qué el margen bruto cae aunque las ventas crecen, y qué categoría, región o canal lo explica.
Autora: Romina Santillán, contadora pública.
Herramientas
SQL Server + SQL Server Management Studio (SSMS): base de datos, tablas, carga de datos y consultas.
Power BI Desktop: limpieza con Power Query (lenguaje M), modelo de datos y medidas DAX.
GitHub: versionado y entrega de los archivos.
Estructura del repositorio
```
Data-Analytics-Practicos/
├── modulo3/
│   └── ventas_tech_db.sql                       → crea la base y carga los datos (DDL + DML)
├── modulo4/
│   ├── m4_consultas_negocio.sql                 → métricas: resumen mensual, ranking, clientes, promedio
│   └── m5_consultas_joins.sql                   → JOIN y UNION ALL: vista base, clientes y productos sin ventas
├── Pipeline_ETL_Santillan_Romina_Checkpoint2.pbix → modelo en Power BI (relaciones, calendario y medidas DAX)
└── README.md
```
Modelo de datos
```
categorias (1) ── (N) productos (1) ── (N) ventas (N) ── (1) clientes
```
`ventas` es la tabla de hechos; `clientes`, `productos` y `categorias` son dimensiones.
El modelo está normalizado en 3FN: la categoría vive en su propia tabla y no se repite en cada producto.
En Power BI se suma una tabla calendario (`Dim_Fechas`) y una tabla de medidas (`_Medidas`) con Total Ventas, Ventas Online, Ventas YTD, Ventas LY y % Crecimiento Anual.
Cómo ejecutar los scripts
Descargá los archivos `.sql` desde GitHub: abrí cada archivo y usá el botón de descarga (↓).
Abrí SSMS y conectate al servidor:
Servidor: `localhost` (o `.\SQLEXPRESS` si instalaste la versión Express).
Autenticación de Windows.
Tildá Certificado de servidor de confianza.
Primero abrí `modulo3/ventas_tech_db.sql` y ejecutalo completo con F5. Crea la base `Ventas_Tech_DB` y carga 25 registros. Se puede ejecutar varias veces sin errores.
Después ejecutá `modulo4/m4_consultas_negocio.sql` y `modulo4/m5_consultas_joins.sql`. Las dos usan la base creada en el paso 3.
Script	Resultado esperado
`ventas_tech_db.sql`	4 consultas de validación con 4, 5, 6 y 10 filas
`m4_consultas_negocio.sql`	4 resultados: 1, 5, 5 y 6 filas
`m5_consultas_joins.sql`	4 resultados: 10, 0, 0 y 2 filas
Hallazgos principales
El producto 1 (Laptop Pro 15) concentra el 55,9 % de la facturación de marzo de 2024 en la base SQL.
En el dataset de Power BI, Computación genera el 79 % de las ventas pero tiene el margen más bajo (28 %).
Entre enero y julio, las ventas de 2024 crecieron un 44,4 % frente al mismo período de 2023.
Uso de IA
La primera versión de este README se generó con asistencia de IA (Claude) y la edité para que refleje la estructura real del repositorio, los pasos de ejecución que usé y los resultados verificados de cada script.
