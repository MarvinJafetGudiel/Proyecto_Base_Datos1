USE MAGIS_AUTO;
GO

-- A. Referencias con datos de contacto 
CREATE OR ALTER PROCEDURE dbo.usp_API_Referencias_Listar @IdCliente INT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT R.IdReferencia, R.IdCliente, P.NombreCompleto, P.DPI, P.NIT,
        P.CorreoElectronico, R.Parentesco, R.LugarTrabajo,
        (SELECT STRING_AGG(T.NumeroTelefono, ', ') FROM dbo.TelefonoPersona T WHERE T.IdPersona=P.IdPersona) AS Telefonos,
        (SELECT STRING_AGG(D.DireccionCompleta, '; ') FROM dbo.DireccionPersona D WHERE D.IdPersona=P.IdPersona) AS Direcciones
 FROM dbo.ReferenciaPersonal R JOIN dbo.Persona P ON P.IdPersona=R.IdPersona
 WHERE R.IdCliente=@IdCliente ORDER BY R.IdReferencia;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_Referencias_Crear
 @IdCliente INT, @DPI VARCHAR(13), @Nombre VARCHAR(150), @Telefono VARCHAR(15),
 @Direccion VARCHAR(250), @Parentesco VARCHAR(50), @Trabajo VARCHAR(150)=NULL,
 @NIT VARCHAR(20)=NULL, @Correo VARCHAR(100)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
 BEGIN TRANSACTION;
 IF NOT EXISTS(SELECT 1 FROM dbo.Cliente WHERE IdCliente=@IdCliente)
  THROW 51001, 'Cliente no encontrado.', 1;
 IF NULLIF(LTRIM(RTRIM(@Telefono)),'') IS NULL OR NULLIF(LTRIM(RTRIM(@Direccion)),'') IS NULL
  THROW 51002, 'Telefono y direccion son obligatorios.', 1;
 DECLARE @IdPersona INT, @Tipo INT;
 SELECT @IdPersona=IdPersona FROM dbo.Persona WITH(UPDLOCK,HOLDLOCK) WHERE DPI=@DPI;
 IF @IdPersona IS NULL
 BEGIN
  INSERT INTO dbo.Persona(DPI,NIT,NombreCompleto,CorreoElectronico)
  VALUES(@DPI,NULLIF(@NIT,''),@Nombre,NULLIF(@Correo,''));
  SET @IdPersona=CONVERT(INT,SCOPE_IDENTITY());
 END;
 IF EXISTS(SELECT 1 FROM dbo.ReferenciaPersonal WHERE IdCliente=@IdCliente AND IdPersona=@IdPersona)
  THROW 51003, 'Esta persona ya es referencia de este cliente.', 1;
 SELECT TOP(1) @Tipo=IdTipoTelefono FROM dbo.TipoTelefono
 ORDER BY CASE WHEN Descripcion LIKE '%cel%' THEN 0 ELSE 1 END, IdTipoTelefono;
 IF @Tipo IS NULL THROW 51004, 'Registre un tipo de telefono primero.', 1;
 IF NOT EXISTS(SELECT 1 FROM dbo.TelefonoPersona WHERE IdPersona=@IdPersona AND NumeroTelefono=@Telefono)
  INSERT INTO dbo.TelefonoPersona(IdPersona,IdTipoTelefono,NumeroTelefono) VALUES(@IdPersona,@Tipo,@Telefono);
 IF NOT EXISTS(SELECT 1 FROM dbo.DireccionPersona WHERE IdPersona=@IdPersona AND DireccionCompleta=@Direccion)
  INSERT INTO dbo.DireccionPersona(IdPersona,DireccionCompleta) VALUES(@IdPersona,@Direccion);
 INSERT INTO dbo.ReferenciaPersonal(IdCliente,IdPersona,Parentesco,LugarTrabajo)
 VALUES(@IdCliente,@IdPersona,@Parentesco,NULLIF(@Trabajo,''));
 SELECT CONVERT(INT,SCOPE_IDENTITY()) AS IdReferencia;
 COMMIT TRANSACTION;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK; THROW; END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_Referencias_Eliminar @IdReferencia INT
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @Cliente INT;
 SELECT @Cliente=IdCliente FROM dbo.ReferenciaPersonal WITH(UPDLOCK,HOLDLOCK) WHERE IdReferencia=@IdReferencia;
 IF @Cliente IS NULL THROW 51005, 'Referencia no encontrada.', 1;
 IF EXISTS(SELECT 1 FROM dbo.Credito WHERE IdCliente=@Cliente)
 AND (SELECT COUNT(*) FROM dbo.ReferenciaPersonal WHERE IdCliente=@Cliente)<=3
  THROW 51006, 'No se pueden dejar menos de tres referencias en un cliente con creditos.', 1;
 DELETE FROM dbo.ReferenciaPersonal WHERE IdReferencia=@IdReferencia;
 SELECT @@ROWCOUNT AS Eliminados;
 COMMIT;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK; THROW; END CATCH;
