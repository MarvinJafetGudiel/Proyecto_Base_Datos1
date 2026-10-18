const express = require('express');
const cors = require('cors');
const sql = require('msnodesqlv8');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api', (req, res, next) => {
    res.set('Cache-Control', 'no-store');
    next();
});

app.use(express.static(path.join(__dirname, '../frontend')));

// Conexion con SQL Server
const conexion =
    "Driver={ODBC Driver 18 for SQL Server};" +
    "Server=localhost;" +
    "Database=MAGIS_AUTO;" +
    "Trusted_Connection=Yes;" +
    "Encrypt=Yes;" +
    "TrustServerCertificate=Yes;";


app.get('/api/resumen', (req, res) => {

    const consulta = `
        SELECT
            (SELECT COUNT(*) FROM Persona) AS personas,
            (SELECT COUNT(*) FROM Cliente) AS clientes,
            (SELECT COUNT(*) FROM Vehiculo) AS vehiculos,
            (SELECT COUNT(*) FROM Credito) AS creditos,
            (SELECT COUNT(*) FROM Cuota) AS cuotas,
            (SELECT COUNT(*) FROM Pago) AS pagos;
    `;

    sql.query(conexion, consulta, (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al consultar resumen:', error.message);

            return res.status(500).json({
                mensaje: 'Error al consultar la base de datos.'
            });
        }

        res.json(resultados[0]);
    });
});

// LISTAR CLIENTES
app.get('/api/clientes', (req, res) => {

    const consulta = `
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
    `;

    sql.query(conexion, consulta, (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al listar clientes:', error.message);

            return res.status(500).json({
                mensaje: 'Error al consultar clientes.'
            });
        }

        res.json(resultados);
    });
});

