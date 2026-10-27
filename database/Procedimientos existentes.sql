USE MAGIS_AUTO;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Persona_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Persona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Persona_Buscar
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Persona WHERE IdPersona = @IdPersona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Persona_Insertar
    @DPI VARCHAR(13),
    @NIT VARCHAR(20),
    @NombreCompleto VARCHAR(150),
    @CorreoElectronico VARCHAR(100),
    @FechaNacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Persona (DPI, NIT, NombreCompleto, CorreoElectronico, FechaNacimiento)
    VALUES (@DPI, @NIT, @NombreCompleto, @CorreoElectronico, @FechaNacimiento);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Persona_Actualizar
    @IdPersona INT,
    @DPI VARCHAR(13),
    @NIT VARCHAR(20),
    @NombreCompleto VARCHAR(150),
    @CorreoElectronico VARCHAR(100),
    @FechaNacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Persona
    SET DPI = @DPI,
    NIT = @NIT,
    NombreCompleto = @NombreCompleto,
    CorreoElectronico = @CorreoElectronico,
    FechaNacimiento = @FechaNacimiento
    WHERE IdPersona = @IdPersona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Persona_Eliminar
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Persona WHERE IdPersona = @IdPersona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TipoTelefono_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.TipoTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TipoTelefono_Buscar
    @IdTipoTelefono INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.TipoTelefono WHERE IdTipoTelefono = @IdTipoTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TipoTelefono_Insertar
    @Descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.TipoTelefono (Descripcion)
    VALUES (@Descripcion);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TipoTelefono_Actualizar
    @IdTipoTelefono INT,
    @Descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TipoTelefono
    SET Descripcion = @Descripcion
    WHERE IdTipoTelefono = @IdTipoTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TipoTelefono_Eliminar
    @IdTipoTelefono INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.TipoTelefono WHERE IdTipoTelefono = @IdTipoTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TelefonoPersona_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.TelefonoPersona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TelefonoPersona_Buscar
    @IdTelefono INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.TelefonoPersona WHERE IdTelefono = @IdTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TelefonoPersona_Insertar
    @IdPersona INT,
    @IdTipoTelefono INT,
    @NumeroTelefono VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.TelefonoPersona (IdPersona, IdTipoTelefono, NumeroTelefono)
    VALUES (@IdPersona, @IdTipoTelefono, @NumeroTelefono);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TelefonoPersona_Actualizar
    @IdTelefono INT,
    @IdPersona INT,
    @IdTipoTelefono INT,
    @NumeroTelefono VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TelefonoPersona
    SET IdPersona = @IdPersona,
    IdTipoTelefono = @IdTipoTelefono,
    NumeroTelefono = @NumeroTelefono
    WHERE IdTelefono = @IdTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_TelefonoPersona_Eliminar
    @IdTelefono INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.TelefonoPersona WHERE IdTelefono = @IdTelefono;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_DireccionPersona_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.DireccionPersona;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_DireccionPersona_Buscar
    @IdDireccion INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.DireccionPersona WHERE IdDireccion = @IdDireccion;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_DireccionPersona_Insertar
    @IdPersona INT,
    @DireccionCompleta VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DireccionPersona (IdPersona, DireccionCompleta)
    VALUES (@IdPersona, @DireccionCompleta);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_DireccionPersona_Actualizar
    @IdDireccion INT,
    @IdPersona INT,
    @DireccionCompleta VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DireccionPersona
    SET IdPersona = @IdPersona,
    DireccionCompleta = @DireccionCompleta
    WHERE IdDireccion = @IdDireccion;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_DireccionPersona_Eliminar
    @IdDireccion INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.DireccionPersona WHERE IdDireccion = @IdDireccion;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Cliente;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Buscar
    @IdCliente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Cliente WHERE IdCliente = @IdCliente;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Insertar
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Cliente (IdPersona)
    VALUES (@IdPersona);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Actualizar
    @IdCliente INT,
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Cliente
    SET IdPersona = @IdPersona
    WHERE IdCliente = @IdCliente;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Eliminar
    @IdCliente INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Cliente WHERE IdCliente = @IdCliente;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_ReferenciaPersonal_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ReferenciaPersonal;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_ReferenciaPersonal_Buscar
    @IdReferencia INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.ReferenciaPersonal WHERE IdReferencia = @IdReferencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_ReferenciaPersonal_Insertar
    @IdCliente INT,
    @IdPersona INT,
    @Parentesco VARCHAR(50),
    @LugarTrabajo VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ReferenciaPersonal (IdCliente, IdPersona, Parentesco, LugarTrabajo)
    VALUES (@IdCliente, @IdPersona, @Parentesco, @LugarTrabajo);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_ReferenciaPersonal_Actualizar
    @IdReferencia INT,
    @IdCliente INT,
    @IdPersona INT,
    @Parentesco VARCHAR(50),
    @LugarTrabajo VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ReferenciaPersonal
    SET IdCliente = @IdCliente,
    IdPersona = @IdPersona,
    Parentesco = @Parentesco,
    LugarTrabajo = @LugarTrabajo
    WHERE IdReferencia = @IdReferencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_ReferenciaPersonal_Eliminar
    @IdReferencia INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ReferenciaPersonal WHERE IdReferencia = @IdReferencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Marca_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Marca;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Marca_Buscar
    @IdMarca INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Marca WHERE IdMarca = @IdMarca;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Marca_Insertar
    @NombreMarca VARCHAR(80)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Marca (NombreMarca)
    VALUES (@NombreMarca);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Marca_Actualizar
    @IdMarca INT,
    @NombreMarca VARCHAR(80)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Marca
    SET NombreMarca = @NombreMarca
    WHERE IdMarca = @IdMarca;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Marca_Eliminar
    @IdMarca INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Marca WHERE IdMarca = @IdMarca;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vehiculo_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Vehiculo;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vehiculo_Buscar
    @VIN VARCHAR(17)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Vehiculo WHERE VIN = @VIN;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vehiculo_Insertar
    @IdMarca INT,
    @Modelo VARCHAR(100),
    @AnioFabricacion SMALLINT,
    @ValorAgencia DECIMAL(12,2),
    @Placa VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Vehiculo (IdMarca, Modelo, AnioFabricacion, ValorAgencia, Placa)
    VALUES (@IdMarca, @Modelo, @AnioFabricacion, @ValorAgencia, @Placa);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vehiculo_Actualizar
    @VIN VARCHAR(17),
    @IdMarca INT,
    @Modelo VARCHAR(100),
    @AnioFabricacion SMALLINT,
    @ValorAgencia DECIMAL(12,2),
    @Placa VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Vehiculo
    SET IdMarca = @IdMarca,
    Modelo = @Modelo,
    AnioFabricacion = @AnioFabricacion,
    ValorAgencia = @ValorAgencia,
    Placa = @Placa
    WHERE VIN = @VIN;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vehiculo_Eliminar
    @VIN VARCHAR(17)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Vehiculo WHERE VIN = @VIN;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Agencia_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Agencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Agencia_Buscar
    @IdAgencia INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Agencia WHERE IdAgencia = @IdAgencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Agencia_Insertar
    @NombreAgencia VARCHAR(100),
    @Region VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Agencia (NombreAgencia, Region)
    VALUES (@NombreAgencia, @Region);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Agencia_Actualizar
    @IdAgencia INT,
    @NombreAgencia VARCHAR(100),
    @Region VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Agencia
    SET NombreAgencia = @NombreAgencia,
    Region = @Region
    WHERE IdAgencia = @IdAgencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Agencia_Eliminar
    @IdAgencia INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Agencia WHERE IdAgencia = @IdAgencia;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vendedor_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Vendedor;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vendedor_Buscar
    @IdVendedor INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Vendedor WHERE IdVendedor = @IdVendedor;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vendedor_Insertar
    @IdPersona INT,
    @IdAgencia INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Vendedor (IdPersona, IdAgencia)
    VALUES (@IdPersona, @IdAgencia);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vendedor_Actualizar
    @IdVendedor INT,
    @IdPersona INT,
    @IdAgencia INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Vendedor
    SET IdPersona = @IdPersona,
    IdAgencia = @IdAgencia
    WHERE IdVendedor = @IdVendedor;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Vendedor_Eliminar
    @IdVendedor INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Vendedor WHERE IdVendedor = @IdVendedor;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Fiador_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Fiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Fiador_Buscar
    @IdFiador INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Fiador WHERE IdFiador = @IdFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Fiador_Insertar
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Fiador (IdPersona)
    VALUES (@IdPersona);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Fiador_Actualizar
    @IdFiador INT,
    @IdPersona INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Fiador
    SET IdPersona = @IdPersona
    WHERE IdFiador = @IdFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Fiador_Eliminar
    @IdFiador INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Fiador WHERE IdFiador = @IdFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_EstadoCredito_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.EstadoCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_EstadoCredito_Buscar
    @IdEstadoCredito INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.EstadoCredito WHERE IdEstadoCredito = @IdEstadoCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_EstadoCredito_Insertar
    @NombreEstado VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.EstadoCredito (NombreEstado)
    VALUES (@NombreEstado);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_EstadoCredito_Actualizar
    @IdEstadoCredito INT,
    @NombreEstado VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.EstadoCredito
    SET NombreEstado = @NombreEstado
    WHERE IdEstadoCredito = @IdEstadoCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_EstadoCredito_Eliminar
    @IdEstadoCredito INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.EstadoCredito WHERE IdEstadoCredito = @IdEstadoCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Credito_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Credito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Credito_Buscar
    @IdCredito INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Credito WHERE IdCredito = @IdCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Credito_Insertar
    @NumeroObligacion VARCHAR(30),
    @IdCliente INT,
    @IdVendedor INT,
    @VIN VARCHAR(17),
    @IdEstadoCredito INT,
    @FechaAprobacion DATETIME2,
    @PlazoMeses INT,
    @Enganche DECIMAL(12,2),
    @MontoFinanciado DECIMAL(12,2),
    @TasaInteresAnual DECIMAL(6,3),
    @PorcentajeComision DECIMAL(6,3),
    @SeguroVehiculoMensual DECIMAL(10,2),
    @SeguroVidaMensual DECIMAL(10,2),
    @ManejoCuentaMensual DECIMAL(10,2),
    @TotalIntereses DECIMAL(14,2),
    @TotalRecaudable DECIMAL(14,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Credito (NumeroObligacion, IdCliente, IdVendedor, VIN, IdEstadoCredito, FechaAprobacion, PlazoMeses, Enganche, MontoFinanciado, TasaInteresAnual, PorcentajeComision, SeguroVehiculoMensual, SeguroVidaMensual, ManejoCuentaMensual, TotalIntereses, TotalRecaudable)
    VALUES (@NumeroObligacion, @IdCliente, @IdVendedor, @VIN, @IdEstadoCredito, @FechaAprobacion, @PlazoMeses, @Enganche, @MontoFinanciado, @TasaInteresAnual, @PorcentajeComision, @SeguroVehiculoMensual, @SeguroVidaMensual, @ManejoCuentaMensual, @TotalIntereses, @TotalRecaudable);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Credito_Actualizar
    @IdCredito INT,
    @NumeroObligacion VARCHAR(30),
    @IdCliente INT,
    @IdVendedor INT,
    @VIN VARCHAR(17),
    @IdEstadoCredito INT,
    @FechaAprobacion DATETIME2,
    @PlazoMeses INT,
    @Enganche DECIMAL(12,2),
    @MontoFinanciado DECIMAL(12,2),
    @TasaInteresAnual DECIMAL(6,3),
    @PorcentajeComision DECIMAL(6,3),
    @SeguroVehiculoMensual DECIMAL(10,2),
    @SeguroVidaMensual DECIMAL(10,2),
    @ManejoCuentaMensual DECIMAL(10,2),
    @TotalIntereses DECIMAL(14,2),
    @TotalRecaudable DECIMAL(14,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Credito
    SET NumeroObligacion = @NumeroObligacion,
    IdCliente = @IdCliente,
    IdVendedor = @IdVendedor,
    VIN = @VIN,
    IdEstadoCredito = @IdEstadoCredito,
    FechaAprobacion = @FechaAprobacion,
    PlazoMeses = @PlazoMeses,
    Enganche = @Enganche,
    MontoFinanciado = @MontoFinanciado,
    TasaInteresAnual = @TasaInteresAnual,
    PorcentajeComision = @PorcentajeComision,
    SeguroVehiculoMensual = @SeguroVehiculoMensual,
    SeguroVidaMensual = @SeguroVidaMensual,
    ManejoCuentaMensual = @ManejoCuentaMensual,
    TotalIntereses = @TotalIntereses,
    TotalRecaudable = @TotalRecaudable
    WHERE IdCredito = @IdCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Credito_Eliminar
    @IdCredito INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Credito WHERE IdCredito = @IdCredito;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_CreditoFiador_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.CreditoFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_CreditoFiador_Buscar
    @IdCredito INT,
    @IdFiador INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.CreditoFiador WHERE IdCredito = @IdCredito AND IdFiador = @IdFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_CreditoFiador_Insertar
    @IdCredito INT,
    @IdFiador INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.CreditoFiador (IdCredito, IdFiador)
    VALUES (@IdCredito, @IdFiador);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_CreditoFiador_Eliminar
    @IdCredito INT,
    @IdFiador INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.CreditoFiador WHERE IdCredito = @IdCredito AND IdFiador = @IdFiador;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cuota_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Cuota;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cuota_Buscar
    @IdCuota INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Cuota WHERE IdCuota = @IdCuota;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cuota_Insertar
    @IdCredito INT,
    @NumeroCuota INT,
    @FechaVencimiento DATE,
    @Capital DECIMAL(12,2),
    @Interes DECIMAL(12,2),
    @ManejoCuenta DECIMAL(10,2),
    @SeguroVehiculo DECIMAL(10,2),
    @SeguroVida DECIMAL(10,2),
    @TotalCuota DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Cuota (IdCredito, NumeroCuota, FechaVencimiento, Capital, Interes, ManejoCuenta, SeguroVehiculo, SeguroVida, TotalCuota)
    VALUES (@IdCredito, @NumeroCuota, @FechaVencimiento, @Capital, @Interes, @ManejoCuenta, @SeguroVehiculo, @SeguroVida, @TotalCuota);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cuota_Actualizar
    @IdCuota INT,
    @IdCredito INT,
    @NumeroCuota INT,
    @FechaVencimiento DATE,
    @Capital DECIMAL(12,2),
    @Interes DECIMAL(12,2),
    @ManejoCuenta DECIMAL(10,2),
    @SeguroVehiculo DECIMAL(10,2),
    @SeguroVida DECIMAL(10,2),
    @TotalCuota DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Cuota
    SET IdCredito = @IdCredito,
    NumeroCuota = @NumeroCuota,
    FechaVencimiento = @FechaVencimiento,
    Capital = @Capital,
    Interes = @Interes,
    ManejoCuenta = @ManejoCuenta,
    SeguroVehiculo = @SeguroVehiculo,
    SeguroVida = @SeguroVida,
    TotalCuota = @TotalCuota
    WHERE IdCuota = @IdCuota;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Cuota_Eliminar
    @IdCuota INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Cuota WHERE IdCuota = @IdCuota;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_MedioPago_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.MedioPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_MedioPago_Buscar
    @IdMedioPago INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.MedioPago WHERE IdMedioPago = @IdMedioPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_MedioPago_Insertar
    @NombreMedio VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.MedioPago (NombreMedio)
    VALUES (@NombreMedio);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_MedioPago_Actualizar
    @IdMedioPago INT,
    @NombreMedio VARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.MedioPago
    SET NombreMedio = @NombreMedio
    WHERE IdMedioPago = @IdMedioPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_MedioPago_Eliminar
    @IdMedioPago INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.MedioPago WHERE IdMedioPago = @IdMedioPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Pago_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Pago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Pago_Buscar
    @IdPago INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Pago WHERE IdPago = @IdPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Pago_Insertar
    @IdCuota INT,
    @IdMedioPago INT,
    @NumeroRecibo VARCHAR(30),
    @FechaPago DATETIME2,
    @MontoPagado DECIMAL(12,2),
    @ReferenciaBancaria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Pago (IdCuota, IdMedioPago, NumeroRecibo, FechaPago, MontoPagado, ReferenciaBancaria)
    VALUES (@IdCuota, @IdMedioPago, @NumeroRecibo, @FechaPago, @MontoPagado, @ReferenciaBancaria);
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Pago_Actualizar
    @IdPago INT,
    @IdCuota INT,
    @IdMedioPago INT,
    @NumeroRecibo VARCHAR(30),
    @FechaPago DATETIME2,
    @MontoPagado DECIMAL(12,2),
    @ReferenciaBancaria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pago
    SET IdCuota = @IdCuota,
    IdMedioPago = @IdMedioPago,
    NumeroRecibo = @NumeroRecibo,
    FechaPago = @FechaPago,
    MontoPagado = @MontoPagado,
    ReferenciaBancaria = @ReferenciaBancaria
    WHERE IdPago = @IdPago;
END;

GO

CREATE OR ALTER PROCEDURE dbo.usp_Pago_Eliminar
    @IdPago INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Pago WHERE IdPago = @IdPago;
END;

GO

SELECT name AS Procedimiento FROM sys.procedures WHERE name LIKE 'usp_%' ORDER BY name;

GO
