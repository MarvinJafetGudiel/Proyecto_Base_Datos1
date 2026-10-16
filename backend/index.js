const express = require('express');
const cors = require('cors');
const sql = require('msnodesqlv8');
const path = require('path');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));
// Conexion con SQL Server
const conexion =
    "Driver={ODBC Driver 18 for SQL Server};" +
    "Server=localhost;" +
    "Database=MAGIS_AUTO;" +
    "Trusted_Connection=Yes;" +
    "Encrypt=Yes;" +
    "TrustServerCertificate=Yes;";



// Resumen de la base de datos
app.get('/api/resumen', (req, res) => {

    const consulta = `
        SELECT
            (SELECT COUNT(*) FROM Persona) AS personas,
            (SELECT COUNT(*) FROM Cliente) AS clientes,
            (SELECT COUNT(*) FROM Vehiculo) AS vehiculos,
            (SELECT COUNT(*) FROM Credito) AS creditos,
            (SELECT COUNT(*) FROM Cuota) AS cuotas,
            (SELECT COUNT(*) FROM Pago) AS pagos
    `;

    sql.query(conexion, consulta, (error, resultados) => {

        if (error) {
            console.log('Error:', error.message);

            return res.status(500).json({
                mensaje: 'Error al consultar la base de datos'
            });
        }

        res.json(resultados[0]);
    });
});

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
        ORDER BY C.IdCliente DESC
    `;

    sql.query(conexion, consulta, (error, resultados) => {

        if (error) {
            console.log('Error:', error.message);
            return res.status(500).json({
                mensaje: 'Error al consultar clientes'
            });
        }

        res.json(resultados);
    });
});

// Iniciar servidor
app.listen(3000, () => {
    console.log('Servidor MAGIS-AUTO iniciado');
    console.log('Direccion: http://localhost:3000');
});
