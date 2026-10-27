USE MAGIS_AUTO;

GO

DECLARE @Inicio1 DATE = '2026-01-01', @Fin1 DATE = '2026-12-31';
SELECT C.NumeroObligacion, C.FechaAprobacion, P.NombreCompleto AS Cliente,
C.MontoFinanciado, C.TotalRecaudable
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente=C.IdCliente
JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
WHERE C.FechaAprobacion >= @Inicio1 AND C.FechaAprobacion < DATEADD(DAY,1,@Fin1)
ORDER BY C.FechaAprobacion;

GO

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

DECLARE @Inicio3 DATE='2026-01-01', @Fin3 DATE='2026-12-31';
SELECT M.NombreMedio, COUNT(*) AS CantidadPagos, SUM(P.MontoPagado) AS TotalRecaudado
FROM dbo.Pago P
JOIN dbo.MedioPago M ON M.IdMedioPago=P.IdMedioPago
WHERE P.FechaPago>=@Inicio3 AND P.FechaPago<DATEADD(DAY,1,@Fin3)
GROUP BY M.NombreMedio ORDER BY TotalRecaudado DESC;

GO

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

DECLARE @Mes5 INT=10;
SELECT P.NombreCompleto, P.FechaNacimiento, P.CorreoElectronico,
CONCAT('Feliz cumpleaños, ',P.NombreCompleto,'; MAGIS-AUTO le desea un excelente día.') AS Mensaje
FROM dbo.Cliente CL
JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
WHERE MONTH(P.FechaNacimiento)=@Mes5
ORDER BY DAY(P.FechaNacimiento),P.NombreCompleto;

GO

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
