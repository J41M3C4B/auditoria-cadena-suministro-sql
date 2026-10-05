# 📊 Auditoría Integral de Cadena de Suministro: Riesgo, Logística y Competitividad

**Rol:** Data Analyst / Business Intelligence  
**Stack Tecnológico:** PostgreSQL, Docker, Looker Studio, Modelado Relacional.

## 🎯 Resumen Ejecutivo
Este proyecto audita la eficiencia financiera y operativa de una cadena de suministro global (2024-2026). A través de un proceso completo de ETL, modelado de datos relacional y análisis exploratorio profundo, se evaluó el desempeño logístico y el riesgo geográfico de múltiples proveedores. 

El análisis desmintió la hipótesis corporativa inicial: la fragmentación de pedidos (micro-órdenes) no destruye el valor del producto base, sino que revela ventajas competitivas en precios unitarios. Sin embargo, expone hemorragias financieras graves en categorías logísticas periféricas y una dependencia geográfica crítica.

---

## 🛠️ Arquitectura de Datos y Metodología (ETL)

El proyecto se estructuró en tres fases de procesamiento SQL puro, transitando desde un archivo plano (CSV) hasta un modelo de datos analítico y normalizado:

### 1. Extracción e Ingestión (`01_SCHEMA_AND_IMPORT.sql`)
*   Definición del esquema crudo (`raw_furnace_requirements`).
*   Ingesta masiva de datos mediante comandos nativos `COPY` de PostgreSQL.

### 2. Modelado y Saneamiento (`02_DATA_CLEANING.sql`)
*   **Limpieza Defensiva:** Estandarización de texto (`LOWER`, `TRIM`), remoción de caracteres contables corruptos (`REPLACE`, `NULLIF`) y casteo a formatos numéricos exactos (`CAST`).
*   **Normalización Relacional:** Transformación de una tabla plana a un modelo relacional (tipo copo de nieve) creando catálogos maestros y llaves foráneas (`countries`, `cities`, `companies`, `categories`, `units_of_measure`, `items`).
*   **Gestión de Históricos:** Creación de la tabla transaccional `company_item_prices` para trackear la evolución de precios por año.

### 3. Análisis de Inteligencia de Negocios (`03_ANALYSIS.sql`)
*   Uso de *Common Table Expressions* (CTEs), Subconsultas y agrupaciones avanzadas (`HAVING COUNT DISTINCT`) para responder a las preguntas críticas del negocio.
*   Cálculo de KPIs financieros y logísticos: *Porcentaje de Dependencia Económica*, *Ratio de Costo Logístico por Kg*, y *Varianza de Precio de Artículos (IPV)*.

---

## 💡 Hallazgos Clave (Insights de Negocio)

### 1. Riesgo Estructural (Vulnerabilidad Geográfica)
Se identificó un pivote drástico en la concentración de proveedores. Para 2026, el **70.9% del gasto global** se concentra en Pakistán, con el nodo de *Sheikhupura* acaparando el 41.53% del capital atado a un **único proveedor**.
> **Acción:** Homologar proveedores secundarios de manera expedita en Asia Central para mitigar el riesgo de paros operativos ante disrupciones geopolíticas o locales.

*(Visualización: Mapa de calor de concentración financiera)*
`![Mapa de Riesgo Geografico](ruta/a/tu/imagen/mapa.png)`

### 2. Fuga de Capital Logístico (Ratio Costo/Kg)
Al estandarizar los fletes mediante un indicador de "Costo por Kilogramo", se descubrió que las categorías periféricas o de servicios (`Account` y `L&T`) superan los **$50.00 USD/kg**. Esto representa un costo insostenible frente al promedio de materias primas principales, que se mantiene estable entre $0.50 y $10.00 USD/kg.
> **Acción:** Forzar la consolidación directa de fletes pequeños y renegociar contratos de servicios extraordinarios para sacarlos de la logística operativa directa.

*(Visualización: Gráfico de barras del Ratio de Costo Logístico)*
`![Ratio de Costo Logistico](ruta/a/tu/imagen/ratio_costo.png)`

### 3. Competitividad: Micro-Órdenes vs. Alto Volumen
Se ejecutó un análisis "Cara a Cara" cruzando artículos idénticos entre el líder de micro-órdenes (*Foundary Port Sudán*) y el líder mayorista (*PakArab Steel Factory*). 
**El Plot Twist Analítico:** La fragmentación no destruye el valor comercial base. *Foundary Port Sudán* ofreció precios más agresivos en 6 de 10 artículos compartidos, logrando ahorros unitarios de hasta **54.55%** (Ej. Item 270: $3,571.00 vs $7,857.00).
> **Acción:** Implementar una **Optimización Híbrida**. Mantener al proveedor de micro-órdenes para componentes de alto valor estratégico, condicionando su viabilidad a que el costo de importación logística no eclipse el ahorro unitario demostrado.

*(Visualización: Gráfico de Varianza de Precios - IPV)*
`![Varianza de Precios](ruta/a/tu/imagen/varianza.png)`

---

## 📁 Estructura del Repositorio
* [`data/`](data/): Archivos crudos y datasets extraídos del análisis.
* [`sql_scripts/`](sql_scripts/):
  * `01_SCHEMA_AND_IMPORT.sql`: DDL y carga de datos.
  * `02_DATA_CLEANING.sql`: Limpieza profunda y normalización de bases de datos.
  * `03_ANALYSIS.sql`: Modelos de consulta para extracción de KPIs de negocio.
* [`visuals/`](visuals/): Capturas de los dashboards interactivos desarrollados.
* [`Informe_Ejecutivo_de_Operaciones.pdf`](Informe_Ejecutivo_de_Operaciones.pdf): Presentación ejecutiva final del análisis.
