USE MAGIS_AUTO;

GO

IF COL_LENGTH('dbo.Vehiculo','EsNuevo') IS NULL

ALTER TABLE dbo.Vehiculo ADD EsNuevo BIT NULL;

GO

IF COL_LENGTH('dbo.Vehiculo','IdAgenciaOrigen') IS NULL

ALTER TABLE dbo.Vehiculo ADD IdAgenciaOrigen INT NULL;

GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_Vehiculo_AgenciaOrigen')

ALTER TABLE dbo.Vehiculo ADD CONSTRAINT FK_Vehiculo_AgenciaOrigen FOREIGN KEY (IdAgenciaOrigen) REFERENCES dbo.Agencia(IdAgencia);

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Agencias_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdAgencia,NombreAgencia,Region FROM dbo.Agencia ORDER BY NombreAgencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT V.VIN,V.IdMarca,M.NombreMarca,V.Modelo,V.AnioFabricacion,V.ValorAgencia,V.Placa,
    V.EsNuevo,V.IdAgenciaOrigen,A.NombreAgencia AS AgenciaOrigen
    FROM dbo.Vehiculo V JOIN dbo.Marca M ON M.IdMarca=V.IdMarca
    LEFT JOIN dbo.Agencia A ON A.IdAgencia=V.IdAgenciaOrigen
    ORDER BY V.Modelo,V.VIN;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Crear
    @p1 VARCHAR(17),@p2 INT,@p3 VARCHAR(100),@p4 SMALLINT,@p5 DECIMAL(12,2),@p6 VARCHAR(15),
    @EsNuevo BIT=NULL,@IdAgencia INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @EsNuevo=1 AND @IdAgencia IS NULL THROW 51021,'Un vehiculo nuevo necesita agencia de origen.',1;
    IF @IdAgencia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Agencia WHERE IdAgencia=@IdAgencia)
    THROW 51022,'Agencia de origen inexistente.',1;
    INSERT INTO dbo.Vehiculo(VIN,IdMarca,Modelo,AnioFabricacion,ValorAgencia,Placa,EsNuevo,IdAgenciaOrigen)
    OUTPUT INSERTED.VIN VALUES(@p1,@p2,@p3,@p4,@p5,@p6,@EsNuevo,@IdAgencia);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Actualizar
    @p1 INT,@p2 VARCHAR(100),@p3 SMALLINT,@p4 DECIMAL(12,2),@p5 VARCHAR(15),@p6 VARCHAR(17),
    @EsNuevo BIT=NULL,@IdAgencia INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @EsNuevo=1 AND @IdAgencia IS NULL THROW 51021,'Un vehiculo nuevo necesita agencia de origen.',1;
    IF @IdAgencia IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.Agencia WHERE IdAgencia=@IdAgencia)
    THROW 51022,'Agencia de origen inexistente.',1;

    IF EXISTS(SELECT 1 FROM dbo.Credito WHERE VIN=@p6)
    BEGIN
        IF EXISTS(SELECT 1 FROM dbo.Vehiculo WHERE VIN=@p6 AND (IdMarca<>@p1 OR Modelo<>@p2 OR AnioFabricacion<>@p3 OR ValorAgencia<>@p4))
        THROW 51023,'Vehiculo financiado: no se pueden cambiar sus datos financieros.',1;
    END;
    UPDATE dbo.Vehiculo SET IdMarca=@p1,Modelo=@p2,AnioFabricacion=@p3,ValorAgencia=@p4,
    Placa=@p5,EsNuevo=@EsNuevo,IdAgenciaOrigen=@IdAgencia
    OUTPUT INSERTED.VIN WHERE VIN=@p6;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Cliente_Contacto_Consultar @IdCliente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.IdCliente,
    (SELECT TOP(1) T.NumeroTelefono FROM dbo.TelefonoPersona T WHERE T.IdPersona=C.IdPersona ORDER BY T.IdTelefono DESC) AS Telefono,
    (SELECT TOP(1) D.DireccionCompleta FROM dbo.DireccionPersona D WHERE D.IdPersona=C.IdPersona ORDER BY D.IdDireccion DESC) AS Direccion
    FROM dbo.Cliente C WHERE C.IdCliente=@IdCliente;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Cliente_Contacto_Guardar @IdCliente INT,@Telefono VARCHAR(15)=NULL,@Direccion VARCHAR(250)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Persona INT,@Tipo INT;
        SELECT @Persona=IdPersona FROM dbo.Cliente WHERE IdCliente=@IdCliente;
        IF @Persona IS NULL THROW 51024,'Cliente no encontrado.',1;
        IF NULLIF(LTRIM(RTRIM(@Telefono)),'') IS NOT NULL
        BEGIN
            SELECT TOP(1) @Tipo=IdTipoTelefono FROM dbo.TipoTelefono ORDER BY IdTipoTelefono;
            IF @Tipo IS NULL THROW 51025,'No hay tipos de telefono configurados.',1;
            IF NOT EXISTS(SELECT 1 FROM dbo.TelefonoPersona WHERE IdPersona=@Persona AND NumeroTelefono=@Telefono)
            INSERT INTO dbo.TelefonoPersona(IdPersona,IdTipoTelefono,NumeroTelefono) VALUES(@Persona,@Tipo,@Telefono);
        END;
        IF NULLIF(LTRIM(RTRIM(@Direccion)),'') IS NOT NULL AND
        NOT EXISTS(SELECT 1 FROM dbo.DireccionPersona WHERE IdPersona=@Persona AND DireccionCompleta=@Direccion)
        INSERT INTO dbo.DireccionPersona(IdPersona,DireccionCompleta) VALUES(@Persona,@Direccion);
        COMMIT;
        SELECT 'Contacto guardado' AS Mensaje;
    END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK;
    THROW;
