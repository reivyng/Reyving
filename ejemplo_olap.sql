-- Ejemplo de esquema para un cubo OLAP (Data Warehouse simple)
-- Base de datos: DW_Ejemplo

-- 1) Crear la base de datos (si no existe)
-- USE master;
-- IF DB_ID('DW_Ejemplo') IS NULL
-- BEGIN
--     CREATE DATABASE DW_Ejemplo;
-- END;
-- GO

USE DW_Ejemplo;
GO

-- 2) Tablas de dimensiones

CREATE TABLE DimFecha (
    FechaKey INT PRIMARY KEY,
    Fecha DATE NOT NULL,
    Año INT NOT NULL,
    Trimestre INT NOT NULL,
    Mes INT NOT NULL,
    Dia INT NOT NULL,
    NombreMes NVARCHAR(20) NOT NULL,
    DiaSemana NVARCHAR(10) NOT NULL
);

CREATE TABLE DimProducto (
    ProductoKey INT PRIMARY KEY,
    NombreProducto NVARCHAR(100) NOT NULL,
    Categoria NVARCHAR(50) NOT NULL,
    Subcategoria NVARCHAR(50) NOT NULL,
    Marca NVARCHAR(50) NOT NULL
);

CREATE TABLE DimCliente (
    ClienteKey INT PRIMARY KEY,
    NombreCliente NVARCHAR(100) NOT NULL,
    Segmento NVARCHAR(50) NOT NULL,
    Region NVARCHAR(50) NOT NULL,
    Pais NVARCHAR(50) NOT NULL
);

CREATE TABLE DimCanalVenta (
    CanalKey INT PRIMARY KEY,
    NombreCanal NVARCHAR(50) NOT NULL
);

-- 3) Tabla de hechos

CREATE TABLE FactVentas (
    VentaKey INT IDENTITY(1,1) PRIMARY KEY,
    FechaKey INT NOT NULL,
    ProductoKey INT NOT NULL,
    ClienteKey INT NOT NULL,
    CanalKey INT NOT NULL,
    Cantidad INT NOT NULL,
    Importe DECIMAL(18,2) NOT NULL,
    Descuento DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_FactVentas_DimFecha FOREIGN KEY (FechaKey) REFERENCES DimFecha(FechaKey),
    CONSTRAINT FK_FactVentas_DimProducto FOREIGN KEY (ProductoKey) REFERENCES DimProducto(ProductoKey),
    CONSTRAINT FK_FactVentas_DimCliente FOREIGN KEY (ClienteKey) REFERENCES DimCliente(ClienteKey),
    CONSTRAINT FK_FactVentas_DimCanal FOREIGN KEY (CanalKey) REFERENCES DimCanalVenta(CanalKey)
);

-- 4) Insertar datos de ejemplo

INSERT INTO DimFecha (FechaKey, Fecha, Año, Trimestre, Mes, Dia, NombreMes, DiaSemana)
VALUES
(20230101, '2023-01-01', 2023, 1, 1, 1, 'Enero', 'Domingo'),
(20230102, '2023-01-02', 2023, 1, 1, 2, 'Enero', 'Lunes'),
(20230115, '2023-01-15', 2023, 1, 1, 15, 'Enero', 'Domingo'),
(20230201, '2023-02-01', 2023, 1, 2, 1, 'Febrero', 'Miércoles'),
(20230301, '2023-03-01', 2023, 1, 3, 1, 'Marzo', 'Miércoles'),
(20230401, '2023-04-01', 2023, 2, 4, 1, 'Abril', 'Sábado');

INSERT INTO DimProducto (ProductoKey, NombreProducto, Categoria, Subcategoria, Marca)
VALUES
(1, 'Notebook Modelo A', 'Electrónica', 'Computadoras', 'MarcaX'),
(2, 'Mouse Inalámbrico', 'Electrónica', 'Periféricos', 'MarcaY'),
(3, 'Café Molido 500gr', 'Alimentos', 'Bebidas', 'MarcaZ');

INSERT INTO DimCliente (ClienteKey, NombreCliente, Segmento, Region, Pais)
VALUES
(1, 'Cliente ABC', 'Corporativo', 'Norte', 'México'),
(2, 'Cliente XYZ', 'PyME', 'Centro', 'México'),
(3, 'Cliente 123', 'Consumo', 'Sur', 'México');

INSERT INTO DimCanalVenta (CanalKey, NombreCanal)
VALUES
(1, 'Tienda Física'),
(2, 'Ecommerce'),
(3, 'Distribuidor');

INSERT INTO FactVentas (FechaKey, ProductoKey, ClienteKey, CanalKey, Cantidad, Importe, Descuento)
VALUES
(20230101, 1, 1, 2, 2, 50000.00, 2500.00),
(20230102, 2, 2, 1, 5, 1250.00, 0.00),
(20230115, 1, 3, 3, 1, 25000.00, 1250.00),
(20230201, 3, 2, 2, 10, 2000.00, 100.00),
(20230301, 2, 1, 1, 7, 1750.00, 50.00),
(20230401, 3, 3, 2, 8, 1600.00, 0.00);

-- 5) Ejemplo de consulta agregada (ROLAP / MVA)
-- Total de ventas por año y categoría de producto

SELECT
  df.Año,
  dp.Categoria,
  SUM(fv.Importe) AS TotalVentas,
  SUM(fv.Cantidad) AS TotalCantidad
FROM FactVentas fv
JOIN DimFecha df ON fv.FechaKey = df.FechaKey
JOIN DimProducto dp ON fv.ProductoKey = dp.ProductoKey
GROUP BY df.Año, dp.Categoria
ORDER BY df.Año, dp.Categoria;
