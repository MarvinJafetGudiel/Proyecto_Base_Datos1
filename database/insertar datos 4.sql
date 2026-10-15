USE MAGIS_AUTO;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;


IF (SELECT COUNT(*) FROM dbo.Cliente) < 100 OR
   (SELECT COUNT(*) FROM dbo.Vendedor) < 1 OR
   (SELECT COUNT(*) FROM dbo.Fiador) < 1 OR
   (SELECT COUNT(*) FROM dbo.Vehiculo WHERE VIN LIKE 'DEMOAUTO%') < 100 OR
   NOT EXISTS (SELECT 1 FROM dbo.EstadoCredito WHERE NombreEstado = 'Activo')
    THROW 50010, 'Faltan datos base. Ejecute primero los scripts 03, 04 y 05.', 1;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    ;WITH N AS (
        SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY object_id) AS n
        FROM sys.all_objects
    ), C AS (
        SELECT IdCliente, ROW_NUMBER() OVER (ORDER BY IdCliente) AS rn
        FROM dbo.Cliente
    ), V AS (
        SELECT IdVendedor, ROW_NUMBER() OVER (ORDER BY IdVendedor) AS rn,
               COUNT(*) OVER () AS total FROM dbo.Vendedor
    ), A AS (
        SELECT VIN, ValorAgencia, ROW_NUMBER() OVER (ORDER BY VIN) AS rn
        FROM dbo.Vehiculo WHERE VIN LIKE 'DEMOAUTO%'
    ), Base AS (
        SELECT N.n, C.IdCliente, V.IdVendedor, A.VIN,
               CAST(A.ValorAgencia * 0.20 AS DECIMAL(12,2)) AS Enganche,
               CAST(A.ValorAgencia * 0.80 AS DECIMAL(12,2)) AS MontoFinanciado,
               CASE N.n % 3 WHEN 0 THEN 12 WHEN 1 THEN 24 ELSE 36 END AS PlazoMeses,
               CAST(12.000 AS DECIMAL(6,3)) AS TasaInteresAnual,
               CAST(2.000 AS DECIMAL(6,3)) AS PorcentajeComision,
               CAST(175.00 AS DECIMAL(10,2)) AS SeguroVehiculoMensual,
               CAST(65.00 AS DECIMAL(10,2)) AS SeguroVidaMensual,
               CAST(25.00 AS DECIMAL(10,2)) AS ManejoCuentaMensual
        FROM N
        JOIN C ON C.rn=N.n
        JOIN A ON A.rn=N.n
        JOIN V ON V.rn=((N.n-1)%V.total)+1
    ), Calculo AS (
        SELECT *,
               CAST(ROUND(MontoFinanciado * TasaInteresAnual / 100.0 * PlazoMeses / 12.0,2) AS DECIMAL(14,2)) AS Intereses
        FROM Base
    )
    INSERT INTO dbo.Credito (
        NumeroObligacion, IdCliente, IdVendedor, VIN, IdEstadoCredito,
        FechaAprobacion, PlazoMeses, Enganche, MontoFinanciado,
        TasaInteresAnual, PorcentajeComision, SeguroVehiculoMensual,
        SeguroVidaMensual, ManejoCuentaMensual, TotalIntereses, TotalRecaudable
    )
    SELECT CONCAT('MAGIS-DEMO-',RIGHT('0000'+CAST(n AS VARCHAR(4)),4)),
           IdCliente,IdVendedor,VIN,
           (SELECT IdEstadoCredito FROM dbo.EstadoCredito WHERE NombreEstado='Activo'),
           DATEADD(DAY,-(n*2),CAST('2026-10-01' AS DATETIME2)),
           PlazoMeses,Enganche,MontoFinanciado,TasaInteresAnual,
           PorcentajeComision,SeguroVehiculoMensual,SeguroVidaMensual,
           ManejoCuentaMensual,Intereses,
           CAST(MontoFinanciado + Intereses +
                PlazoMeses*(SeguroVehiculoMensual+SeguroVidaMensual+ManejoCuentaMensual)
                AS DECIMAL(14,2))
    FROM Calculo B
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Credito X WHERE X.NumeroObligacion=
          CONCAT('MAGIS-DEMO-',RIGHT('0000'+CAST(B.n AS VARCHAR(4)),4)))
      AND NOT EXISTS (SELECT 1 FROM dbo.Credito X WHERE X.VIN=B.VIN);

    ;WITH F AS (
        SELECT IdFiador, ROW_NUMBER() OVER (ORDER BY IdFiador) AS rn,
               COUNT(*) OVER () AS total FROM dbo.Fiador
    ), C AS (
        SELECT IdCredito, ROW_NUMBER() OVER (ORDER BY NumeroObligacion) AS rn
        FROM dbo.Credito WHERE NumeroObligacion LIKE 'MAGIS-DEMO-%'
    )
    INSERT INTO dbo.CreditoFiador (IdCredito,IdFiador)
    SELECT C.IdCredito,F.IdFiador FROM C
    JOIN F ON F.rn=((C.rn-1)%F.total)+1
    WHERE NOT EXISTS (SELECT 1 FROM dbo.CreditoFiador CF
                      WHERE CF.IdCredito=C.IdCredito AND CF.IdFiador=F.IdFiador);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

SELECT COUNT(*) AS CreditosDemo FROM dbo.Credito WHERE NumeroObligacion LIKE 'MAGIS-DEMO-%';
SELECT COUNT(*) AS CreditosConFiador FROM dbo.CreditoFiador CF
JOIN dbo.Credito C ON C.IdCredito=CF.IdCredito
WHERE C.NumeroObligacion LIKE 'MAGIS-DEMO-%';
SELECT TOP (10) NumeroObligacion, PlazoMeses, MontoFinanciado,
       TotalIntereses, TotalRecaudable FROM dbo.Credito
WHERE NumeroObligacion LIKE 'MAGIS-DEMO-%' ORDER BY NumeroObligacion;
GO
