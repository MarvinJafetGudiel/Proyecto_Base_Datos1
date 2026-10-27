USE MAGIS_AUTO;

GO

SELECT E.NombreEstado, COUNT(C.IdCredito) AS CantidadCreditos,
COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.EstadoCredito E
LEFT JOIN dbo.Credito C ON C.IdEstadoCredito = E.IdEstadoCredito
GROUP BY E.NombreEstado
ORDER BY CantidadCreditos DESC;

GO

SELECT C.NumeroObligacion, P.NombreCompleto AS Cliente,
SUM(Q.TotalCuota) AS TotalProgramado,
COALESCE(SUM(Pagos.TotalPagado),0) AS TotalPagado,
SUM(Q.TotalCuota) - COALESCE(SUM(Pagos.TotalPagado),0) AS SaldoPendiente
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
JOIN dbo.Persona P ON P.IdPersona = CL.IdPersona
JOIN dbo.Cuota Q ON Q.IdCredito = C.IdCredito
LEFT JOIN (
SELECT IdCuota, SUM(MontoPagado) AS TotalPagado
FROM dbo.Pago GROUP BY IdCuota
) Pagos ON Pagos.IdCuota = Q.IdCuota
GROUP BY C.NumeroObligacion, P.NombreCompleto
ORDER BY SaldoPendiente DESC;

GO

SELECT
P.NombreCompleto,
CR.NumeroObligacion,
CU.NumeroCuota,
PA.NumeroRecibo,
PA.FechaPago,
PA.MontoPagado
FROM Persona P
INNER JOIN Cliente C
ON P.IdPersona = C.IdPersona
INNER JOIN Credito CR
ON C.IdCliente = CR.IdCliente
INNER JOIN Cuota CU
ON CR.IdCredito = CU.IdCredito
INNER JOIN Pago PA
ON CU.IdCuota = PA.IdCuota
WHERE P.IdPersona = 85
ORDER BY PA.FechaPago;

SELECT A.NombreAgencia, A.Region,
COUNT(C.IdCredito) AS CantidadCreditos,
COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.Agencia A
LEFT JOIN dbo.Vendedor V ON V.IdAgencia = A.IdAgencia
LEFT JOIN dbo.Credito C ON C.IdVendedor = V.IdVendedor
GROUP BY A.NombreAgencia, A.Region
ORDER BY TotalFinanciado DESC;

GO

SELECT M.NombreMarca, COUNT(C.IdCredito) AS CantidadCreditos,
COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.Marca M
JOIN dbo.Vehiculo V ON V.IdMarca = M.IdMarca
JOIN dbo.Credito C ON C.VIN = V.VIN
GROUP BY M.NombreMarca
ORDER BY CantidadCreditos DESC;

GO

SELECT C.NumeroObligacion, P.NombreCompleto AS Cliente,
C.MontoFinanciado, C.TasaInteresAnual,
C.PlazoMeses, C.TotalIntereses, C.TotalRecaudable
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
JOIN dbo.Persona P ON P.IdPersona = CL.IdPersona
ORDER BY C.TotalIntereses DESC;

GO

SELECT C.NumeroObligacion, PC.NombreCompleto AS Cliente,
PF.NombreCompleto AS Fiador
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
JOIN dbo.Persona PC ON PC.IdPersona = CL.IdPersona
JOIN dbo.CreditoFiador CF ON CF.IdCredito = C.IdCredito
JOIN dbo.Fiador F ON F.IdFiador = CF.IdFiador
JOIN dbo.Persona PF ON PF.IdPersona = F.IdPersona
ORDER BY C.NumeroObligacion, PF.NombreCompleto;

GO

SELECT TOP (100)
C.NumeroObligacion,
Q.NumeroCuota,
Q.FechaVencimiento,
Q.TotalCuota,
ISNULL(SUM(P.MontoPagado), 0) AS TotalPagado,
Q.TotalCuota - ISNULL(SUM(P.MontoPagado), 0) AS SaldoPendiente
FROM Credito C
INNER JOIN Cuota Q ON C.IdCredito = Q.IdCredito
LEFT JOIN Pago P ON Q.IdCuota = P.IdCuota
GROUP BY C.NumeroObligacion, Q.IdCuota, Q.NumeroCuota,
Q.FechaVencimiento, Q.TotalCuota
HAVING Q.TotalCuota > ISNULL(SUM(P.MontoPagado), 0)
ORDER BY C.NumeroObligacion, Q.NumeroCuota;

GO

SELECT TOP (100)
C.NumeroObligacion,
Q.NumeroCuota,
Q.TotalCuota,
SUM(P.MontoPagado) AS TotalPagado
FROM Credito C
INNER JOIN Cuota Q ON C.IdCredito = Q.IdCredito
INNER JOIN Pago P ON Q.IdCuota = P.IdCuota
GROUP BY C.NumeroObligacion, Q.IdCuota, Q.NumeroCuota, Q.TotalCuota
HAVING SUM(P.MontoPagado) >= Q.TotalCuota
ORDER BY C.NumeroObligacion, Q.NumeroCuota;

GO

SELECT TOP (100)
C.NumeroObligacion,
Q.NumeroCuota,
Q.TotalCuota,
SUM(P.MontoPagado) AS TotalAbonado,
Q.TotalCuota - SUM(P.MontoPagado) AS SaldoPendiente
FROM Credito C
INNER JOIN Cuota Q ON C.IdCredito = Q.IdCredito
INNER JOIN Pago P ON Q.IdCuota = P.IdCuota
GROUP BY C.NumeroObligacion, Q.IdCuota, Q.NumeroCuota, Q.TotalCuota
HAVING SUM(P.MontoPagado) > 0 AND SUM(P.MontoPagado) < Q.TotalCuota
ORDER BY C.NumeroObligacion, Q.NumeroCuota;

GO

SELECT
YEAR(FechaPago) AS Anio,
MONTH(FechaPago) AS Mes,
COUNT(*) AS CantidadPagos,
SUM(MontoPagado) AS TotalRecaudado
FROM Pago
GROUP BY YEAR(FechaPago), MONTH(FechaPago)
ORDER BY Anio, Mes;

GO

SELECT TOP (20)
P.IdPersona,
P.NombreCompleto,
COUNT(CR.IdCredito) AS CantidadCreditos,
SUM(CR.MontoFinanciado) AS TotalFinanciado
FROM Persona P
INNER JOIN Cliente CL ON P.IdPersona = CL.IdPersona
INNER JOIN Credito CR ON CL.IdCliente = CR.IdCliente
GROUP BY P.IdPersona, P.NombreCompleto
ORDER BY TotalFinanciado DESC;

GO

SELECT
(SELECT COUNT(*) FROM Credito) AS CantidadCreditos,
(SELECT ISNULL(SUM(MontoFinanciado), 0) FROM Credito) AS TotalFinanciado,
(SELECT ISNULL(SUM(TotalRecaudable), 0) FROM Credito) AS TotalRecaudable,
(SELECT COUNT(*) FROM Cuota) AS CantidadCuotas,
(SELECT ISNULL(SUM(TotalCuota), 0) FROM Cuota) AS TotalProgramadoCuotas,
(SELECT COUNT(*) FROM Pago) AS CantidadPagos,
(SELECT ISNULL(SUM(MontoPagado), 0) FROM Pago) AS TotalPagado;

GO