END CATCH;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_04
    @Inicio DATE=NULL,@Fin DATE=NULL,@FechaCorte DATE=NULL,@MinDias INT=1,
    @Mes INT=NULL,@IdCliente INT=NULL,@NumeroCredito VARCHAR(30)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT P.NombreCompleto AS Vendedor,A.NombreAgencia,
    COUNT(C.IdCredito) AS CreditosEmitidos,COALESCE(SUM(C.MontoFinanciado),0) AS MontoFinanciado
    FROM dbo.Vendedor V JOIN dbo.Persona P ON P.IdPersona=V.IdPersona
    JOIN dbo.Agencia A ON A.IdAgencia=V.IdAgencia
    LEFT JOIN dbo.Credito C ON C.IdVendedor=V.IdVendedor
    AND (@Inicio IS NULL OR C.FechaAprobacion>=@Inicio)
    AND (@Fin IS NULL OR C.FechaAprobacion<DATEADD(DAY,1,@Fin))
    GROUP BY V.IdVendedor,P.NombreCompleto,A.NombreAgencia
    ORDER BY MontoFinanciado DESC;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Creditos_Crear
    @p1 VARCHAR(30),
    @p2 INT,
    @p3 INT,
    @p4 VARCHAR(17),
    @p5 DECIMAL(12,2),
    @p6 INT,
    @p7 DECIMAL(6,3)
