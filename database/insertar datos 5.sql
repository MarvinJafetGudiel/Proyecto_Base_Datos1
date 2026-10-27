USE MAGIS_AUTO;

GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Credito WHERE NumeroObligacion LIKE 'MAGIS-DEMO-%')
THROW 50020, 'No hay creditos DEMO. Ejecute primero 06_insertar_creditos.sql.', 1;

GO

BEGIN TRY
    BEGIN TRANSACTION;

    ;
    WITH Numeros AS (
    SELECT TOP (120) ROW_NUMBER() OVER (ORDER BY object_id) AS NumeroCuota
    FROM sys.all_objects
    ), Base AS (
    SELECT C.IdCredito, C.PlazoMeses, C.FechaAprobacion,
    C.MontoFinanciado, C.TotalIntereses,
    C.ManejoCuentaMensual, C.SeguroVehiculoMensual, C.SeguroVidaMensual,
    N.NumeroCuota,
    CAST(ROUND(C.MontoFinanciado / C.PlazoMeses, 2) AS DECIMAL(12,2)) AS CapitalBase,
    CAST(ROUND(C.TotalIntereses / C.PlazoMeses, 2) AS DECIMAL(12,2)) AS InteresBase
    FROM dbo.Credito C
    CROSS JOIN Numeros N
    WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%'
    AND N.NumeroCuota <= C.PlazoMeses
    ), Distribucion AS (
    SELECT *,
    CAST(CASE WHEN NumeroCuota = PlazoMeses
    THEN MontoFinanciado - CapitalBase * (PlazoMeses - 1)
ELSE CapitalBase END AS DECIMAL(12,2)) AS CapitalCuota,
    CAST(CASE WHEN NumeroCuota = PlazoMeses
    THEN TotalIntereses - InteresBase * (PlazoMeses - 1)
ELSE InteresBase END AS DECIMAL(12,2)) AS InteresCuota
    FROM Base
    )
    INSERT INTO dbo.Cuota
    (IdCredito, NumeroCuota, FechaVencimiento, Capital, Interes,
    ManejoCuenta, SeguroVehiculo, SeguroVida, TotalCuota)
    SELECT D.IdCredito, D.NumeroCuota,
    CAST(DATEADD(MONTH, D.NumeroCuota, CAST(D.FechaAprobacion AS DATE)) AS DATE),
    D.CapitalCuota, D.InteresCuota,
    D.ManejoCuentaMensual, D.SeguroVehiculoMensual, D.SeguroVidaMensual,
    CAST(D.CapitalCuota + D.InteresCuota + D.ManejoCuentaMensual
    + D.SeguroVehiculoMensual + D.SeguroVidaMensual AS DECIMAL(12,2))
    FROM Distribucion D
    WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Cuota Q
    WHERE Q.IdCredito = D.IdCredito AND Q.NumeroCuota = D.NumeroCuota
    );

    IF EXISTS (
    SELECT 1
    FROM dbo.Credito C
    OUTER APPLY (
    SELECT COUNT(*) AS Cantidad, COALESCE(SUM(Q.Capital),0) AS Capital,
    COALESCE(SUM(Q.Interes),0) AS Intereses,
    COALESCE(SUM(Q.TotalCuota),0) AS Total
    FROM dbo.Cuota Q WHERE Q.IdCredito = C.IdCredito
    ) S
    WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%'
    AND (S.Cantidad <> C.PlazoMeses OR S.Capital <> C.MontoFinanciado
    OR S.Intereses <> C.TotalIntereses OR S.Total <> C.TotalRecaudable)
    )
    THROW 50021, 'Las cuotas no cuadran con uno o mas creditos. Se cancelo la insercion.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

GO

SELECT COUNT(*) AS TotalCuotasDemo
FROM dbo.Cuota Q JOIN dbo.Credito C ON C.IdCredito = Q.IdCredito
WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%';

SELECT TOP (10) C.NumeroObligacion, C.PlazoMeses,
COUNT(Q.IdCuota) AS CuotasGeneradas,
C.TotalRecaudable, SUM(Q.TotalCuota) AS SumaCuotas
FROM dbo.Credito C
JOIN dbo.Cuota Q ON Q.IdCredito = C.IdCredito
WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%'
GROUP BY C.NumeroObligacion, C.PlazoMeses, C.TotalRecaudable
ORDER BY C.NumeroObligacion;

SELECT TOP (12) Q.NumeroCuota, Q.FechaVencimiento, Q.Capital, Q.Interes,
Q.ManejoCuenta, Q.SeguroVehiculo, Q.SeguroVida, Q.TotalCuota
FROM dbo.Cuota Q
JOIN dbo.Credito C ON C.IdCredito = Q.IdCredito
WHERE C.NumeroObligacion = 'MAGIS-DEMO-0001'
ORDER BY Q.NumeroCuota;

GO