END;
GO

-- B. Fiadores: alta con datos legales, contacto, direccion y asignacion N:M.
CREATE OR ALTER PROCEDURE dbo.usp_API_Fiadores_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT F.IdFiador, P.NombreCompleto, P.DPI, P.NIT, P.CorreoElectronico,
 (SELECT STRING_AGG(T.NumeroTelefono, ', ') FROM dbo.TelefonoPersona T WHERE T.IdPersona=P.IdPersona) AS Telefonos,
 (SELECT STRING_AGG(D.DireccionCompleta, '; ') FROM dbo.DireccionPersona D WHERE D.IdPersona=P.IdPersona) AS Direcciones
 FROM dbo.Fiador F JOIN dbo.Persona P ON P.IdPersona=F.IdPersona ORDER BY P.NombreCompleto;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_Fiadores_Crear
 @DPI VARCHAR(13), @Nombre VARCHAR(150), @Telefono VARCHAR(15),
 @Direccion VARCHAR(250), @NIT VARCHAR(20)=NULL, @Correo VARCHAR(100)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY BEGIN TRANSACTION;
 DECLARE @IdPersona INT,@Tipo INT;
 SELECT @IdPersona=IdPersona FROM dbo.Persona WITH(UPDLOCK,HOLDLOCK) WHERE DPI=@DPI;
 IF @IdPersona IS NULL
 BEGIN
  INSERT INTO dbo.Persona(DPI,NIT,NombreCompleto,CorreoElectronico)
  VALUES(@DPI,NULLIF(@NIT,''),@Nombre,NULLIF(@Correo,''));
  SET @IdPersona=CONVERT(INT,SCOPE_IDENTITY());
 END;
 IF EXISTS(SELECT 1 FROM dbo.Fiador WHERE IdPersona=@IdPersona)
  THROW 51007, 'Esta persona ya esta registrada como fiador.', 1;
 SELECT TOP(1) @Tipo=IdTipoTelefono FROM dbo.TipoTelefono ORDER BY CASE WHEN Descripcion LIKE '%cel%' THEN 0 ELSE 1 END,IdTipoTelefono;
 IF @Tipo IS NULL THROW 51008, 'Registre un tipo de telefono primero.', 1;
 IF NOT EXISTS(SELECT 1 FROM dbo.TelefonoPersona WHERE IdPersona=@IdPersona AND NumeroTelefono=@Telefono)
  INSERT INTO dbo.TelefonoPersona(IdPersona,IdTipoTelefono,NumeroTelefono) VALUES(@IdPersona,@Tipo,@Telefono);
 IF NOT EXISTS(SELECT 1 FROM dbo.DireccionPersona WHERE IdPersona=@IdPersona AND DireccionCompleta=@Direccion)
  INSERT INTO dbo.DireccionPersona(IdPersona,DireccionCompleta) VALUES(@IdPersona,@Direccion);
 INSERT INTO dbo.Fiador(IdPersona) VALUES(@IdPersona);
 SELECT CONVERT(INT,SCOPE_IDENTITY()) AS IdFiador;
 COMMIT;
 END TRY BEGIN CATCH IF @@TRANCOUNT>0 ROLLBACK; THROW; END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_CreditoFiadores_Listar @IdCredito INT
AS
BEGIN
 SET NOCOUNT ON;
 SELECT CF.IdCredito, CF.IdFiador, P.NombreCompleto, P.DPI
 FROM dbo.CreditoFiador CF JOIN dbo.Fiador F ON F.IdFiador=CF.IdFiador
 JOIN dbo.Persona P ON P.IdPersona=F.IdPersona
 WHERE CF.IdCredito=@IdCredito ORDER BY P.NombreCompleto;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_CreditoFiadores_Asignar @IdCredito INT,@IdFiador INT
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Credito WHERE IdCredito=@IdCredito) THROW 51009,'Credito inexistente.',1;
 IF NOT EXISTS(SELECT 1 FROM dbo.Fiador WHERE IdFiador=@IdFiador) THROW 51010,'Fiador inexistente.',1;
 IF EXISTS(SELECT 1 FROM dbo.CreditoFiador WHERE IdCredito=@IdCredito AND IdFiador=@IdFiador)
  THROW 51011,'Fiador ya asignado a este credito.',1;
 INSERT INTO dbo.CreditoFiador(IdCredito,IdFiador) VALUES(@IdCredito,@IdFiador);
 SELECT @IdCredito AS IdCredito,@IdFiador AS IdFiador;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_CreditoFiadores_Quitar @IdCredito INT,@IdFiador INT
AS
BEGIN
 SET NOCOUNT ON;
 DELETE FROM dbo.CreditoFiador WHERE IdCredito=@IdCredito AND IdFiador=@IdFiador;
 SELECT @@ROWCOUNT AS Eliminados;
