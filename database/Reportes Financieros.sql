USE MAGIS_AUTO;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_01
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio1 DATE = COALESCE(@Inicio, CONVERT(DATE,'2000-01-01')), @Fin1 DATE = COALESCE(@Fin, CONVERT(DATE,'2100-12-31'));
    SELECT C.NumeroObligacion, C.FechaAprobacion, P.NombreCompleto AS Cliente,
    C.MontoFinanciado, C.TotalRecaudable
    FROM dbo.Credito C
    JOIN dbo.Cliente CL ON CL.IdCliente=C.IdCliente
    JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
    WHERE C.FechaAprobacion >= @Inicio1 AND C.FechaAprobacion < DATEADD(DAY,1,@Fin1)
    ORDER BY C.FechaAprobacion;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_02
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaCorte2 DATE = COALESCE(@FechaCorte, CAST(GETDATE() AS DATE)), @MinDias2 INT = @MinDias;
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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_03
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio3 DATE = COALESCE(@Inicio, CONVERT(DATE,'2000-01-01')), @Fin3 DATE = COALESCE(@Fin, CONVERT(DATE,'2100-12-31'));
    SELECT M.NombreMedio, COUNT(*) AS CantidadPagos, SUM(P.MontoPagado) AS TotalRecaudado
    FROM dbo.Pago P
    JOIN dbo.MedioPago M ON M.IdMedioPago=P.IdMedioPago
    WHERE P.FechaPago>=@Inicio3 AND P.FechaPago<DATEADD(DAY,1,@Fin3)
    GROUP BY M.NombreMedio ORDER BY TotalRecaudado DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_04
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT P.NombreCompleto AS Vendedor, A.NombreAgencia,
    COUNT(C.IdCredito) AS CreditosEmitidos,
    COALESCE(SUM(C.MontoFinanciado),0) AS MontoFinanciado
    FROM dbo.Vendedor V
    JOIN dbo.Persona P ON P.IdPersona=V.IdPersona
    JOIN dbo.Agencia A ON A.IdAgencia=V.IdAgencia
    LEFT JOIN dbo.Credito C ON C.IdVendedor=V.IdVendedor
    GROUP BY V.IdVendedor,P.NombreCompleto,A.NombreAgencia
    ORDER BY MontoFinanciado DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_05
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mes5 INT = COALESCE(@Mes, MONTH(GETDATE()));
    SELECT P.NombreCompleto, P.FechaNacimiento, P.CorreoElectronico,
    CONCAT('Feliz cumpleaños, ',P.NombreCompleto,'; MAGIS-AUTO le desea un excelente día.') AS Mensaje
    FROM dbo.Cliente CL
    JOIN dbo.Persona P ON P.IdPersona=CL.IdPersona
    WHERE MONTH(P.FechaNacimiento)=@Mes5
    ORDER BY DAY(P.FechaNacimiento),P.NombreCompleto;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_06
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdCliente6 INT = @IdCliente;
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
    WHERE (@IdCliente6 IS NULL OR CL.IdCliente=@IdCliente6)
    ORDER BY C.NumeroObligacion;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_07
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NumeroCredito7 VARCHAR(30) = @NumeroCredito;
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
    WHERE (@NumeroCredito7 IS NULL OR C.NumeroObligacion=@NumeroCredito7)
    ORDER BY Q.NumeroCuota;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_08
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT E.NombreEstado, COUNT(C.IdCredito) AS CantidadCreditos,
    COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
    FROM dbo.EstadoCredito E
    LEFT JOIN dbo.Credito C ON C.IdEstadoCredito = E.IdEstadoCredito
    GROUP BY E.NombreEstado
    ORDER BY CantidadCreditos DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_09
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_10
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NumeroObligacion VARCHAR(30) = @NumeroCredito;
    SELECT C.NumeroObligacion, PE.NombreCompleto AS Cliente,
    Q.NumeroCuota, PA.NumeroRecibo, PA.FechaPago,
    PA.MontoPagado, M.NombreMedio
    FROM dbo.Pago PA
    JOIN dbo.Cuota Q ON Q.IdCuota = PA.IdCuota
    JOIN dbo.Credito C ON C.IdCredito = Q.IdCredito
    JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
    JOIN dbo.Persona PE ON PE.IdPersona = CL.IdPersona
    JOIN dbo.MedioPago M ON M.IdMedioPago = PA.IdMedioPago
    WHERE (@NumeroObligacion IS NULL OR C.NumeroObligacion = @NumeroObligacion)
    ORDER BY PA.FechaPago, PA.NumeroRecibo;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_11
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.NombreAgencia, A.Region,
    COUNT(C.IdCredito) AS CantidadCreditos,
    COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
    FROM dbo.Agencia A
    LEFT JOIN dbo.Vendedor V ON V.IdAgencia = A.IdAgencia
    LEFT JOIN dbo.Credito C ON C.IdVendedor = V.IdVendedor
    GROUP BY A.NombreAgencia, A.Region
    ORDER BY TotalFinanciado DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_12
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT M.NombreMarca, COUNT(C.IdCredito) AS CantidadCreditos,
    COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
    FROM dbo.Marca M
    JOIN dbo.Vehiculo V ON V.IdMarca = M.IdMarca
    JOIN dbo.Credito C ON C.VIN = V.VIN
    GROUP BY M.NombreMarca
    ORDER BY CantidadCreditos DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_13
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT C.NumeroObligacion, P.NombreCompleto AS Cliente,
    C.MontoFinanciado, C.TasaInteresAnual,
    C.PlazoMeses, C.TotalIntereses, C.TotalRecaudable
    FROM dbo.Credito C
    JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
    JOIN dbo.Persona P ON P.IdPersona = CL.IdPersona
    ORDER BY C.TotalIntereses DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_14
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT C.NumeroObligacion, PC.NombreCompleto AS Cliente,
    PF.NombreCompleto AS Fiador
    FROM dbo.Credito C
    JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
    JOIN dbo.Persona PC ON PC.IdPersona = CL.IdPersona
    JOIN dbo.CreditoFiador CF ON CF.IdCredito = C.IdCredito
    JOIN dbo.Fiador F ON F.IdFiador = CF.IdFiador
    JOIN dbo.Persona PF ON PF.IdPersona = F.IdPersona
    ORDER BY C.NumeroObligacion, PF.NombreCompleto;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_15
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_16
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_17
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_18
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
    YEAR(FechaPago) AS Anio,
    MONTH(FechaPago) AS Mes,
    COUNT(*) AS CantidadPagos,
    SUM(MontoPagado) AS TotalRecaudado
    FROM Pago
    GROUP BY YEAR(FechaPago), MONTH(FechaPago)
    ORDER BY Anio, Mes;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_19
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

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
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_20
    @Inicio DATE = NULL,
    @Fin DATE = NULL,
    @FechaCorte DATE = NULL,
    @MinDias INT = 1,
    @Mes INT = NULL,
    @IdCliente INT = NULL,
    @NumeroCredito VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
    (SELECT COUNT(*) FROM Credito) AS CantidadCreditos,
    (SELECT ISNULL(SUM(MontoFinanciado), 0) FROM Credito) AS TotalFinanciado,
    (SELECT ISNULL(SUM(TotalRecaudable), 0) FROM Credito) AS TotalRecaudable,
    (SELECT COUNT(*) FROM Cuota) AS CantidadCuotas,
    (SELECT ISNULL(SUM(TotalCuota), 0) FROM Cuota) AS TotalProgramadoCuotas,
    (SELECT COUNT(*) FROM Pago) AS CantidadPagos,
    (SELECT ISNULL(SUM(MontoPagado), 0) FROM Pago) AS TotalPagado;
END;

GO
