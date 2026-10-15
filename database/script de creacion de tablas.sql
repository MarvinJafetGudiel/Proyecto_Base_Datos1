USE MAGIS_AUTO;
GO

CREATE TABLE Persona (
    IdPersona INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Persona PRIMARY KEY,
    DPI VARCHAR(13) NOT NULL CONSTRAINT UQ_Persona_DPI UNIQUE,
    NIT VARCHAR(20) NULL CONSTRAINT UQ_Persona_NIT UNIQUE,
    NombreCompleto VARCHAR(150) NOT NULL,
    CorreoElectronico VARCHAR(100) NULL,
    FechaNacimiento DATE NULL
);
GO

CREATE TABLE TipoTelefono (
    IdTipoTelefono INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TipoTelefono PRIMARY KEY,
    Descripcion VARCHAR(30) NOT NULL CONSTRAINT UQ_TipoTelefono_Descripcion UNIQUE
);
GO

CREATE TABLE TelefonoPersona (
    IdTelefono INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TelefonoPersona PRIMARY KEY,
    IdPersona INT NOT NULL,
    IdTipoTelefono INT NOT NULL,
    NumeroTelefono VARCHAR(15) NOT NULL,
    CONSTRAINT FK_TelefonoPersona_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona),
    CONSTRAINT FK_TelefonoPersona_Tipo FOREIGN KEY (IdTipoTelefono) REFERENCES TipoTelefono(IdTipoTelefono),
    CONSTRAINT UQ_TelefonoPersona UNIQUE (IdPersona, NumeroTelefono)
);
GO

CREATE TABLE DireccionPersona (
    IdDireccion INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DireccionPersona PRIMARY KEY,
    IdPersona INT NOT NULL,
    DireccionCompleta VARCHAR(250) NOT NULL,
    CONSTRAINT FK_DireccionPersona_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona)
);
GO

CREATE TABLE Cliente (
    IdCliente INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cliente PRIMARY KEY,
    IdPersona INT NOT NULL CONSTRAINT UQ_Cliente_IdPersona UNIQUE,
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona)
);
GO

CREATE TABLE ReferenciaPersonal (
    IdReferencia INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ReferenciaPersonal PRIMARY KEY,
    IdCliente INT NOT NULL,
    IdPersona INT NOT NULL,
    Parentesco VARCHAR(50) NOT NULL,
    LugarTrabajo VARCHAR(150) NULL,
    CONSTRAINT FK_ReferenciaPersonal_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    CONSTRAINT FK_ReferenciaPersonal_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona),
    CONSTRAINT UQ_ReferenciaPersonal_ClientePersona UNIQUE (IdCliente, IdPersona)
);
GO

-- 2. Vehiculos y agencias
CREATE TABLE Marca (
    IdMarca INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Marca PRIMARY KEY,
    NombreMarca VARCHAR(80) NOT NULL CONSTRAINT UQ_Marca_Nombre UNIQUE
);
GO

CREATE TABLE Vehiculo (
    VIN VARCHAR(17) NOT NULL CONSTRAINT PK_Vehiculo PRIMARY KEY,
    IdMarca INT NOT NULL,
    Modelo VARCHAR(100) NOT NULL,
    AnioFabricacion SMALLINT NOT NULL,
    ValorAgencia DECIMAL(12,2) NOT NULL,
    Placa VARCHAR(15) NULL CONSTRAINT UQ_Vehiculo_Placa UNIQUE,
    CONSTRAINT FK_Vehiculo_Marca FOREIGN KEY (IdMarca) REFERENCES Marca(IdMarca),
    CONSTRAINT CK_Vehiculo_Anio CHECK (AnioFabricacion BETWEEN 1900 AND 2100),
    CONSTRAINT CK_Vehiculo_Valor CHECK (ValorAgencia > 0)
);
GO

CREATE TABLE Agencia (
    IdAgencia INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Agencia PRIMARY KEY,
    NombreAgencia VARCHAR(100) NOT NULL,
    Region VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Vendedor (
    IdVendedor INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Vendedor PRIMARY KEY,
    IdPersona INT NOT NULL CONSTRAINT UQ_Vendedor_IdPersona UNIQUE,
    IdAgencia INT NOT NULL,
    CONSTRAINT FK_Vendedor_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona),
    CONSTRAINT FK_Vendedor_Agencia FOREIGN KEY (IdAgencia) REFERENCES Agencia(IdAgencia)
);
GO

CREATE TABLE Fiador (
    IdFiador INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Fiador PRIMARY KEY,
    IdPersona INT NOT NULL CONSTRAINT UQ_Fiador_IdPersona UNIQUE,
    CONSTRAINT FK_Fiador_Persona FOREIGN KEY (IdPersona) REFERENCES Persona(IdPersona)
);
GO

CREATE TABLE EstadoCredito (
    IdEstadoCredito INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_EstadoCredito PRIMARY KEY,
    NombreEstado VARCHAR(30) NOT NULL CONSTRAINT UQ_EstadoCredito_Nombre UNIQUE
);
GO

