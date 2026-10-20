USE MAGIS_AUTO;
GO
-- SOLO LECTURA: no borra ni cambia información.
SELECT 'Tablas originales' AS Comprobacion, COUNT(*) AS Cantidad
FROM sys.tables WHERE name IN ('Persona','TipoTelefono','TelefonoPersona','DireccionPersona','Cliente','ReferenciaPersonal','Marca','Vehiculo','Agencia','Vendedor','Fiador','EstadoCredito','Credito','CreditoFiador','Cuota','MedioPago','Pago');
SELECT 'Reportes financieros' AS Comprobacion, COUNT(*) AS Cantidad FROM sys.procedures WHERE name LIKE 'usp_Reporte_[0-9][0-9]';
SELECT 'Procedimientos API' AS Comprobacion, COUNT(*) AS Cantidad FROM sys.procedures WHERE name LIKE 'usp_API_%';
SELECT 'Procedimientos CRUD originales' AS Comprobacion, COUNT(*) AS Cantidad FROM sys.procedures WHERE name LIKE 'usp_%' AND name NOT LIKE 'usp_API_%' AND name NOT LIKE 'usp_Reporte_%';
SELECT 'Vehiculos sin clasificar' AS Comprobacion, COUNT(*) AS Cantidad FROM dbo.Vehiculo WHERE EsNuevo IS NULL OR IdAgenciaOrigen IS NULL;
SELECT 'Vehiculos nuevos de agencia sin credito' AS Comprobacion, COUNT(*) AS Cantidad FROM dbo.Vehiculo V
WHERE V.EsNuevo=1 AND V.IdAgenciaOrigen IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Credito C WHERE C.VIN=V.VIN);
SELECT 'Clientes con menos de tres referencias' AS Comprobacion, COUNT(*) AS Cantidad
FROM dbo.Cliente C WHERE (SELECT COUNT(*) FROM dbo.ReferenciaPersonal R WHERE R.IdCliente=C.IdCliente)<3;
SELECT (SELECT COUNT(*) FROM dbo.Persona) AS Personas,
 (SELECT COUNT(*) FROM dbo.Cliente) AS Clientes,
 (SELECT COUNT(*) FROM dbo.Vehiculo) AS Vehiculos,
 (SELECT COUNT(*) FROM dbo.Credito) AS Creditos,
 (SELECT COUNT(*) FROM dbo.Cuota) AS Cuotas,
 (SELECT COUNT(*) FROM dbo.Pago) AS Pagos;
GO