END;
GO

-- C. Comisiones: calculadas UNICAMENTE sobre pagos cobrados (no anticipadas).
CREATE OR ALTER PROCEDURE dbo.usp_API_Comisiones_Listar
AS
BEGIN
 SET NOCOUNT ON;
 SELECT V.IdVendedor,P.NombreCompleto AS Vendedor,
 COUNT(DISTINCT C.IdCredito) AS Creditos,
 COUNT(PA.IdPago) AS PagosRecibidos,
 CAST(COALESCE(SUM(PA.MontoPagado),0) AS DECIMAL(18,2)) AS TotalCobrado,
 CAST(COALESCE(SUM(PA.MontoPagado*C.PorcentajeComision/100.0),0) AS DECIMAL(18,2)) AS ComisionDevengada
 FROM dbo.Vendedor V JOIN dbo.Persona P ON P.IdPersona=V.IdPersona
 LEFT JOIN dbo.Credito C ON C.IdVendedor=V.IdVendedor
 LEFT JOIN dbo.Cuota Q ON Q.IdCredito=C.IdCredito
 LEFT JOIN dbo.Pago PA ON PA.IdCuota=Q.IdCuota
 GROUP BY V.IdVendedor,P.NombreCompleto ORDER BY ComisionDevengada DESC;
END;
GO

-- D. Depreciacion: historial de valoraciones; no altera el valor de agencia original.
IF OBJECT_ID('dbo.HistorialDepreciacion','U') IS NULL
BEGIN
 CREATE TABLE dbo.HistorialDepreciacion(
  IdValoracion INT IDENTITY(1,1) PRIMARY KEY,
  VIN VARCHAR(17) NOT NULL REFERENCES dbo.Vehiculo(VIN),
  FechaValoracion DATE NOT NULL,
  ValorEstimado DECIMAL(12,2) NOT NULL CHECK(ValorEstimado>=0),
  Observacion VARCHAR(250) NULL,
  CONSTRAINT UQ_HistorialDepreciacion_VIN_Fecha UNIQUE(VIN,FechaValoracion)
 );
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_Depreciacion_Listar @VIN VARCHAR(17)=NULL
AS
BEGIN
 SET NOCOUNT ON;
 SELECT V.VIN,M.NombreMarca,V.Modelo,V.AnioFabricacion,V.ValorAgencia,
 CAST(ROUND(V.ValorAgencia*0.85,2) AS DECIMAL(12,2)) AS EstimadoDepreciacion15,
 CAST(ROUND(V.ValorAgencia*0.80,2) AS DECIMAL(12,2)) AS EstimadoDepreciacion20,
 H.FechaValoracion,H.ValorEstimado,H.Observacion,
 CASE WHEN H.ValorEstimado IS NOT NULL THEN CAST(ROUND((V.ValorAgencia-H.ValorEstimado)*100.0/NULLIF(V.ValorAgencia,0),2) AS DECIMAL(8,2)) END AS DepreciacionRealPorcentaje
 FROM dbo.Vehiculo V JOIN dbo.Marca M ON M.IdMarca=V.IdMarca
 LEFT JOIN dbo.HistorialDepreciacion H ON H.VIN=V.VIN
 WHERE @VIN IS NULL OR V.VIN=@VIN
 ORDER BY V.Modelo,V.VIN,H.FechaValoracion DESC;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_API_Depreciacion_Registrar
 @VIN VARCHAR(17),@Fecha DATE,@Valor DECIMAL(12,2),@Observacion VARCHAR(250)=NULL
AS
BEGIN
 SET NOCOUNT ON;
 IF NOT EXISTS(SELECT 1 FROM dbo.Vehiculo WHERE VIN=@VIN) THROW 51012,'Vehiculo inexistente.',1;
 IF @Valor<0 THROW 51013,'Valor invalido.',1;
 IF EXISTS(SELECT 1 FROM dbo.HistorialDepreciacion WHERE VIN=@VIN AND FechaValoracion=@Fecha)
  THROW 51014,'Ya existe valoracion para ese vehiculo y fecha.',1;
 INSERT INTO dbo.HistorialDepreciacion(VIN,FechaValoracion,ValorEstimado,Observacion)
 VALUES(@VIN,@Fecha,@Valor,NULLIF(@Observacion,''));
 SELECT CONVERT(INT,SCOPE_IDENTITY()) AS IdValoracion;
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


-- F. Verificacion de instalacion sin escrituras adicionales.
SELECT name FROM sys.procedures WHERE name LIKE 'usp_API_Referencias_%' OR name LIKE 'usp_API_Fiadores_%' OR name LIKE 'usp_API_CreditoFiadores_%' OR name LIKE 'usp_API_Comisiones_%' OR name LIKE 'usp_API_Depreciacion_%' ORDER BY name;
GO
