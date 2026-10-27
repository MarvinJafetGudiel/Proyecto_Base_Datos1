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

function buscarFila(resultados, columna) {
    if (!Array.isArray(resultados)) return null;

    for (const item of resultados) {
        if (Array.isArray(item)) {
            const fila = item.find(f => f && f[columna] !== undefined);
            if (fila) return fila;
        } else if (item && item[columna] !== undefined) {
            return item;
        }
    }
    return null;
}


const conexion =
    "Driver={ODBC Driver 18 for SQL Server};" +
    "Server=localhost;" +
    "Database=MAGIS_AUTO;" +
    "Trusted_Connection=Yes;" +
    "Encrypt=Yes;" +
    "TrustServerCertificate=Yes;";

app.get('/api/resumen', (req, res) => {

    const consulta = "EXEC dbo.usp_API_Resumen;";

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



app.get('/api/clientes', (req, res) => {

    const consulta = "EXEC dbo.usp_API_Clientes_Listar;";

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

    const consulta = "EXEC dbo.usp_API_Clientes_Crear ?, ?, ?, ?;";

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

        const cliente = buscarFila(resultados, 'IdCliente');

        res.status(201).json({
            mensaje: 'Cliente registrado correctamente.',
            idCliente: cliente ? cliente.IdCliente : null
        });
    });
});

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

    const consulta = "EXEC dbo.usp_API_Clientes_Actualizar ?, ?, ?, ?, ?;";

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

        const fila = buscarFila(resultados, 'Actualizados');

        if (!fila) {
            return res.status(500).json({
                mensaje: 'No se pudo confirmar la actualizacion del cliente.'
            });
        }

        if (Number(fila.Actualizados) === 0) {
            return res.status(404).json({
                mensaje: 'Cliente no encontrado.'
            });
        }

        res.json({
            mensaje: 'Cliente actualizado correctamente.'
        });
    });
});

app.delete('/api/clientes/:id', (req, res) => {

    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
        return res.status(400).json({
            mensaje: 'ID incorrecto.'
        });
    }

    const consulta = "EXEC dbo.usp_API_Clientes_Eliminar ?, ?;";

    sql.query(conexion, consulta, [id, id], (error, resultados) => {

        if (res.headersSent) return;

        if (error) {
            console.error('Error al eliminar cliente:', error.message);

            return res.status(409).json({
                mensaje: 'No se puede eliminar porque el cliente tiene informacion relacionada.'
            });
        }

        const fila = buscarFila(resultados, 'Eliminados');

        if (!fila) {
            return res.status(500).json({
                mensaje: 'No se pudo confirmar la eliminacion.'
            });
        }

        if (Number(fila.Eliminados) === 0) {
            return res.status(404).json({
                mensaje: 'Cliente no encontrado.'
            });
        }

        res.json({
            mensaje: 'Cliente eliminado correctamente.'
        });
    });
});


app.get('/api/marcas', (req, res) => {

    const consulta = "EXEC dbo.usp_API_Marcas_Listar;";

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

app.get('/api/agencias', (req, res) => consultarSP(res, 'usp_API_Agencias_Listar'));


app.get('/api/vehiculos', (req, res) => {

    const consulta = "EXEC dbo.usp_API_Vehiculos_Listar;";

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
        placa: placa || null,
        esNuevo: datos.esNuevo === true || datos.esNuevo === "1",
        idAgencia: Number(datos.idAgencia) || null
    };
}

app.post('/api/vehiculos', (req, res) => {

    const datos = validarVehiculo(req.body || {});

    if (!datos) {
        return res.status(400).json({
            mensaje: 'Revisa los datos. El VIN debe tener 17 caracteres.'
        });
    }

    const consulta = "EXEC dbo.usp_API_Vehiculos_Crear ?, ?, ?, ?, ?, ?, ?, ?;";

    sql.query(conexion, consulta, [
        datos.vin,
        datos.marca,
        datos.modelo,
        datos.anio,
        datos.valor,
        datos.placa,
        datos.esNuevo ? 1 : 0, datos.idAgencia
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(400).json({
                mensaje: 'No se pudo registrar. Revisa el VIN, placa y marca.'
            });
        }

        res.status(201).json({
            mensaje: 'Vehiculo registrado correctamente.'
        });
    });
});


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

    const consulta = "EXEC dbo.usp_API_Vehiculos_Actualizar ?, ?, ?, ?, ?, ?, ?, ?;";

    sql.query(conexion, consulta, [
        datos.marca,
        datos.modelo,
        datos.anio,
        datos.valor,
        datos.placa,
        datos.vin,
        datos.esNuevo ? 1 : 0, datos.idAgencia
    ], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(400).json({
                mensaje: 'No se pudo actualizar el vehiculo.'
            });
        }

        const fila = buscarFila(filas, 'VIN');

        if (!fila) {
            return res.status(404).json({
                mensaje: 'Vehiculo no encontrado o no se pudo confirmar el cambio.'
            });
        }

        res.json({
            mensaje: 'Vehiculo actualizado correctamente.'
        });
    });
});