CREATE TABLE Credito (
    IdCredito INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Credito PRIMARY KEY,
    NumeroObligacion VARCHAR(30) NOT NULL CONSTRAINT UQ_Credito_NumeroObligacion UNIQUE,
    IdCliente INT NOT NULL,
    IdVendedor INT NOT NULL,
    VIN VARCHAR(17) NOT NULL,
    IdEstadoCredito INT NOT NULL,
    FechaAprobacion DATETIME2 NOT NULL,
    PlazoMeses INT NOT NULL,
    Enganche DECIMAL(12,2) NOT NULL,
    MontoFinanciado DECIMAL(12,2) NOT NULL,
    TasaInteresAnual DECIMAL(6,3) NOT NULL,
    PorcentajeComision DECIMAL(6,3) NOT NULL,
    SeguroVehiculoMensual DECIMAL(10,2) NOT NULL,
    SeguroVidaMensual DECIMAL(10,2) NOT NULL,
    ManejoCuentaMensual DECIMAL(10,2) NOT NULL CONSTRAINT DF_Credito_Manejo DEFAULT (25.00),
    TotalIntereses DECIMAL(14,2) NOT NULL,
    TotalRecaudable DECIMAL(14,2) NOT NULL,
    CONSTRAINT FK_Credito_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    CONSTRAINT FK_Credito_Vendedor FOREIGN KEY (IdVendedor) REFERENCES Vendedor(IdVendedor),
    CONSTRAINT FK_Credito_Vehiculo FOREIGN KEY (VIN) REFERENCES Vehiculo(VIN),
    CONSTRAINT FK_Credito_Estado FOREIGN KEY (IdEstadoCredito) REFERENCES EstadoCredito(IdEstadoCredito),
    CONSTRAINT CK_Credito_Plazo CHECK (PlazoMeses > 0),
    CONSTRAINT CK_Credito_Enganche CHECK (Enganche >= 0),
    CONSTRAINT CK_Credito_Monto CHECK (MontoFinanciado > 0),
    CONSTRAINT CK_Credito_Tasa CHECK (TasaInteresAnual BETWEEN 0 AND 100),
    CONSTRAINT CK_Credito_Comision CHECK (PorcentajeComision BETWEEN 0 AND 100),
    CONSTRAINT CK_Credito_Seguros CHECK (SeguroVehiculoMensual >= 0 AND SeguroVidaMensual >= 0 AND ManejoCuentaMensual >= 0),
    CONSTRAINT CK_Credito_Totales CHECK (TotalIntereses >= 0 AND TotalRecaudable >= 0)
);
GO

CREATE TABLE CreditoFiador (
    IdCredito INT NOT NULL,
    IdFiador INT NOT NULL,
    CONSTRAINT PK_CreditoFiador PRIMARY KEY (IdCredito, IdFiador),
    CONSTRAINT FK_CreditoFiador_Credito FOREIGN KEY (IdCredito) REFERENCES Credito(IdCredito),
    CONSTRAINT FK_CreditoFiador_Fiador FOREIGN KEY (IdFiador) REFERENCES Fiador(IdFiador)
);
GO


CREATE TABLE Cuota (
    IdCuota INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cuota PRIMARY KEY,
    IdCredito INT NOT NULL,
    NumeroCuota INT NOT NULL,
    FechaVencimiento DATE NOT NULL,
    Capital DECIMAL(12,2) NOT NULL,
    Interes DECIMAL(12,2) NOT NULL,
    ManejoCuenta DECIMAL(10,2) NOT NULL,
    SeguroVehiculo DECIMAL(10,2) NOT NULL,
    SeguroVida DECIMAL(10,2) NOT NULL,
    TotalCuota DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Cuota_Credito FOREIGN KEY (IdCredito) REFERENCES Credito(IdCredito),
    CONSTRAINT UQ_Cuota_Numero UNIQUE (IdCredito, NumeroCuota),
    CONSTRAINT CK_Cuota_Numero CHECK (NumeroCuota > 0),
    CONSTRAINT CK_Cuota_Importes CHECK (Capital >= 0 AND Interes >= 0 AND ManejoCuenta >= 0 AND SeguroVehiculo >= 0 AND SeguroVida >= 0 AND TotalCuota >= 0)
);
GO

CREATE TABLE MedioPago (
    IdMedioPago INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_MedioPago PRIMARY KEY,
    NombreMedio VARCHAR(60) NOT NULL CONSTRAINT UQ_MedioPago_Nombre UNIQUE
);
GO

CREATE TABLE Pago (
    IdPago INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Pago PRIMARY KEY,
    IdCuota INT NOT NULL,
    IdMedioPago INT NOT NULL,
    NumeroRecibo VARCHAR(30) NOT NULL CONSTRAINT UQ_Pago_NumeroRecibo UNIQUE,
    FechaPago DATETIME2 NOT NULL,
    MontoPagado DECIMAL(12,2) NOT NULL,
    ReferenciaBancaria VARCHAR(100) NULL,
    CONSTRAINT FK_Pago_Cuota FOREIGN KEY (IdCuota) REFERENCES Cuota(IdCuota),
    CONSTRAINT FK_Pago_Medio FOREIGN KEY (IdMedioPago) REFERENCES MedioPago(IdMedioPago),
    CONSTRAINT CK_Pago_Monto CHECK (MontoPagado > 0)
);
GO
