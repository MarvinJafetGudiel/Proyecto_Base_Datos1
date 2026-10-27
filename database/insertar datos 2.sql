USE MAGIS_AUTO;

GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM Persona WHERE DPI LIKE '9%')
BEGIN
    PRINT 'Ya existen personas de esta carga. No se insertaron duplicados.';
END
ELSE
    BEGIN
        BEGIN TRANSACTION;

        ;
        WITH Numeros AS (
        SELECT TOP (900) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
        )
        INSERT INTO Persona (DPI,NIT,NombreCompleto,CorreoElectronico,FechaNacimiento)
        SELECT CONCAT('9',RIGHT('000000000000'+CAST(n AS VARCHAR(12)),12)),
        CONCAT('DEMO-',RIGHT('000000'+CAST(n AS VARCHAR(6)),6)),
        CONCAT(CASE n%10 WHEN 0 THEN 'Ana' WHEN 1 THEN 'Carlos' WHEN 2 THEN 'Maria' WHEN 3 THEN 'Jose' WHEN 4 THEN 'Lucia' WHEN 5 THEN 'Pedro' WHEN 6 THEN 'Sofia' WHEN 7 THEN 'Luis' WHEN 8 THEN 'Elena' ELSE 'Miguel' END,
        ' ',CASE n%8 WHEN 0 THEN 'Lopez' WHEN 1 THEN 'Garcia' WHEN 2 THEN 'Perez' WHEN 3 THEN 'Ramirez' WHEN 4 THEN 'Morales' WHEN 5 THEN 'Gonzalez' WHEN 6 THEN 'Hernandez' ELSE 'Castillo' END,
        ' Demo ',n),
        CONCAT('persona',n,'@example.com'),
        DATEADD(DAY,-(n*11%12000),CONVERT(DATE,'2000-01-01'))
        FROM Numeros;

        ;
        WITH P AS (
        SELECT IdPersona, ROW_NUMBER() OVER (ORDER BY DPI) AS rn
        FROM Persona WHERE DPI LIKE '9%'
        )
        INSERT INTO Cliente (IdPersona) SELECT IdPersona FROM P WHERE rn BETWEEN 1 AND 180;

        ;
        WITH P AS (
        SELECT IdPersona, ROW_NUMBER() OVER (ORDER BY DPI) AS rn
        FROM Persona WHERE DPI LIKE '9%'
        ), A AS (
        SELECT IdAgencia, ROW_NUMBER() OVER (ORDER BY IdAgencia) AS rn FROM Agencia
        )
        INSERT INTO Vendedor (IdPersona,IdAgencia)
        SELECT P.IdPersona,A.IdAgencia FROM P JOIN A ON A.rn=((P.rn-181)%6)+1
        WHERE P.rn BETWEEN 181 AND 195;

        ;
        WITH P AS (
        SELECT IdPersona, ROW_NUMBER() OVER (ORDER BY DPI) AS rn
        FROM Persona WHERE DPI LIKE '9%'
        )
        INSERT INTO Fiador (IdPersona) SELECT IdPersona FROM P WHERE rn BETWEEN 196 AND 275;

        ;
        WITH C AS (
        SELECT IdCliente,ROW_NUMBER() OVER (ORDER BY IdCliente) AS rn FROM Cliente
        ), R AS (
        SELECT IdPersona,ROW_NUMBER() OVER (ORDER BY DPI) AS rn
        FROM Persona WHERE DPI LIKE '9%'
        )
        INSERT INTO ReferenciaPersonal (IdCliente,IdPersona,Parentesco,LugarTrabajo)
        SELECT C.IdCliente,R.IdPersona,
        CASE k.n WHEN 1 THEN 'Familiar' WHEN 2 THEN 'Amigo' ELSE 'Companero de trabajo' END,
        CONCAT('Empresa de ejemplo ',C.rn)
        FROM C CROSS JOIN (VALUES (1),(2),(3)) k(n)
        JOIN R ON R.rn=275+(C.rn-1)*3+k.n
        WHERE C.rn<=180;

        INSERT INTO DireccionPersona (IdPersona,DireccionCompleta)
        SELECT IdPersona,CONCAT('Zona ',(ABS(CHECKSUM(DPI))%20)+1,', Guatemala, direccion ficticia')
        FROM Persona WHERE DPI LIKE '9%';

        ;
        WITH T AS (SELECT IdTipoTelefono,ROW_NUMBER() OVER (ORDER BY IdTipoTelefono) rn FROM TipoTelefono)
        INSERT INTO TelefonoPersona (IdPersona,IdTipoTelefono,NumeroTelefono)
        SELECT P.IdPersona,T.IdTipoTelefono,
        CONCAT('5',RIGHT('0000000'+CAST(ABS(CHECKSUM(P.DPI))%10000000 AS VARCHAR(7)),7))
        FROM Persona P JOIN T ON T.rn=1 WHERE P.DPI LIKE '9%';
        COMMIT TRANSACTION;
    END;

    SELECT 'Persona' AS Tabla,COUNT(*) AS Registros FROM Persona
    UNION ALL SELECT 'Cliente',COUNT(*) FROM Cliente
    UNION ALL SELECT 'Vendedor',COUNT(*) FROM Vendedor
    UNION ALL SELECT 'Fiador',COUNT(*) FROM Fiador
    UNION ALL SELECT 'ReferenciaPersonal',COUNT(*) FROM ReferenciaPersonal
    UNION ALL SELECT 'DireccionPersona',COUNT(*) FROM DireccionPersona
    UNION ALL SELECT 'TelefonoPersona',COUNT(*) FROM TelefonoPersona;

GO
