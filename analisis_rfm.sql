USE PortfolioRetail;
GO

-- SI YA CREASTE LA TABLA ANTES POR ERROR, BORRALA PRIMERO:
IF OBJECT_ID('Tabla_Segmentacion_Clientes', 'U') IS NOT NULL
DROP TABLE Tabla_Segmentacion_Clientes;
GO

-- 1. Calculamos R, F y M por cliente
WITH RFM_Base AS (
    SELECT 
        Customer_ID AS ClienteID, 
        DATEDIFF(day, MAX(InvoiceDate), '2011-12-10') AS Recencia_Dias,
        COUNT(DISTINCT Invoice) AS Frecuencia_Compras,
        SUM(TotalVenta) AS Dinero_Total
    FROM Ventas
    WHERE Customer_ID IS NOT NULL 
    GROUP BY Customer_ID          
),

-- 2. Damos puntajes del 1 al 4 (4 es mejor)
RFM_Scores AS (
    SELECT 
        ClienteID, Recencia_Dias, Frecuencia_Compras, Dinero_Total,
        NTILE(4) OVER (ORDER BY Recencia_Dias DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frecuencia_Compras ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Dinero_Total ASC) AS M_Score
    FROM RFM_Base
)

-- 3. Creamos la tabla final con los segmentos
SELECT 
    ClienteID, Recencia_Dias, Frecuencia_Compras, Dinero_Total,
    CAST(R_Score AS varchar) + CAST(F_Score AS varchar) + CAST(M_Score AS varchar) AS RFM_Cell,
    CASE 
        WHEN (R_Score + F_Score + M_Score) >= 11 THEN 'Campeones (VIP)'
        WHEN (R_Score + F_Score + M_Score) >= 9 THEN 'Leales Potenciales'
        WHEN (R_Score + F_Score + M_Score) >= 7 THEN 'Necesitan Atención'
        WHEN R_Score = 1 THEN 'En Riesgo'
        ELSE 'Promedio' 
    END AS Segmento_Cliente
INTO Tabla_Segmentacion_Clientes 
FROM RFM_Scores;


SELECT TOP 5 * FROM Tabla_Segmentacion_Clientes;