// REGISTRAR CLIENTE
app.post('/api/clientes', (req, res) => {

    const { nombre, dpi, nit, correo } = req.body;

    if (
        typeof nombre !== 'string' ||
        !nombre.trim() ||
        typeof dpi !== 'string' ||
        !/^\d{13}$/.test(dpi)
    ) {
        return res.status(400).json({
            mensaje: 'Ingresa un nombre y un DPI de 13 digitos.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Persona
                (DPI, NIT, NombreCompleto, CorreoElectronico)
            VALUES (?, ?, ?, ?);

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
    `;

    sql.query(conexion, consulta, [
        dpi,
        nit || null,
        nombre.trim(),
        correo || null
    ], (error, resultados) => {


        if (res.headersSent) return;

        if (error) {
            console.error('Error al registrar cliente:', error.message);

            return res.status(400).json({
                mensaje: 'No se pudo registrar. Revisa los datos, el DPI y el NIT.'
            });
        }

        const cliente = Array.isArray(resultados)
            ? resultados.find(fila =>
                fila && fila.IdCliente !== undefined
            )
            : null;

        if (!cliente) return;

        res.status(201).json({
            mensaje: 'Cliente registrado correctamente.',
            idCliente: cliente.IdCliente
        });
    });
});

// ACTUALIZAR CLIENTE
app.put('/api/clientes/:id', (req, res) => {

    const id = Number(req.params.id);
    const { nombre, dpi, nit, correo } = req.body;

    if (
        !Number.isInteger(id) ||
        id <= 0 ||
        typeof nombre !== 'string' ||
        !nombre.trim() ||
        typeof dpi !== 'string' ||
        !/^\d{13}$/.test(dpi)
    ) {
        return res.status(400).json({
            mensaje: 'Datos del cliente incorrectos.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;

        UPDATE P
        SET P.NombreCompleto = ?,
            P.DPI = ?,
            P.NIT = ?,
            P.CorreoElectronico = ?
        FROM Persona P
        INNER JOIN Cliente C
            ON P.IdPersona = C.IdPersona
        WHERE C.IdCliente = ?;

        SELECT @@ROWCOUNT AS Actualizados;
    `;

    sql.query(conexion, consulta, [
        nombre.trim(),
        dpi,
        nit || null,
        correo || null,
        id
    ], (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al actualizar cliente:', error.message);

            return res.status(400).json({
                mensaje: 'No se pudo actualizar. Revisa el DPI y el NIT.'
            });
        }

        const fila = Array.isArray(resultados)
            ? resultados.find(item =>
                item && item.Actualizados !== undefined
            )
            : null;

        if (!fila) return;

        if (fila.Actualizados === 0) {
            return res.status(404).json({
                mensaje: 'Cliente no encontrado.'
            });
        }

        res.json({
            mensaje: 'Cliente actualizado correctamente.'
        });
    });
});

// ELIMINAR CLIENTE
app.delete('/api/clientes/:id', (req, res) => {

    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
        return res.status(400).json({
            mensaje: 'ID incorrecto.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;

        DELETE FROM Cliente
        WHERE IdCliente = ?;

        SELECT @@ROWCOUNT AS Eliminados;
    `;

    sql.query(conexion, consulta, [id], (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al eliminar cliente:', error.message);

            return res.status(409).json({
                mensaje: 'No se puede eliminar porque el cliente tiene informacion relacionada.'
            });
        }

        const fila = Array.isArray(resultados)
            ? resultados.find(item =>
                item && item.Eliminados !== undefined
            )
            : null;

        if (!fila) return;

        if (fila.Eliminados === 0) {
            return res.status(404).json({
                mensaje: 'Cliente no encontrado.'
            });
        }

        res.json({
            mensaje: 'Cliente eliminado correctamente.'
        });
    });
});


// CONSULTAR MARCAS
app.get('/api/marcas', (req, res) => {

    const consulta = `
        SELECT IdMarca, NombreMarca
        FROM Marca
        ORDER BY NombreMarca;
    `;

    sql.query(conexion, consulta, (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);
            return res.status(500).json({
                mensaje: 'Error al consultar marcas.'
            });
        }

        res.json(filas);
    });
});

// CONSULTAR VEHICULOS
app.get('/api/vehiculos', (req, res) => {

    const consulta = `
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
    `;

    sql.query(conexion, consulta, (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);
            return res.status(500).json({
                mensaje: 'Error al consultar vehiculos.'
            });
        }

        res.json(filas);
    });
});

// VALIDAR DATOS DEL VEHICULO
function validarVehiculo(datos) {

    const vin = String(datos.vin || '')
        .trim().toUpperCase();

    const modelo = String(datos.modelo || '').trim();

    const placa = String(datos.placa || '')
        .trim().toUpperCase();

    const marca = Number(datos.idMarca);
    const anio = Number(datos.anio);
    const valor = Number(datos.valor);

    if (
        !/^[A-Z0-9]{17}$/.test(vin) ||
        !Number.isInteger(marca) ||
        marca <= 0 ||
        !modelo ||
        modelo.length > 100 ||
        !Number.isInteger(anio) ||
        anio < 1900 ||
        anio > 2100 ||
        !Number.isFinite(valor) ||
        valor <= 0 ||
        valor > 9999999999.99 ||
        placa.length > 15
    ) {
        return null;
    }

    return {
        vin,
        marca,
        modelo,
        anio,
        valor,
        placa: placa || null
    };
}

// REGISTRAR VEHICULO
app.post('/api/vehiculos', (req, res) => {

    const datos = validarVehiculo(req.body || {});

    if (!datos) {
        return res.status(400).json({
            mensaje: 'Revisa los datos. El VIN debe tener 17 caracteres.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;

        INSERT INTO Vehiculo
            (VIN, IdMarca, Modelo, AnioFabricacion,
             ValorAgencia, Placa)
        OUTPUT INSERTED.VIN
        VALUES (?, ?, ?, ?, ?, ?);
    `;

    sql.query(conexion, consulta, [
        datos.vin,
        datos.marca,
        datos.modelo,
        datos.anio,
        datos.valor,
        datos.placa
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(400).json({
                mensaje: 'No se pudo registrar. Revisa el VIN, placa y marca.'
            });
        }

        if (!Array.isArray(filas) ||
            !filas.some(fila => fila && fila.VIN)) {
            return;
        }

        res.status(201).json({
            mensaje: 'Vehiculo registrado correctamente.'
        });
    });
});

// EDITAR VEHICULO
app.put('/api/vehiculos/:vin', (req, res) => {

    const datos = validarVehiculo({
        ...req.body,
        vin: req.params.vin
    });

    if (!datos) {
        return res.status(400).json({
            mensaje: 'Datos del vehiculo incorrectos.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;

        UPDATE Vehiculo
        SET
            IdMarca = ?,
            Modelo = ?,
            AnioFabricacion = ?,
            ValorAgencia = ?,
            Placa = ?
        OUTPUT INSERTED.VIN
        WHERE VIN = ?;
    `;

    sql.query(conexion, consulta, [
        datos.marca,
        datos.modelo,
        datos.anio,
        datos.valor,
        datos.placa,
        datos.vin
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(400).json({
                mensaje: 'No se pudo actualizar el vehiculo.'
            });
        }

        if (!Array.isArray(filas)) return;

        if (!filas.some(fila => fila && fila.VIN)) {
            return res.status(404).json({
                mensaje: 'Vehiculo no encontrado.'
            });
        }

        res.json({
            mensaje: 'Vehiculo actualizado correctamente.'
        });
    });
});

// ELIMINAR VEHICULO
app.delete('/api/vehiculos/:vin', (req, res) => {

    const vin = String(req.params.vin || '')
        .trim().toUpperCase();

    if (!/^[A-Z0-9]{17}$/.test(vin)) {
        return res.status(400).json({
            mensaje: 'VIN incorrecto.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;

        DELETE FROM Vehiculo
        OUTPUT DELETED.VIN
        WHERE VIN = ?;
    `;

    sql.query(conexion, consulta, [vin], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(409).json({
                mensaje: 'No se puede eliminar porque el vehiculo tiene informacion relacionada.'
            });
        }

        if (!Array.isArray(filas)) return;

        if (!filas.some(fila => fila && fila.VIN)) {
            return res.status(404).json({
                mensaje: 'Vehiculo no encontrado.'
            });
        }

        res.json({
            mensaje: 'Vehiculo eliminado correctamente.'
        });
    });
});



// CONSULTAR CREDITOS 
app.get('/api/creditos', (req, res) => {

    const consulta = `
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
    `;

    sql.query(conexion, consulta, (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error(
                'Error al consultar creditos:',
                error.message
            );

            return res.status(500).json({
                mensaje: 'No se pudieron consultar los creditos.'
            });
        }

        res.json(resultados);
    });
});


// Consultar vendedores
app.get('/api/vendedores', (req, res) => {
    const consulta = `
        SELECT V.IdVendedor, P.NombreCompleto
        FROM Vendedor V
        INNER JOIN Persona P ON V.IdPersona = P.IdPersona
        ORDER BY P.NombreCompleto;
    `;

    sql.query(conexion, consulta, (error, filas) => {
        if (res.headersSent) return;

        if (error) {
            return res.status(500).json({
                mensaje: 'Error al consultar vendedores.'
            });
        }

        res.json(filas);
    });
});

// Registrar un nuevo crédito y cuotas
app.post('/api/creditos', (req, res) => {
    const d = req.body || {};

    const numero = String(d.numero || '').trim().toUpperCase();
    const vin = String(d.vin || '').trim().toUpperCase();
    const cliente = Number(d.idCliente);
    const vendedor = Number(d.idVendedor);
    const plazo = Number(d.plazo);
    const enganche = Number(d.enganche);
    const tasa = Number(d.tasa);

    if (
        !/^[A-Z0-9-]{3,30}$/.test(numero) ||
        !/^[A-Z0-9]{17}$/.test(vin) ||
        !Number.isInteger(cliente) || cliente <= 0 ||
        !Number.isInteger(vendedor) || vendedor <= 0 ||
        !Number.isInteger(plazo) || plazo < 1 || plazo > 120 ||
        !Number.isFinite(enganche) || enganche < 0 ||
        enganche > 9999999999 ||
        !Number.isFinite(tasa) || tasa < 0 || tasa > 100 ||
        Math.abs(Math.round(enganche * 100) - enganche * 100) > 0.000001 ||
        Math.abs(Math.round(tasa * 1000) - tasa * 1000) > 0.000001
    ) {
        return res.status(400).json({
            mensaje: 'Revisa los datos del financiamiento.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;
        SET XACT_ABORT ON;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @Numero VARCHAR(30) = ?;
            DECLARE @Cliente INT = ?;
            DECLARE @Vendedor INT = ?;
            DECLARE @VIN VARCHAR(17) = ?;
            DECLARE @Enganche DECIMAL(12,2) = ?;
            DECLARE @Plazo INT = ?;
            DECLARE @Tasa DECIMAL(6,3) = ?;

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

            SET @Intereses = ROUND(
                @Monto * @Tasa / 100.0 * @Plazo / 12.0, 2
            );

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
                    SET @Interes = @Intereses - @InteresPrevio;
                END
                ELSE
                BEGIN
                    SET @Capital = ROUND(@Monto / @Plazo, 2);
                    SET @Interes = ROUND(@Intereses / @Plazo, 2);
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
    `;

    sql.query(conexion, consulta, [
        numero, cliente, vendedor, vin,
        enganche, plazo, tasa
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.error(
                'Error al registrar credito:',
                error.message
            );

            return res.status(400).json({
                mensaje: 'No se pudo registrar: ' + error.message
            });
        }

        const registrado = Array.isArray(filas)
            ? filas.find(f =>
                f && f.IdCredito !== undefined
            )
            : null;

        if (!registrado) return;

        res.status(201).json({
            mensaje: 'Credito y cuotas registrados correctamente.',
            idCredito: registrado.IdCredito
        });
    });
});


app.get('/api/cuotas', (req, res) => {

    const idCredito = Number(req.query.credito);

    if (!Number.isInteger(idCredito) || idCredito <= 0) {
        return res.status(400).json({
            mensaje: 'Selecciona un credito valido.'
        });
    }

    const consulta = `
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
        WHERE C.IdCredito = ?
        ORDER BY C.NumeroCuota;
    `;

    sql.query(conexion, consulta, [idCredito],
        (error, resultados) => {

            if (res.headersSent) return;

            if (error) {
                console.error(
                    'Error al consultar cuotas:',
                    error.message
                );

                return res.status(500).json({
                    mensaje: 'No se pudieron consultar las cuotas.'
                });
            }

            res.json(resultados);
        }
    );
});


// Consultar medios de pago 
app.get('/api/medios-pago', (req, res) => {

    const consulta = `
        SELECT IdMedioPago, NombreMedio
        FROM MedioPago
        ORDER BY NombreMedio;
    `;

    sql.query(conexion, consulta, (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al consultar medios:', error.message);
            return res.status(500).json({
                mensaje: 'No se pudieron consultar los medios de pago.'
            });
        }

        res.json(filas);
    });
});

// Registrar un pago en una cuota
app.post('/api/pagos', (req, res) => {

    const datos = req.body || {};

    const idCuota = Number(datos.idCuota);
    const idMedio = Number(datos.idMedioPago);
    const recibo = String(datos.numeroRecibo || '')
        .trim().toUpperCase();
    const referencia = String(datos.referencia || '').trim();
    const montoTexto = String(datos.monto ?? '').trim();
    const monto = Number(montoTexto);

    if (
        !Number.isInteger(idCuota) || idCuota <= 0 ||
        !Number.isInteger(idMedio) || idMedio <= 0 ||
        !recibo || recibo.length > 30 ||
        referencia.length > 100 ||
        !/^\d+(\.\d{1,2})?$/.test(montoTexto) ||
        !Number.isFinite(monto) ||
        monto <= 0 || monto > 9999999999.99
    ) {
        return res.status(400).json({
            mensaje: 'Revisa la cuota, el medio de pago, el recibo y el monto.'
        });
    }

    const consulta = `
        SET NOCOUNT ON;
        SET XACT_ABORT ON;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @IdCuota INT = ?;
            DECLARE @IdMedio INT = ?;
            DECLARE @Recibo VARCHAR(30) = ?;
            DECLARE @Monto DECIMAL(12,2) = ?;
            DECLARE @Referencia VARCHAR(100) = ?;

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
    `;

    sql.query(conexion, consulta, [
        idCuota,
        idMedio,
        recibo,
        montoTexto,
        referencia
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al registrar pago:', error.message);

            return res.status(400).json({
                mensaje: 'No se pudo registrar el pago. Verifica el saldo de la cuota y que el recibo no este repetido.'
            });
        }

        const registrado = Array.isArray(filas)
            ? filas.find(fila =>
                fila && fila.IdPago !== undefined
            )
            : null;

        if (!registrado) return;

        res.status(201).json({
            mensaje: 'Pago registrado correctamente.',
            idPago: registrado.IdPago
        });
    });
});


// INICIAR SERVIDOR
app.listen(3000, () => {
    console.log('Servidor MAGIS-AUTO iniciado');
    console.log('Direccion: http://localhost:3000');
});
