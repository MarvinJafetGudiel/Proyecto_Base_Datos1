USE MAGIS_AUTO;
GO

/*
Consulta 8. Créditos por estado
Esta consulta permite conocer cuántos créditos se encuentran registrados en cada estado y cuánto dinero
se ha financiado en cada uno. Su utilidad es ayudar a la empresa a llevar un mejor control de los créditos,
ver cómo se encuentra distribuida su cartera y hacer mas facil la revisión de la información financiera. */
SELECT E.NombreEstado, COUNT(C.IdCredito) AS CantidadCreditos,
       COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.EstadoCredito E
LEFT JOIN dbo.Credito C ON C.IdEstadoCredito = E.IdEstadoCredito
GROUP BY E.NombreEstado
ORDER BY CantidadCreditos DESC;
GO

/*
Consulta 9. Saldo pendiente por cada crédito
Esta consulta permite conocer cuánto dinero falta por pagar en cada crédito. Para eso
se toma el total de las cuotas programadas y se le restan los pagos que el cliente ha realizado.
Es útil para llevar un control de las deudas pendientes y conocer cuánto dinero queda por recuperar de cada financiamiento. 
*/
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

/*
Consulta 10. Historial de pagos por cliente
Esta consulta permite verificar los pagos que ha realizado un cliente en sus créditos.
Muestra información como el nombre del cliente, número de crédito, número de cuota, recibo,
fecha y monto pagado. Su utilidad es mantener un registro de los pagos realizados, y resolver
cualquier duda a los clientes.
*/
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

/*
Consulta 11. Créditos por agencia
Esta consulta permite ver cuántos créditos han sido gestionados por los vendedores de cada agencia
y el monto total financiado. Es útil para comparar los resultados de las diferentes agencias, 
identificar cuáles tienen mayor actividad comercial y evaluar la participación en los financiamientos de la empresa.
*/
SELECT A.NombreAgencia, A.Region,
       COUNT(C.IdCredito) AS CantidadCreditos,
       COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.Agencia A
LEFT JOIN dbo.Vendedor V ON V.IdAgencia = A.IdAgencia
LEFT JOIN dbo.Credito C ON C.IdVendedor = V.IdVendedor
GROUP BY A.NombreAgencia, A.Region
ORDER BY TotalFinanciado DESC;
GO

/*
Consulta 12. Vehículos financiados por marca
Esta consulta permite ver las marcas de vehículos que tienen más créditos registrados, 
mostrando la cantidad de financiamientos y el dinero financiado por cada marca.
Es util para conocer cuáles son las marcas con mayor demanda de financiamiento y ayudar
a la empresa a tomar decisiones.
*/
SELECT M.NombreMarca, COUNT(C.IdCredito) AS CantidadCreditos,
       COALESCE(SUM(C.MontoFinanciado),0) AS TotalFinanciado
FROM dbo.Marca M
JOIN dbo.Vehiculo V ON V.IdMarca = M.IdMarca
JOIN dbo.Credito C ON C.VIN = V.VIN
GROUP BY M.NombreMarca
ORDER BY CantidadCreditos DESC;
GO

/*
Consulta 13. Intereses por crédito
Esta consulta permite ver la información financiera de cada crédito, incluyendo el monto financiado,
la tasa de interés anual, el plazo en meses, el total de intereses y el monto total que se espera recaudar.
Es útil para conocer el costo financiero de los créditos y comparar cuáles generan mayores intereses.
*/
SELECT C.NumeroObligacion, P.NombreCompleto AS Cliente,
       C.MontoFinanciado, C.TasaInteresAnual,
       C.PlazoMeses, C.TotalIntereses, C.TotalRecaudable
FROM dbo.Credito C
JOIN dbo.Cliente CL ON CL.IdCliente = C.IdCliente
JOIN dbo.Persona P ON P.IdPersona = CL.IdPersona
ORDER BY C.TotalIntereses DESC;
GO

/*
Consulta 14. Créditos con fiadores
Esta consulta permite identificar los créditos que tienen uno o varios fiadores registrados, mostrando el nombre
del cliente y de las personas que respaldan su financiamiento. Su utilidad es ver facilmente las garantías
personales y mantener organizada la información de los fiadores asociados a cada crédito.
*/
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

/*
Consulta 15. Cuotas con saldo pendiente
Esta consulta permite identificar las cuotas que todavía no han sido pagadas completamente. Muestra el número de crédito,
la cuota, su fecha de vencimiento, el monto total, lo que se ha pagado y el saldo pendiente. Es útil para conocer qué pagos
faltan por completar y llevar un mejor control de los clientes.
*/
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

/*
Consulta 16. Cuotas pagadas completamente
Esta consulta permite conocer cuáles son las cuotas que ya fueron pagadas en su totalidad. 
Compara el monto de cada cuota con la suma de los pagos realizados para determinar si ya está cancelada.
Su utilidad es comprobar los pagos completados y mantener un registro claro de las cuotas que los clientes ya pagaron.
*/
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

/*
Consulta 17. Cuotas con abonos parciales
Esta consulta permite ver las cuotas en las que el cliente ha realizado uno o mas abonos,
pero que todavía tiene una cantidad pendiente por pagar. Es útil para dar seguimiento a los pagos parciales,
conocer cuánto dinero se ha abonado y calcular cuánto falta para completar cada cuota.
*/
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

/*
Consulta 18. Recaudación mensual
Esta consulta permite conocer cuánto dinero ha recibido la empresa durante cada mes, tomando en cuenta los pagos registrados.
También muestra la cantidad de pagos realizados en ese período. es util para llevar un control de los ingresos por cobros,
comparar los resultados mensuales y conocer cómo se comporta la recaudación de la empresa.
*/
SELECT
    YEAR(FechaPago) AS Anio,
    MONTH(FechaPago) AS Mes,
    COUNT(*) AS CantidadPagos,
    SUM(MontoPagado) AS TotalRecaudado
FROM Pago
GROUP BY YEAR(FechaPago), MONTH(FechaPago)
ORDER BY Anio, Mes;
GO

/*
Consulta 19. Clientes con mayor monto financiado
Esta consulta permite ver a los 20 clientes que tienen la mayor cantidad de dinero financiado por la empresa.
Muestra el nombre del cliente, la cantidad de créditos que tiene y el monto total financiado. su utilidad es para conocer
cuáles son los clientes con mayores compromisos financieros y facilita el seguimiento de sus créditos.
*/
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

/*
Consulta 20. Resumen general de cartera
Esta consulta permite tener un resumen general de la información financiera de MAGIS-AUTO ya que muestra la cantidad de créditos,
el dinero financiado, el total que se espera recaudar, las cuotas registradas y los pagos realizados. Su utilidad es presentar 
en un solo reporte los datos más importantes de la cartera de créditos y facilitar la revisión de la situación financiera de la empresa.
*/
SELECT
    (SELECT COUNT(*) FROM Credito) AS CantidadCreditos,
    (SELECT ISNULL(SUM(MontoFinanciado), 0) FROM Credito) AS TotalFinanciado,
    (SELECT ISNULL(SUM(TotalRecaudable), 0) FROM Credito) AS TotalRecaudable,
    (SELECT COUNT(*) FROM Cuota) AS CantidadCuotas,
    (SELECT ISNULL(SUM(TotalCuota), 0) FROM Cuota) AS TotalProgramadoCuotas,
    (SELECT COUNT(*) FROM Pago) AS CantidadPagos,
    (SELECT ISNULL(SUM(MontoPagado), 0) FROM Pago) AS TotalPagado;
GO
