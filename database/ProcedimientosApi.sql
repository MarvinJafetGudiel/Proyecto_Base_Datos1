USE MAGIS_AUTO;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Resumen
AS
BEGIN
    SET NOCOUNT ON;
SELECT
            (SELECT COUNT(*) FROM Persona) AS personas,
            (SELECT COUNT(*) FROM Cliente) AS clientes,
            (SELECT COUNT(*) FROM Vehiculo) AS vehiculos,
            (SELECT COUNT(*) FROM Credito) AS creditos,
            (SELECT COUNT(*) FROM Cuota) AS cuotas,
            (SELECT COUNT(*) FROM Pago) AS pagos;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Clientes_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT
            C.IdCliente,
            P.NombreCompleto,
            P.DPI,
            P.NIT,
            P.CorreoElectronico,
            P.FechaNacimiento
        FROM Cliente C
        INNER JOIN Persona P
            ON C.IdPersona = P.IdPersona
        ORDER BY C.IdCliente DESC;
END;
GO

-- 03. API: Clientes_Crear
CREATE OR ALTER PROCEDURE dbo.usp_API_Clientes_Crear
    @p1 VARCHAR(13),
    @p2 VARCHAR(20),
    @p3 VARCHAR(150),
    @p4 VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;
        SET XACT_ABORT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Persona
                (DPI, NIT, NombreCompleto, CorreoElectronico)
            VALUES (@p1, @p2, @p3, @p4);

            DECLARE @IdPersona INT;
            SET @IdPersona = SCOPE_IDENTITY();

            INSERT INTO Cliente (IdPersona)
            VALUES (@IdPersona);

            COMMIT TRANSACTION;

            SELECT IdCliente
            FROM Cliente
            WHERE IdPersona = @IdPersona;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Clientes_Actualizar
    @p1 VARCHAR(150),
    @p2 VARCHAR(13),
    @p3 VARCHAR(20),
    @p4 VARCHAR(100),
    @p5 INT
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;

        UPDATE P
        SET P.NombreCompleto = @p1,
            P.DPI = @p2,
            P.NIT = @p3,
            P.CorreoElectronico = @p4
        FROM Persona P
        INNER JOIN Cliente C
            ON P.IdPersona = C.IdPersona
        WHERE C.IdCliente = @p5;

        SELECT @@ROWCOUNT AS Actualizados;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Clientes_Eliminar
    @p1 INT,
    @p2 INT
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;
        SET XACT_ABORT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @IdPersona INT;
            DECLARE @Eliminados INT = 0;

            SELECT @IdPersona = IdPersona
            FROM Cliente
            WHERE IdCliente = @p1;

            IF @IdPersona IS NOT NULL
            BEGIN
                DELETE FROM Cliente
                WHERE IdCliente = @p2;

                SET @Eliminados = @@ROWCOUNT;

                IF NOT EXISTS (
                    SELECT 1 FROM Cliente WHERE IdPersona = @IdPersona
                )
                AND NOT EXISTS (
                    SELECT 1 FROM DireccionPersona WHERE IdPersona = @IdPersona
                )
                AND NOT EXISTS (
                    SELECT 1 FROM Fiador WHERE IdPersona = @IdPersona
                )
                AND NOT EXISTS (
                    SELECT 1 FROM ReferenciaPersonal WHERE IdPersona = @IdPersona
                )
                AND NOT EXISTS (
                    SELECT 1 FROM TelefonoPersona WHERE IdPersona = @IdPersona
                )
                AND NOT EXISTS (
                    SELECT 1 FROM Vendedor WHERE IdPersona = @IdPersona
                )
                BEGIN
                    DELETE FROM Persona
                    WHERE IdPersona = @IdPersona;
                END
            END

            COMMIT TRANSACTION;

            SELECT @Eliminados AS Eliminados;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Marcas_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT IdMarca, NombreMarca
        FROM Marca
        ORDER BY NombreMarca;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT
            V.VIN,
            V.IdMarca,
            M.NombreMarca,
            V.Modelo,
            V.AnioFabricacion,
            V.ValorAgencia,
            V.Placa
        FROM Vehiculo V
        INNER JOIN Marca M
            ON V.IdMarca = M.IdMarca
        ORDER BY V.Modelo, V.VIN;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Crear
    @p1 VARCHAR(17),
    @p2 INT,
    @p3 VARCHAR(100),
    @p4 SMALLINT,
    @p5 DECIMAL(12,2),
    @p6 VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;

        INSERT INTO Vehiculo
            (VIN, IdMarca, Modelo, AnioFabricacion,
             ValorAgencia, Placa)
        OUTPUT INSERTED.VIN
        VALUES (@p1, @p2, @p3, @p4, @p5, @p6);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Actualizar
    @p1 INT,
    @p2 VARCHAR(100),
    @p3 SMALLINT,
    @p4 DECIMAL(12,2),
    @p5 VARCHAR(15),
    @p6 VARCHAR(17)
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;

        UPDATE Vehiculo
        SET
            IdMarca = @p1,
            Modelo = @p2,
            AnioFabricacion = @p3,
            ValorAgencia = @p4,
            Placa = @p5
        OUTPUT INSERTED.VIN
        WHERE VIN = @p6;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vehiculos_Eliminar
    @p1 VARCHAR(17)
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;

        DELETE FROM Vehiculo
        OUTPUT DELETED.VIN
        WHERE VIN = @p1;
