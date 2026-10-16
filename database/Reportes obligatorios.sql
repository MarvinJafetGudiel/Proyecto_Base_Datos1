USE MAGIS_AUTO;
GO
-- MAGIS-AUTO Reportes financieros 1 al 7 

-- 1. Reporte de todos los créditos emitidos en un período de tiempo. La razón de este reporte es analizar el volumen de
--ventas realizadas por un período especifico de tiempo.
DECLARE @Inicio1 DATE = '2026-01-01', @Fin1 DATE = '2026-12-31';
SELECT C.NumeroObligacion, C.FechaAprobacion, P.NombreCompleto AS Cliente,
       C.MontoFinanciado, C.TotalRecaudable
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente=C.IdCliente
JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
WHERE C.FechaAprobacion >= @Inicio1 AND C.FechaAprobacion < DATEADD(DAY,1,@Fin1)
ORDER BY C.FechaAprobacion;
GO

-- 2. Reporte de cartera en mora. Muestra todos los créditos que a la fecha está pendientes de pago y presentan X
--cantidad de días de atraso.
DECLARE @FechaCorte2 DATE = '2026-10-15', @MinDias2 INT = 1;
WITH Pagos AS (
 SELECT IdCuota, SUM(MontoPagado) AS Abonado FROM dbo.Pago
 WHERE FechaPago < DATEADD(DAY,1,@FechaCorte2)
 GROUP BY IdCuota
)
SELECT C.NumeroObligacion, P.NombreCompleto AS Cliente,
       Q.NumeroCuota, Q.FechaVencimiento,
       DATEDIFF(DAY,Q.FechaVencimiento,@FechaCorte2) AS DiasAtraso,
       Q.TotalCuota-COALESCE(PG.Abonado,0) AS SaldoVencido
FROM dbo.Cuota Q
JOIN dbo.Credito C ON C.IdCredito=Q.IdCredito
JOIN dbo.Cliente CL ON CL.IdCliente=C.IdCliente
JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
LEFT JOIN Pagos PG ON PG.IdCuota=Q.IdCuota
WHERE Q.FechaVencimiento < @FechaCorte2
  AND DATEDIFF(DAY,Q.FechaVencimiento,@FechaCorte2)>=@MinDias2
  AND Q.TotalCuota>COALESCE(PG.Abonado,0)
ORDER BY DiasAtraso DESC, C.NumeroObligacion;
GO

-- 3. Reporte de pagos realizados en un período de tiempo dado por tipo de pago. Muestra el movimiento de pagos por tipo
--de pago y así determinar cuál es el medio de pago más utilizado en un tiempo dado.
DECLARE @Inicio3 DATE='2026-01-01', @Fin3 DATE='2026-12-31';
SELECT M.NombreMedio, COUNT(*) AS CantidadPagos, SUM(P.MontoPagado) AS TotalRecaudado
FROM dbo.Pago P
JOIN dbo.MedioPago M ON M.IdMedioPago=P.IdMedioPago
WHERE P.FechaPago>=@Inicio3 AND P.FechaPago<DATEADD(DAY,1,@Fin3)
GROUP BY M.NombreMedio ORDER BY TotalRecaudado DESC;
GO

-- 4. Reporte de ventas por vendedor. Muestra el total de ventas por vendedor con el objetivo de determinar el mejor
--vendedor de créditos.
SELECT P.NombreCompleto AS Vendedor, A.NombreAgencia,
       COUNT(C.IdCredito) AS CreditosEmitidos,
       COALESCE(SUM(C.MontoFinanciado),0) AS MontoFinanciado
FROM dbo.Vendedor V
JOIN dbo.Persona P ON P.IdPersona=V.IdPersona
JOIN dbo.Agencia A ON A.IdAgencia=V.IdAgencia
LEFT JOIN dbo.Credito C ON C.IdVendedor=V.IdVendedor
GROUP BY V.IdVendedor,P.NombreCompleto,A.NombreAgencia
ORDER BY MontoFinanciado DESC;
GO

-- 5. Reporte de cumpleañeros del mes. Hacer una carta de felicitación para cada cliente por su fecha de cumpleaños
DECLARE @Mes5 INT=10;
SELECT P.NombreCompleto, P.FechaNacimiento, P.CorreoElectronico,
       CONCAT('Feliz cumpleaños, ',P.NombreCompleto,'; MAGIS-AUTO le desea un excelente día.') AS Mensaje
FROM dbo.Cliente CL
JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
WHERE MONTH(P.FechaNacimiento)=@Mes5
ORDER BY DAY(P.FechaNacimiento),P.NombreCompleto;
GO

-- 6. Estado de cuenta por cliente
DECLARE @IdCliente6 INT=(SELECT MIN(IdCliente) FROM dbo.Cliente);
WITH Abonos AS (
 SELECT Q.IdCredito,SUM(P.MontoPagado) AS TotalPagado
 FROM dbo.Cuota Q JOIN dbo.Pago P ON P.IdCuota=Q.IdCuota
 GROUP BY Q.IdCredito
)
SELECT CL.IdCliente, PE.NombreCompleto, C.NumeroObligacion,
       C.TotalRecaudable,COALESCE(A.TotalPagado,0) AS TotalPagado,
       C.TotalRecaudable-COALESCE(A.TotalPagado,0) AS SaldoPendiente
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente=C.IdCliente
JOIN dbo.Persona PE ON PE.IdPersona=CL.IdPersona
LEFT JOIN Abonos A ON A.IdCredito=C.IdCredito
WHERE CL.IdCliente=@IdCliente6
ORDER BY C.NumeroObligacion;
GO

-- 7. Plan de pagos por crédito
DECLARE @NumeroCredito7 VARCHAR(30)='MAGIS-DEMO-0001';
WITH Abonos AS (
 SELECT IdCuota,SUM(MontoPagado) AS TotalPagado FROM dbo.Pago GROUP BY IdCuota
)
SELECT C.NumeroObligacion,Q.NumeroCuota,Q.FechaVencimiento,
       Q.Capital,Q.Interes,Q.ManejoCuenta,Q.SeguroVehiculo,Q.SeguroVida,
       Q.TotalCuota,COALESCE(A.TotalPagado,0) AS TotalPagado,
       Q.TotalCuota-COALESCE(A.TotalPagado,0) AS SaldoPendiente
FROM dbo.Cuota Q
JOIN dbo.Credito C ON C.IdCredito=Q.IdCredito
LEFT JOIN Abonos A ON A.IdCuota=Q.IdCuota
WHERE C.NumeroObligacion=@NumeroCredito7
ORDER BY Q.NumeroCuota;
GO