AS
BEGIN
    SET NOCOUNT ON;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Numero VARCHAR(30) = @p1;
        DECLARE @Cliente INT = @p2;
        DECLARE @Vendedor INT = @p3;
        DECLARE @VIN VARCHAR(17) = @p4;
        DECLARE @Enganche DECIMAL(12,2) = @p5;
        DECLARE @Plazo INT = @p6;
        DECLARE @Tasa DECIMAL(6,3) = @p7;

        DECLARE @Valor DECIMAL(12,2);
        DECLARE @Monto DECIMAL(12,2);
        DECLARE @Intereses DECIMAL(14,2);
        DECLARE @Total DECIMAL(14,2);
        DECLARE @Estado INT;
        DECLARE @IdCredito INT;
        DECLARE @i INT = 1;
        DECLARE @Capital DECIMAL(12,2);
        DECLARE @Interes DECIMAL(12,2);
        DECLARE @CapitalPrevio DECIMAL(12,2) = 0;
        DECLARE @InteresPrevio DECIMAL(12,2) = 0;
        DECLARE @Fecha DATETIME2 = SYSDATETIME();

        SELECT @Valor = ValorAgencia
        FROM Vehiculo WITH (UPDLOCK, HOLDLOCK)
        WHERE VIN = @VIN;

        IF @Valor IS NULL
        THROW 50001, 'El vehiculo no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.Vehiculo WHERE VIN=@VIN AND EsNuevo=1 AND IdAgenciaOrigen IS NOT NULL)
        THROW 51020, 'Solo se financian vehiculos nuevos de agencia. Clasifique el vehiculo y registre su agencia de origen.', 1;

        IF EXISTS (
        SELECT 1 FROM Credito WHERE VIN = @VIN
        )
        THROW 50002, 'El vehiculo ya tiene un credito.', 1;

        IF @Enganche >= @Valor
        THROW 50003, 'El enganche es demasiado alto.', 1;

        IF NOT EXISTS (
        SELECT 1 FROM Cliente WHERE IdCliente = @Cliente
        )
        THROW 50004, 'El cliente no existe.', 1;

        IF (SELECT COUNT(*) FROM dbo.ReferenciaPersonal WITH (HOLDLOCK)
        WHERE IdCliente=@Cliente) < 3
        THROW 51015, 'El cliente necesita tres referencias personales antes del financiamiento.', 1;

        IF NOT EXISTS (
        SELECT 1 FROM Vendedor WHERE IdVendedor = @Vendedor
        )
        THROW 50005, 'El vendedor no existe.', 1;

        IF EXISTS (
        SELECT 1 FROM Credito
        WHERE NumeroObligacion = @Numero
        )
        THROW 50006, 'El numero de obligacion ya existe.', 1;

        SELECT @Estado = IdEstadoCredito
        FROM EstadoCredito
        WHERE NombreEstado = 'Activo';

        IF @Estado IS NULL
        THROW 50007, 'Falta el estado Activo.', 1;

        SET @Monto = @Valor - @Enganche;

        DECLARE @SaldoCalculo DECIMAL(12,2) = @Monto;
        DECLARE @CapitalCalculo DECIMAL(12,2);
        SET @Intereses = 0;
        WHILE @i <= @Plazo
        BEGIN
            IF @i = @Plazo
            SET @CapitalCalculo = @SaldoCalculo;
        ELSE
            SET @CapitalCalculo = ROUND(@Monto / @Plazo, 2);
            SET @Intereses = @Intereses + ROUND(@SaldoCalculo * @Tasa / 1200.0, 2);
            SET @SaldoCalculo = @SaldoCalculo - @CapitalCalculo;
            SET @i = @i + 1;
        END;
        SET @i = 1;

        SET @Total = @Monto + @Intereses
        + @Plazo * (175 + 65 + 25);

        INSERT INTO Credito (
        NumeroObligacion, IdCliente, IdVendedor,
        VIN, IdEstadoCredito, FechaAprobacion,
        PlazoMeses, Enganche, MontoFinanciado,
        TasaInteresAnual, PorcentajeComision,
        SeguroVehiculoMensual, SeguroVidaMensual,
        ManejoCuentaMensual, TotalIntereses,
        TotalRecaudable
        )
        VALUES (
        @Numero, @Cliente, @Vendedor,
        @VIN, @Estado, @Fecha,
        @Plazo, @Enganche, @Monto,
        @Tasa, 2, 175, 65, 25,
        @Intereses, @Total
        );

        SET @IdCredito = SCOPE_IDENTITY();

        WHILE @i <= @Plazo
        BEGIN
            IF @i = @Plazo
            BEGIN
                SET @Capital = @Monto - @CapitalPrevio;
                SET @Interes = ROUND((@Monto - @CapitalPrevio) * @Tasa / 1200.0, 2);
            END
        ELSE
            BEGIN
                SET @Capital = ROUND(@Monto / @Plazo, 2);
                SET @Interes = ROUND((@Monto - @CapitalPrevio) * @Tasa / 1200.0, 2);
            END;

            INSERT INTO Cuota (
            IdCredito, NumeroCuota, FechaVencimiento,
            Capital, Interes, ManejoCuenta,
            SeguroVehiculo, SeguroVida, TotalCuota
            )
            VALUES (
            @IdCredito, @i,
            DATEADD(MONTH, @i, CAST(@Fecha AS DATE)),
            @Capital, @Interes, 25, 175, 65,
            @Capital + @Interes + 25 + 175 + 65
            );

            SET @CapitalPrevio = @CapitalPrevio + @Capital;
            SET @InteresPrevio = @InteresPrevio + @Interes;
            SET @i = @i + 1;
        END;

        COMMIT TRANSACTION;

        SELECT
        @IdCredito AS IdCredito,
        @Numero AS NumeroObligacion;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;

GO
