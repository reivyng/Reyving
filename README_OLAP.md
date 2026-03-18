# Ejemplo paso a paso: Construir un cubo OLAP (con datos de muestra)

Este repositorio contiene un ejemplo completo para construir un cubo OLAP desde cero usando un modelo de datos en estrella (star schema). Incluye:

- Un **script SQL** (`ejemplo_olap.sql`) que crea un data warehouse de ejemplo (dimensiones + tabla de hechos) y carga datos de prueba.
- Instrucciones para construir un cubo OLAP en **SQL Server Analysis Services (SSAS)** y una opción alternativa en **Power BI (modelo tabular)**.

---

## 1) Preparar datos de ejemplo (Data Warehouse)

1. Abre SQL Server Management Studio (SSMS) o tu cliente SQL favorito.
2. Ejecuta el script `ejemplo_olap.sql` en una instancia de SQL Server.

Esto creará una base de datos `DW_Ejemplo` con:

- `DimFecha` (dimensión de tiempo)
- `DimProducto` (dimensión de producto)
- `DimCliente` (dimensión de cliente)
- `DimCanalVenta` (dimensión de canal de venta)
- `FactVentas` (tabla de hechos con métricas: Cantidad, Importe, Descuento)

---

## 2) Diseñar el cubo OLAP en SSAS (multidimensional)

### 2.1. Crear un proyecto de Analysis Services

1. En Visual Studio (con la extensión **SQL Server Data Tools** instalada), crea un nuevo proyecto de tipo `Analysis Services Multidimensional and Data Mining Project`.
2. Nombra el proyecto, por ejemplo, `CuboVentasEjemplo`.

### 2.2. Definir la fuente de datos (Data Source)

1. Agrega una nueva **Data Source** apuntando a tu instancia de SQL Server donde ejecutaste `ejemplo_olap.sql`.
2. Selecciona la base de datos `DW_Ejemplo`.
3. Prueba la conexión y asegúrate de que funcione.

### 2.3. Definir la vista de datos (Data Source View)

1. Crea un nuevo **Data Source View** (DSV).
2. Añade las tablas: `DimFecha`, `DimProducto`, `DimCliente`, `DimCanalVenta` y `FactVentas`.
3. Asegúrate de que las relaciones (FK) entre `FactVentas` y las dimensiones estén correctamente detectadas.

### 2.4. Crear dimensiones

1. Crea una dimensión para cada tabla dimensional (`DimFecha`, `DimProducto`, `DimCliente`, `DimCanalVenta`).
2. Define los atributos que usarás para filtrar y agrupar (por ejemplo: Año, Trimestre, Categoría, Región).

### 2.5. Crear el cubo

1. Crea un nuevo cubo usando el asistente.
2. Selecciona la tabla de hechos `FactVentas` como la fuente de medidas.
3. Elige las medidas a incluir (ej. `Importe`, `Cantidad`, `Descuento`).
4. Conecta el cubo a las dimensiones que creaste.

### 2.6. Procesar y explorar

1. Procesa el cubo (botón derecho > Procesar).
2. Usa la pestaña **Browser** para revisar medidas y hacer drill-down en las dimensiones.

---

## 3) Ejemplo de consulta MDX (para el cubo SSAS)

Una vez procesado el cubo, puedes ejecutarlo desde SQL Server Management Studio (MDX query):

```sql
SELECT
  {[Measures].[Importe], [Measures].[Cantidad]} ON COLUMNS,
  NON EMPTY
    ([DimFecha].[Año].[Año].Members * [DimProducto].[Categoria].[Categoria].Members)
  ON ROWS
FROM [NombreDelCubo]
```

> Cambia `[NombreDelCubo]` por el nombre real del cubo que creaste.

---

## 4) Alternativa: Modelo tabular en Power BI

Si no tienes SSAS, puedes usar Power BI (o Azure Analysis Services / Power BI Premium) con el mismo modelo.

### 4.1. Cargar los datos

1. En Power BI Desktop, selecciona **Obtener datos > SQL Server**.
2. Conéctate a la base de datos `DW_Ejemplo`.
3. Carga las tablas `DimFecha`, `DimProducto`, `DimCliente`, `DimCanalVenta` y `FactVentas`.

### 4.2. Relacionar las tablas

1. En el modelo (vista de relaciones), crea relaciones entre `FactVentas` y las dimensiones:
   - `FactVentas.FechaKey` → `DimFecha.FechaKey`
   - `FactVentas.ProductoKey` → `DimProducto.ProductoKey`
   - `FactVentas.ClienteKey` → `DimCliente.ClienteKey`
   - `FactVentas.CanalKey` → `DimCanalVenta.CanalKey`

### 4.3. Crear medidas (DAX)

Ejemplo de medida para total de ventas:

```dax
Total Ventas = SUM(FactVentas[Importe])
```

Medida para total de unidades:

```dax
Total Unidades = SUM(FactVentas[Cantidad])
```

### 4.4. Explorar con visuales

Crea un **matriz** o **gráfico de barras** y usa dimensionalidades como año, categoría, región para explorar los datos.

---

## 5) ¿Qué sigue? Ajustes y expansión

- Agrega más datos de ventas reales (o genera datos sintéticos) en `FactVentas` para probar volumen y rendimiento.
- Añade más dimensiones si necesitas: tienda, vendedor, campaña, etc.
- Implementa lógica de actualización incremental (ETL) para mantener el cubo actualizado.

---

Si quieres, puedo ayudarte a generar un conjunto de datos sintético más amplio (p.ej. miles de registros) y a escribir un script de ETL (en T-SQL o Python) para cargar datos de forma incremental.»