END;
GO


CREATE OR ALTER PROCEDURE dbo.usp_API_Creditos_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT
            C.IdCredito,
            C.NumeroObligacion,
            P.NombreCompleto AS Cliente,
            M.NombreMarca,
            V.Modelo,
            C.VIN,
            E.NombreEstado,
            C.FechaAprobacion,
            C.PlazoMeses,
            C.Enganche,
            C.MontoFinanciado,
            C.TasaInteresAnual,
            C.TotalIntereses,
            C.TotalRecaudable
        FROM Credito C
        INNER JOIN Cliente CL
            ON C.IdCliente = CL.IdCliente
        INNER JOIN Persona P
            ON CL.IdPersona = P.IdPersona
        INNER JOIN Vehiculo V
            ON C.VIN = V.VIN
        INNER JOIN Marca M
            ON V.IdMarca = M.IdMarca
        INNER JOIN EstadoCredito E
            ON C.IdEstadoCredito = E.IdEstadoCredito
        ORDER BY C.IdCredito DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Vendedores_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT V.IdVendedor, P.NombreCompleto
        FROM Vendedor V
        INNER JOIN Persona P ON V.IdPersona = P.IdPersona
        ORDER BY P.NombreCompleto;
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

            -- Sumar los intereses de cada mes sobre el saldo de capital pendiente.
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

CREATE OR ALTER PROCEDURE dbo.usp_API_Cuotas_Listar
    @p1 INT
AS
BEGIN
    SET NOCOUNT ON;
SELECT
            C.IdCuota,
            C.IdCredito,
            C.NumeroCuota,
            C.FechaVencimiento,
            C.Capital,
            C.Interes,
            C.ManejoCuenta,
            C.SeguroVehiculo,
            C.SeguroVida,
            C.TotalCuota,
            ISNULL(P.TotalPagado, 0) AS TotalPagado
        FROM Cuota C
        LEFT JOIN (
            SELECT
                IdCuota,
                SUM(MontoPagado) AS TotalPagado
            FROM Pago
            GROUP BY IdCuota
        ) P ON C.IdCuota = P.IdCuota
        WHERE C.IdCredito = @p1
        ORDER BY C.NumeroCuota;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_MediosPago_Listar
AS
BEGIN
    SET NOCOUNT ON;
SELECT IdMedioPago, NombreMedio
        FROM MedioPago
        ORDER BY NombreMedio;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_API_Pagos_Crear
    @p1 INT,
    @p2 INT,
    @p3 VARCHAR(30),
    @p4 DECIMAL(12,2),
    @p5 VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
SET NOCOUNT ON;
        SET XACT_ABORT ON;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @IdCuota INT = @p1;
            DECLARE @IdMedio INT = @p2;
            DECLARE @Recibo VARCHAR(30) = @p3;
            DECLARE @Monto DECIMAL(12,2) = @p4;
            DECLARE @Referencia VARCHAR(100) = @p5;

            DECLARE @TotalCuota DECIMAL(12,2);
            DECLARE @Pagado DECIMAL(14,2);
            DECLARE @IdPago INT;

            -- Bloquear la cuota mientras se registra el pago
            SELECT @TotalCuota = TotalCuota
            FROM Cuota WITH (UPDLOCK, HOLDLOCK)
            WHERE IdCuota = @IdCuota;

            IF @TotalCuota IS NULL
                THROW 50001, 'La cuota no existe.', 1;

            IF NOT EXISTS (
                SELECT 1 FROM MedioPago
                WHERE IdMedioPago = @IdMedio
            )
                THROW 50002, 'El medio de pago no existe.', 1;

            IF EXISTS (
                SELECT 1 FROM Pago
                WHERE NumeroRecibo = @Recibo
            )
                THROW 50003, 'El numero de recibo ya existe.', 1;

            SELECT @Pagado = ISNULL(SUM(MontoPagado), 0)
            FROM Pago WITH (UPDLOCK, HOLDLOCK)
            WHERE IdCuota = @IdCuota;

            IF @Monto > (@TotalCuota - @Pagado)
                THROW 50004, 'El monto supera el saldo de la cuota.', 1;

            INSERT INTO Pago (
                IdCuota,
                IdMedioPago,
                NumeroRecibo,
                FechaPago,
                MontoPagado,
                ReferenciaBancaria
            )
            VALUES (
                @IdCuota,
                @IdMedio,
                @Recibo,
                SYSDATETIME(),
                @Monto,
                NULLIF(@Referencia, '')
            );

            SET @IdPago = SCOPE_IDENTITY();

            COMMIT TRANSACTION;

            SELECT @IdPago AS IdPago;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            THROW;
        END CATCH;
END;
GO
