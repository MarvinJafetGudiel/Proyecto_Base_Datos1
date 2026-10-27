USE MAGIS_AUTO;

GO

SET NOCOUNT ON;

DECLARE @R TABLE (Prueba VARCHAR(100), Estado VARCHAR(12), Detalle NVARCHAR(4000));
DECLARE @id INT;

INSERT INTO @R SELECT 'usp_Persona_Listar', CASE WHEN OBJECT_ID('dbo.usp_Persona_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Persona_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Persona_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Persona_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Persona_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Persona_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Persona_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Persona_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Persona_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TipoTelefono_Listar', CASE WHEN OBJECT_ID('dbo.usp_TipoTelefono_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TipoTelefono_Buscar', CASE WHEN OBJECT_ID('dbo.usp_TipoTelefono_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TipoTelefono_Insertar', CASE WHEN OBJECT_ID('dbo.usp_TipoTelefono_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TipoTelefono_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_TipoTelefono_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TipoTelefono_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_TipoTelefono_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TelefonoPersona_Listar', CASE WHEN OBJECT_ID('dbo.usp_TelefonoPersona_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TelefonoPersona_Buscar', CASE WHEN OBJECT_ID('dbo.usp_TelefonoPersona_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TelefonoPersona_Insertar', CASE WHEN OBJECT_ID('dbo.usp_TelefonoPersona_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TelefonoPersona_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_TelefonoPersona_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_TelefonoPersona_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_TelefonoPersona_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_DireccionPersona_Listar', CASE WHEN OBJECT_ID('dbo.usp_DireccionPersona_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_DireccionPersona_Buscar', CASE WHEN OBJECT_ID('dbo.usp_DireccionPersona_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_DireccionPersona_Insertar', CASE WHEN OBJECT_ID('dbo.usp_DireccionPersona_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_DireccionPersona_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_DireccionPersona_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_DireccionPersona_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_DireccionPersona_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cliente_Listar', CASE WHEN OBJECT_ID('dbo.usp_Cliente_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cliente_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Cliente_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cliente_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Cliente_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cliente_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Cliente_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cliente_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Cliente_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_ReferenciaPersonal_Listar', CASE WHEN OBJECT_ID('dbo.usp_ReferenciaPersonal_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_ReferenciaPersonal_Buscar', CASE WHEN OBJECT_ID('dbo.usp_ReferenciaPersonal_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_ReferenciaPersonal_Insertar', CASE WHEN OBJECT_ID('dbo.usp_ReferenciaPersonal_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_ReferenciaPersonal_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_ReferenciaPersonal_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_ReferenciaPersonal_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_ReferenciaPersonal_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Marca_Listar', CASE WHEN OBJECT_ID('dbo.usp_Marca_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Marca_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Marca_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Marca_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Marca_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Marca_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Marca_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Marca_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Marca_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vehiculo_Listar', CASE WHEN OBJECT_ID('dbo.usp_Vehiculo_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vehiculo_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Vehiculo_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vehiculo_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Vehiculo_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vehiculo_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Vehiculo_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vehiculo_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Vehiculo_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Agencia_Listar', CASE WHEN OBJECT_ID('dbo.usp_Agencia_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Agencia_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Agencia_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Agencia_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Agencia_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Agencia_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Agencia_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Agencia_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Agencia_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vendedor_Listar', CASE WHEN OBJECT_ID('dbo.usp_Vendedor_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vendedor_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Vendedor_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vendedor_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Vendedor_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vendedor_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Vendedor_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Vendedor_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Vendedor_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Fiador_Listar', CASE WHEN OBJECT_ID('dbo.usp_Fiador_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Fiador_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Fiador_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Fiador_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Fiador_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Fiador_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Fiador_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Fiador_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Fiador_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_EstadoCredito_Listar', CASE WHEN OBJECT_ID('dbo.usp_EstadoCredito_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_EstadoCredito_Buscar', CASE WHEN OBJECT_ID('dbo.usp_EstadoCredito_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_EstadoCredito_Insertar', CASE WHEN OBJECT_ID('dbo.usp_EstadoCredito_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_EstadoCredito_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_EstadoCredito_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_EstadoCredito_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_EstadoCredito_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Credito_Listar', CASE WHEN OBJECT_ID('dbo.usp_Credito_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Credito_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Credito_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Credito_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Credito_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Credito_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Credito_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Credito_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Credito_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_CreditoFiador_Listar', CASE WHEN OBJECT_ID('dbo.usp_CreditoFiador_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_CreditoFiador_Buscar', CASE WHEN OBJECT_ID('dbo.usp_CreditoFiador_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_CreditoFiador_Insertar', CASE WHEN OBJECT_ID('dbo.usp_CreditoFiador_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_CreditoFiador_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_CreditoFiador_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cuota_Listar', CASE WHEN OBJECT_ID('dbo.usp_Cuota_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cuota_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Cuota_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cuota_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Cuota_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cuota_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Cuota_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Cuota_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Cuota_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_MedioPago_Listar', CASE WHEN OBJECT_ID('dbo.usp_MedioPago_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_MedioPago_Buscar', CASE WHEN OBJECT_ID('dbo.usp_MedioPago_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_MedioPago_Insertar', CASE WHEN OBJECT_ID('dbo.usp_MedioPago_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_MedioPago_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_MedioPago_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_MedioPago_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_MedioPago_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Pago_Listar', CASE WHEN OBJECT_ID('dbo.usp_Pago_Listar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Pago_Buscar', CASE WHEN OBJECT_ID('dbo.usp_Pago_Buscar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Pago_Insertar', CASE WHEN OBJECT_ID('dbo.usp_Pago_Insertar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Pago_Actualizar', CASE WHEN OBJECT_ID('dbo.usp_Pago_Actualizar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';
INSERT INTO @R SELECT 'usp_Pago_Eliminar', CASE WHEN OBJECT_ID('dbo.usp_Pago_Eliminar','P') IS NOT NULL THEN 'OK' ELSE 'ERROR' END, 'Existencia del procedimiento';

BEGIN TRY
    EXEC dbo.usp_Persona_Listar;
    INSERT INTO @R VALUES ('Listar Persona','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Persona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vPersona INT;
    SELECT TOP (1) @vPersona=IdPersona FROM dbo.Persona;
    IF @vPersona IS NOT NULL
    BEGIN
        EXEC dbo.usp_Persona_Buscar @IdPersona=@vPersona;
        INSERT INTO @R VALUES ('Buscar Persona','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Persona','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Persona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_TipoTelefono_Listar;
    INSERT INTO @R VALUES ('Listar TipoTelefono','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar TipoTelefono','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vTipoTelefono INT;
    SELECT TOP (1) @vTipoTelefono=IdTipoTelefono FROM dbo.TipoTelefono;
    IF @vTipoTelefono IS NOT NULL
    BEGIN
        EXEC dbo.usp_TipoTelefono_Buscar @IdTipoTelefono=@vTipoTelefono;
        INSERT INTO @R VALUES ('Buscar TipoTelefono','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar TipoTelefono','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar TipoTelefono','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_TelefonoPersona_Listar;
    INSERT INTO @R VALUES ('Listar TelefonoPersona','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar TelefonoPersona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vTelefonoPersona INT;
    SELECT TOP (1) @vTelefonoPersona=IdTelefono FROM dbo.TelefonoPersona;
    IF @vTelefonoPersona IS NOT NULL
    BEGIN
        EXEC dbo.usp_TelefonoPersona_Buscar @IdTelefono=@vTelefonoPersona;
        INSERT INTO @R VALUES ('Buscar TelefonoPersona','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar TelefonoPersona','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar TelefonoPersona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_DireccionPersona_Listar;
    INSERT INTO @R VALUES ('Listar DireccionPersona','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar DireccionPersona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vDireccionPersona INT;
    SELECT TOP (1) @vDireccionPersona=IdDireccion FROM dbo.DireccionPersona;
    IF @vDireccionPersona IS NOT NULL
    BEGIN
        EXEC dbo.usp_DireccionPersona_Buscar @IdDireccion=@vDireccionPersona;
        INSERT INTO @R VALUES ('Buscar DireccionPersona','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar DireccionPersona','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar DireccionPersona','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Cliente_Listar;
    INSERT INTO @R VALUES ('Listar Cliente','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Cliente','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vCliente INT;
    SELECT TOP (1) @vCliente=IdCliente FROM dbo.Cliente;
    IF @vCliente IS NOT NULL
    BEGIN
        EXEC dbo.usp_Cliente_Buscar @IdCliente=@vCliente;
        INSERT INTO @R VALUES ('Buscar Cliente','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Cliente','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Cliente','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_ReferenciaPersonal_Listar;
    INSERT INTO @R VALUES ('Listar ReferenciaPersonal','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar ReferenciaPersonal','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vReferenciaPersonal INT;
    SELECT TOP (1) @vReferenciaPersonal=IdReferencia FROM dbo.ReferenciaPersonal;
    IF @vReferenciaPersonal IS NOT NULL
    BEGIN
        EXEC dbo.usp_ReferenciaPersonal_Buscar @IdReferencia=@vReferenciaPersonal;
        INSERT INTO @R VALUES ('Buscar ReferenciaPersonal','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar ReferenciaPersonal','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar ReferenciaPersonal','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Marca_Listar;
    INSERT INTO @R VALUES ('Listar Marca','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Marca','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vMarca INT;
    SELECT TOP (1) @vMarca=IdMarca FROM dbo.Marca;
    IF @vMarca IS NOT NULL
    BEGIN
        EXEC dbo.usp_Marca_Buscar @IdMarca=@vMarca;
        INSERT INTO @R VALUES ('Buscar Marca','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Marca','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Marca','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Vehiculo_Listar;
    INSERT INTO @R VALUES ('Listar Vehiculo','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Vehiculo','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vVehiculo VARCHAR(17);
    SELECT TOP (1) @vVehiculo=VIN FROM dbo.Vehiculo;
    IF @vVehiculo IS NOT NULL
    BEGIN
        EXEC dbo.usp_Vehiculo_Buscar @VIN=@vVehiculo;
        INSERT INTO @R VALUES ('Buscar Vehiculo','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Vehiculo','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Vehiculo','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Agencia_Listar;
    INSERT INTO @R VALUES ('Listar Agencia','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Agencia','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vAgencia INT;
    SELECT TOP (1) @vAgencia=IdAgencia FROM dbo.Agencia;
    IF @vAgencia IS NOT NULL
    BEGIN
        EXEC dbo.usp_Agencia_Buscar @IdAgencia=@vAgencia;
        INSERT INTO @R VALUES ('Buscar Agencia','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Agencia','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Agencia','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Vendedor_Listar;
    INSERT INTO @R VALUES ('Listar Vendedor','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Vendedor','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vVendedor INT;
    SELECT TOP (1) @vVendedor=IdVendedor FROM dbo.Vendedor;
    IF @vVendedor IS NOT NULL
    BEGIN
        EXEC dbo.usp_Vendedor_Buscar @IdVendedor=@vVendedor;
        INSERT INTO @R VALUES ('Buscar Vendedor','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Vendedor','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Vendedor','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Fiador_Listar;
    INSERT INTO @R VALUES ('Listar Fiador','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Fiador','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vFiador INT;
    SELECT TOP (1) @vFiador=IdFiador FROM dbo.Fiador;
    IF @vFiador IS NOT NULL
    BEGIN
        EXEC dbo.usp_Fiador_Buscar @IdFiador=@vFiador;
        INSERT INTO @R VALUES ('Buscar Fiador','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Fiador','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Fiador','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_EstadoCredito_Listar;
    INSERT INTO @R VALUES ('Listar EstadoCredito','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar EstadoCredito','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vEstadoCredito INT;
    SELECT TOP (1) @vEstadoCredito=IdEstadoCredito FROM dbo.EstadoCredito;
    IF @vEstadoCredito IS NOT NULL
    BEGIN
        EXEC dbo.usp_EstadoCredito_Buscar @IdEstadoCredito=@vEstadoCredito;
        INSERT INTO @R VALUES ('Buscar EstadoCredito','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar EstadoCredito','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar EstadoCredito','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Credito_Listar;
    INSERT INTO @R VALUES ('Listar Credito','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Credito','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vCredito INT;
    SELECT TOP (1) @vCredito=IdCredito FROM dbo.Credito;
    IF @vCredito IS NOT NULL
    BEGIN
        EXEC dbo.usp_Credito_Buscar @IdCredito=@vCredito;
        INSERT INTO @R VALUES ('Buscar Credito','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Credito','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Credito','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_CreditoFiador_Listar;
    INSERT INTO @R VALUES ('Listar CreditoFiador','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar CreditoFiador','ERROR',ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    DECLARE @cfCredito INT, @cfFiador INT;
    SELECT TOP (1) @cfCredito=IdCredito,@cfFiador=IdFiador FROM dbo.CreditoFiador;
    IF @cfCredito IS NOT NULL
    BEGIN
        EXEC dbo.usp_CreditoFiador_Buscar @IdCredito=@cfCredito,@IdFiador=@cfFiador;
        INSERT INTO @R VALUES ('Buscar CreditoFiador','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar CreditoFiador','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar CreditoFiador','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Cuota_Listar;
    INSERT INTO @R VALUES ('Listar Cuota','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Cuota','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vCuota INT;
    SELECT TOP (1) @vCuota=IdCuota FROM dbo.Cuota;
    IF @vCuota IS NOT NULL
    BEGIN
        EXEC dbo.usp_Cuota_Buscar @IdCuota=@vCuota;
        INSERT INTO @R VALUES ('Buscar Cuota','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Cuota','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Cuota','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_MedioPago_Listar;
    INSERT INTO @R VALUES ('Listar MedioPago','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar MedioPago','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vMedioPago INT;
    SELECT TOP (1) @vMedioPago=IdMedioPago FROM dbo.MedioPago;
    IF @vMedioPago IS NOT NULL
    BEGIN
        EXEC dbo.usp_MedioPago_Buscar @IdMedioPago=@vMedioPago;
        INSERT INTO @R VALUES ('Buscar MedioPago','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar MedioPago','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar MedioPago','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    EXEC dbo.usp_Pago_Listar;
    INSERT INTO @R VALUES ('Listar Pago','OK','Ejecutado');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Listar Pago','ERROR',ERROR_MESSAGE());
END CATCH;
BEGIN TRY
    DECLARE @vPago INT;
    SELECT TOP (1) @vPago=IdPago FROM dbo.Pago;
    IF @vPago IS NOT NULL
    BEGIN
        EXEC dbo.usp_Pago_Buscar @IdPago=@vPago;
        INSERT INTO @R VALUES ('Buscar Pago','OK','Ejecutado');
    END
ELSE INSERT INTO @R VALUES ('Buscar Pago','OMITIDA','Sin registros');
END TRY BEGIN CATCH INSERT INTO @R VALUES ('Buscar Pago','ERROR',ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.Persona WHERE DPI='8999999999999')
    THROW 51000, 'DPI de prueba ocupado. No se modificaron datos.', 1;
    EXEC dbo.usp_Persona_Insertar @DPI='8999999999999', @NIT='S15-TEST-UNICO', @NombreCompleto='Prueba Script 15', @CorreoElectronico='s15@example.com', @FechaNacimiento='2000-01-01';
    SELECT @id=IdPersona FROM dbo.Persona WHERE DPI='8999999999999';
    IF @id IS NULL THROW 51001, 'Insercion no comprobada', 1;
    INSERT INTO @R VALUES ('Persona Insertar','OK','Comprobado');
    EXEC dbo.usp_Persona_Actualizar @IdPersona=@id, @DPI='8999999999999', @NIT='S15-TEST-UNICO', @NombreCompleto='Prueba Actualizada', @CorreoElectronico='s15@example.com', @FechaNacimiento='2000-01-01';
    IF NOT EXISTS (SELECT 1 FROM dbo.Persona WHERE IdPersona=@id AND NombreCompleto='Prueba Actualizada') THROW 51002, 'Actualizacion no comprobada', 1;
    INSERT INTO @R VALUES ('Persona Actualizar','OK','Comprobado');
    EXEC dbo.usp_Persona_Eliminar @IdPersona=@id;
    IF EXISTS (SELECT 1 FROM dbo.Persona WHERE IdPersona=@id) THROW 51003, 'Eliminacion no comprobada', 1;
    INSERT INTO @R VALUES ('Persona Eliminar','OK','Comprobado');
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    INSERT INTO @R VALUES ('Escritura Persona','ERROR',ERROR_MESSAGE());
END CATCH;

SELECT Prueba,Estado,Detalle FROM @R ORDER BY CASE WHEN Estado='ERROR' THEN 0 WHEN Estado='OMITIDA' THEN 1 ELSE 2 END, Prueba;
SELECT Estado,COUNT(*) AS Cantidad FROM @R GROUP BY Estado;

GO
