USE MAGIS_AUTO;
GO
SET NOCOUNT ON;

INSERT INTO TipoTelefono (Descripcion)
SELECT v.Descripcion FROM (VALUES ('Celular'),('Casa'),('Trabajo')) v(Descripcion)
WHERE NOT EXISTS (SELECT 1 FROM TipoTelefono t WHERE t.Descripcion=v.Descripcion);

INSERT INTO Marca (NombreMarca)
SELECT v.NombreMarca FROM (VALUES ('Toyota'),('Honda'),('Hyundai'),('Mazda'),('Kia'),('Nissan'),('Suzuki'),('Mitsubishi'),('Ford'),('Volkswagen'),('Chevrolet'),('Isuzu')) v(NombreMarca)
WHERE NOT EXISTS (SELECT 1 FROM Marca m WHERE m.NombreMarca=v.NombreMarca);

INSERT INTO Agencia (NombreAgencia, Region)
SELECT v.NombreAgencia,v.Region FROM (VALUES
('MAGIS Central','Guatemala'),('MAGIS Jalapa','Jalapa'),('MAGIS Xela','Quetzaltenango'),
('MAGIS Escuintla','Escuintla'),('MAGIS Coban','Alta Verapaz'),('MAGIS Zacapa','Zacapa')) v(NombreAgencia,Region)
WHERE NOT EXISTS (SELECT 1 FROM Agencia a WHERE a.NombreAgencia=v.NombreAgencia AND a.Region=v.Region);

INSERT INTO EstadoCredito (NombreEstado)
SELECT v.NombreEstado FROM (VALUES ('Activo'),('Cancelado'),('En mora'),('Pendiente')) v(NombreEstado)
WHERE NOT EXISTS (SELECT 1 FROM EstadoCredito e WHERE e.NombreEstado=v.NombreEstado);

INSERT INTO MedioPago (NombreMedio)
SELECT v.NombreMedio FROM (VALUES ('Efectivo'),('Transferencia bancaria'),('Deposito bancario'),('Tarjeta de debito'),('Cheque')) v(NombreMedio)
WHERE NOT EXISTS (SELECT 1 FROM MedioPago p WHERE p.NombreMedio=v.NombreMedio);

SELECT 'TipoTelefono' AS Tabla,COUNT(*) AS Registros FROM TipoTelefono
UNION ALL SELECT 'Marca',COUNT(*) FROM Marca
UNION ALL SELECT 'Agencia',COUNT(*) FROM Agencia
UNION ALL SELECT 'EstadoCredito',COUNT(*) FROM EstadoCredito
UNION ALL SELECT 'MedioPago',COUNT(*) FROM MedioPago;
GO
