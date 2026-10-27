USE MAGIS_AUTO;

GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Cuota Q JOIN dbo.Credito C ON C.IdCredito=Q.IdCredito
WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%')
THROW 50030, 'Primero ejecute 07_generar_cuotas.sql.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.MedioPago)
THROW 50031, 'Primero cargue el catalogo MedioPago.', 1;

GO

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT Q.IdCuota, Q.NumeroCuota, Q.FechaVencimiento, Q.TotalCuota,
    ROW_NUMBER() OVER (ORDER BY C.NumeroObligacion, Q.NumeroCuota) AS OrdenGlobal
    INTO #CuotasDemo
    FROM dbo.Cuota Q
    INNER JOIN dbo.Credito C ON C.IdCredito = Q.IdCredito
    WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%'
    AND Q.NumeroCuota BETWEEN 1 AND 6
    AND Q.FechaVencimiento <= '2026-10-15'
    AND NOT EXISTS (SELECT 1 FROM dbo.Pago P WHERE P.IdCuota = Q.IdCuota);

    ;
    WITH Medios AS (
    SELECT IdMedioPago,
    ROW_NUMBER() OVER (ORDER BY IdMedioPago) AS Numero,
    COUNT(*) OVER () AS Cantidad
    FROM dbo.MedioPago
    )
    INSERT INTO dbo.Pago
    (IdCuota, IdMedioPago, NumeroRecibo, FechaPago, MontoPagado, ReferenciaBancaria)
    SELECT Q.IdCuota, M.IdMedioPago,
    CONCAT('MAGIS-P1-', Q.IdCuota),
    CAST(DATEADD(DAY, -3, Q.FechaVencimiento) AS DATETIME2),
    CAST(CASE WHEN Q.NumeroCuota % 3 = 0
    THEN ROUND(Q.TotalCuota * 0.60, 2)
ELSE Q.TotalCuota END AS DECIMAL(12,2)),
    CONCAT('DEMO-', Q.IdCuota, '-1')
    FROM #CuotasDemo Q
    INNER JOIN Medios M ON M.Numero = ((Q.OrdenGlobal - 1) % M.Cantidad) + 1
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Pago P
    WHERE P.NumeroRecibo = CONCAT('MAGIS-P1-', Q.IdCuota));

    ;
    WITH Medios AS (
    SELECT IdMedioPago,
    ROW_NUMBER() OVER (ORDER BY IdMedioPago) AS Numero,
    COUNT(*) OVER () AS Cantidad
    FROM dbo.MedioPago
    )
    INSERT INTO dbo.Pago
    (IdCuota, IdMedioPago, NumeroRecibo, FechaPago, MontoPagado, ReferenciaBancaria)
    SELECT Q.IdCuota, M.IdMedioPago,
    CONCAT('MAGIS-P2-', Q.IdCuota),
    CAST(Q.FechaVencimiento AS DATETIME2),
    CAST(ROUND(Q.TotalCuota * 0.20, 2) AS DECIMAL(12,2)),
    CONCAT('DEMO-', Q.IdCuota, '-2')
    FROM #CuotasDemo Q
    INNER JOIN Medios M ON M.Numero = (Q.OrdenGlobal % M.Cantidad) + 1
    WHERE Q.NumeroCuota % 3 = 0
    AND NOT EXISTS (SELECT 1 FROM dbo.Pago P
    WHERE P.NumeroRecibo = CONCAT('MAGIS-P2-', Q.IdCuota));

    DROP TABLE #CuotasDemo;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

GO

SELECT COUNT(*) AS TotalPagosDemo
FROM dbo.Pago
WHERE NumeroRecibo LIKE 'MAGIS-P1-%' OR NumeroRecibo LIKE 'MAGIS-P2-%';

SELECT TOP (15) C.NumeroObligacion, Q.NumeroCuota, Q.TotalCuota,
COALESCE(SUM(P.MontoPagado), 0) AS TotalPagado,
Q.TotalCuota - COALESCE(SUM(P.MontoPagado), 0) AS SaldoPendiente
FROM dbo.Cuota Q
JOIN dbo.Credito C ON C.IdCredito = Q.IdCredito
LEFT JOIN dbo.Pago P ON P.IdCuota = Q.IdCuota
WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%'
GROUP BY C.NumeroObligacion, Q.NumeroCuota, Q.TotalCuota
ORDER BY C.NumeroObligacion, Q.NumeroCuota;

GO

SELECT Q.IdCuota, Q.TotalCuota, SUM(P.MontoPagado) AS TotalPagado
FROM dbo.Cuota Q
JOIN dbo.Pago P ON P.IdCuota = Q.IdCuota
GROUP BY Q.IdCuota, Q.TotalCuota
HAVING SUM(P.MontoPagado) > Q.TotalCuota;

GO