app.delete('/api/vehiculos/:vin', (req, res) => {

    const vin = String(req.params.vin || '')
        .trim().toUpperCase();

    if (!/^[A-Z0-9]{17}$/.test(vin)) {
        return res.status(400).json({
            mensaje: 'VIN incorrecto.'
        });
    }

    const consulta = "EXEC dbo.usp_API_Vehiculos_Eliminar ?;";

    sql.query(conexion, consulta, [vin], (error, filas) => {

        if (res.headersSent) return;

        if (error) {
            console.log(error.message);

            return res.status(409).json({
                mensaje: 'No se puede eliminar porque el vehiculo tiene informacion relacionada.'
            });
        }

        const fila = buscarFila(filas, 'VIN');

        if (!fila) {
            return res.status(404).json({
                mensaje: 'Vehiculo no encontrado o no se pudo confirmar el cambio.'
            });
        }

        res.json({
            mensaje: 'Vehiculo eliminado correctamente.'
        });
    });
});

app.get('/api/creditos', (req, res) => {

    const consulta = "EXEC dbo.usp_API_Creditos_Listar;";

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

app.get('/api/vendedores', (req, res) => {
    const consulta = "EXEC dbo.usp_API_Vendedores_Listar;";

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

    const consulta = "EXEC dbo.usp_API_Creditos_Crear ?, ?, ?, ?, ?, ?, ?;";

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
                mensaje: mensajeNegocio(error)
            });
        }

        const registrado = buscarFila(filas, 'IdCredito');

        res.status(201).json({
            mensaje: 'Credito y cuotas registrados correctamente.',
            idCredito: registrado ? registrado.IdCredito : null
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

    const consulta = "EXEC dbo.usp_API_Cuotas_Listar ?;";

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

app.get('/api/medios-pago', (req, res) => {

    const consulta = "EXEC dbo.usp_API_MediosPago_Listar;";

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

    const consulta = "EXEC dbo.usp_API_Pagos_Crear ?, ?, ?, ?, ?;";

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

        const registrado = buscarFila(filas, 'IdPago');

        res.status(201).json({
            mensaje: 'Pago registrado correctamente.',
            idPago: registrado ? registrado.IdPago : null
        });
    });
});



app.get('/api/reportes/:numero', (req, res) => {
    const numero = Number(req.params.numero);
    if (!Number.isInteger(numero) || numero < 1 || numero > 20) {
        return res.status(400).json({ mensaje: 'Reporte no valido.' });
    }
    const inicio = /^\d{4}-\d{2}-\d{2}$/.test(req.query.inicio || '') ? req.query.inicio : null;
    const fin = /^\d{4}-\d{2}-\d{2}$/.test(req.query.fin || '') ? req.query.fin : null;
    const fechaCorte = /^\d{4}-\d{2}-\d{2}$/.test(req.query.fechaCorte || '') ? req.query.fechaCorte : null;
    const dias = req.query.minDias === undefined ? 1 : Number(req.query.minDias);
    const mes = req.query.mes === undefined || req.query.mes === '' ? null : Number(req.query.mes);
    const cliente = req.query.idCliente === undefined || req.query.idCliente === '' ? null : Number(req.query.idCliente);
    const obligacion = String(req.query.numeroCredito || '').trim();
    if (!Number.isInteger(dias) || dias < 0 || dias > 10000 ||
        (mes !== null && (!Number.isInteger(mes) || mes < 1 || mes > 12)) ||
        (cliente !== null && (!Number.isInteger(cliente) || cliente < 1)) || obligacion.length > 30) {
        return res.status(400).json({ mensaje: 'Parametros de consulta incorrectos.' });
    }
    const procedimiento = `dbo.usp_Reporte_${String(numero).padStart(2, '0')}`;
    const consulta = `EXEC ${procedimiento} ?, ?, ?, ?, ?, ?, ?;`;
    sql.query(conexion, consulta, [inicio, fin, fechaCorte, dias, mes, cliente, obligacion || null], (error, filas) => {
        if (error) {
            console.error('Error en reporte:', error.message);
            return res.status(500).json({ mensaje: 'No se pudo generar el reporte.' });
        }
        res.json(Array.isArray(filas) ? filas : []);
    });
});


function mensajeNegocio(error) {
    const m = String(error?.message || '');
    const reglas = [
        [/tres referencias/i, 'El cliente necesita al menos 3 referencias personales antes del financiamiento.'],
        [/vehiculo.*(nuevo|agencia)|agencia.*vehiculo/i, 'Solo se pueden financiar vehículos nuevos con agencia de origen registrada. Revisa la ficha del vehículo.'],
        [/ya tiene un credito/i, 'Este vehículo ya tiene un crédito registrado.'],
        [/numero de obligacion ya existe/i, 'Ese número de obligación ya existe.'],
        [/enganche es demasiado alto/i, 'El enganche debe ser menor que el precio del vehículo.'],
        [/ya existe valoracion/i, 'Ya existe una valoración para ese vehículo en esa fecha.'],
        [/ya asignado/i, 'Este fiador ya está asignado al crédito.'],
        [/ya es referencia/i, 'Esta persona ya es referencia del cliente.'],
        [/FOREIGN KEY|REFERENCE constraint/i, 'No se puede eliminar porque existen registros relacionados.'],
        [/UNIQUE KEY|duplicate key/i, 'Ya existe un registro con esos datos.']
    ];

    for (const [exp, texto] of reglas) {
        if (exp.test(m)) {
            return texto;
        }
    }

    return 'No se pudo completar la operación. Revisa los datos o consulta la terminal del servidor.';
}

function consultarSP(res, nombre, valores = [], codigo = 200) {
    const marcas = valores.map(() => '?').join(', ');

    sql.query(
        conexion,
        `EXEC dbo.${nombre}${marcas ? ' ' + marcas : ''};`,
        valores,
        (error, filas) => {
            if (error) {
                console.error(nombre, error.message);
                return res.status(400).json({ mensaje: mensajeNegocio(error) });
            }

            res.status(codigo).json(Array.isArray(filas) ? filas : []);
        }
    );
}

function positivo(valor) {
    const numero = Number(valor);

    if (Number.isInteger(numero) && numero > 0) {
        return numero;
    }

    return null;
}

function texto(valor, limite = 150) {
    if (typeof valor === 'string') {
        return valor.trim().slice(0, limite);
    }

    return '';
}

function personaValida(datos) {
    return /^\d{13}$/.test(texto(datos.dpi)) &&
        !!texto(datos.nombre) &&
        !!texto(datos.telefono, 15) &&
        !!texto(datos.direccion, 250);
}

app.get('/api/clientes/:id/contacto', (req, res) => {
    const id = positivo(req.params.id);

    if (!id) {
        return res.status(400).json({ mensaje: 'Cliente inválido.' });
    }

    consultarSP(res, 'usp_API_Cliente_Contacto_Consultar', [id]);
});

app.put('/api/clientes/:id/contacto', (req, res) => {
    const id = positivo(req.params.id);
    const datos = req.body || {};
    const telefono = texto(datos.telefono, 15);
    const direccion = texto(datos.direccion, 250);

    if (!id) {
        return res.status(400).json({ mensaje: 'Cliente inválido.' });
    }

    consultarSP(res, 'usp_API_Cliente_Contacto_Guardar', [
        id,
        telefono || null,
        direccion || null
    ]);
});

app.get('/api/referencias/:cliente', (req, res) => {
    const id = positivo(req.params.cliente);

    if (!id) {
        return res.status(400).json({ mensaje: 'Cliente invalido.' });
    }

    consultarSP(res, 'usp_API_Referencias_Listar', [id]);
});

app.post('/api/referencias', (req, res) => {
    const datos = req.body || {};
    const id = positivo(datos.idCliente);

    if (!id || !personaValida(datos) || !texto(datos.parentesco, 50)) {
        return res.status(400).json({
            mensaje: 'Completa cliente, DPI, nombre, telefono, direccion y parentesco.'
        });
    }

    consultarSP(res, 'usp_API_Referencias_Crear', [
        id,
        texto(datos.dpi),
        texto(datos.nombre),
        texto(datos.telefono, 15),
        texto(datos.direccion, 250),
        texto(datos.parentesco, 50),
        texto(datos.trabajo, 150) || null,
        texto(datos.nit, 20) || null,
        texto(datos.correo, 100) || null
    ], 201);
});

app.delete('/api/referencias/:id', (req, res) => {
    const id = positivo(req.params.id);

    if (!id) {
        return res.status(400).json({ mensaje: 'Referencia invalida.' });
    }

    consultarSP(res, 'usp_API_Referencias_Eliminar', [id]);
});

app.get('/api/fiadores', (req, res) => {
    consultarSP(res, 'usp_API_Fiadores_Listar');
});

app.post('/api/fiadores', (req, res) => {
    const datos = req.body || {};

    if (!personaValida(datos)) {
        return res.status(400).json({
            mensaje: 'Completa DPI, nombre, telefono y direccion.'
        });
    }

    consultarSP(res, 'usp_API_Fiadores_Crear', [
        texto(datos.dpi),
        texto(datos.nombre),
        texto(datos.telefono, 15),
        texto(datos.direccion, 250),
        texto(datos.nit, 20) || null,
        texto(datos.correo, 100) || null
    ], 201);
});

app.get('/api/creditos/:id/fiadores', (req, res) => {
    const id = positivo(req.params.id);

    if (!id) {
        return res.status(400).json({ mensaje: 'Credito invalido.' });
    }

    consultarSP(res, 'usp_API_CreditoFiadores_Listar', [id]);
});

app.post('/api/creditos/:id/fiadores', (req, res) => {
    const id = positivo(req.params.id);
    const fiador = positivo(req.body?.idFiador);

    if (!id || !fiador) {
        return res.status(400).json({ mensaje: 'Selecciona credito y fiador.' });
    }

    consultarSP(res, 'usp_API_CreditoFiadores_Asignar', [id, fiador], 201);
});

app.delete('/api/creditos/:id/fiadores/:fiador', (req, res) => {
    const id = positivo(req.params.id);
    const fiador = positivo(req.params.fiador);

    if (!id || !fiador) {
        return res.status(400).json({ mensaje: 'Datos incorrectos.' });
    }

    consultarSP(res, 'usp_API_CreditoFiadores_Quitar', [id, fiador]);
});

app.get('/api/comisiones', (req, res) => {
    consultarSP(res, 'usp_API_Comisiones_Listar');
});

app.get('/api/depreciacion', (req, res) => {
    const vin = texto(req.query.vin, 17).toUpperCase();

    if (vin && !/^[A-Z0-9]{17}$/.test(vin)) {
        return res.status(400).json({ mensaje: 'VIN incorrecto.' });
    }

    consultarSP(res, 'usp_API_Depreciacion_Listar', [vin || null]);
});

app.post('/api/depreciacion', (req, res) => {
    const datos = req.body || {};
    const vin = texto(datos.vin, 17).toUpperCase();
    const fecha = texto(datos.fecha, 10);
    const valor = Number(datos.valor);

    if (
        !/^[A-Z0-9]{17}$/.test(vin) ||
        !/^\d{4}-\d{2}-\d{2}$/.test(fecha) ||
        !Number.isFinite(valor) ||
        valor < 0 ||
        valor > 9999999999.99
    ) {
        return res.status(400).json({ mensaje: 'Revisa VIN, fecha y valor.' });
    }

    consultarSP(res, 'usp_API_Depreciacion_Registrar', [
        vin,
        fecha,
        valor,
        texto(datos.observacion, 250) || null
    ], 201);
});

app.listen(3000, () => {
    console.log('Servidor MAGIS-AUTO iniciado');
    console.log('Direccion: http://localhost:3000');
});
