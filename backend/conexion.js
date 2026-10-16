
const sql = require('mssql/msnodesqlv8');

// Configuración de nuestra base de datos
const config = {
    server: 'localhost',
    database: 'MAGIS_AUTO',
    options: {
        trustedConnection: true,
        trustServerCertificate: true
    }
};

// Conectar con SQL Server
async function conectarBD() {
    try {
        const conexion = await sql.connect(config);
        console.log('Conexión exitosa con MAGIS_AUTO');
        return conexion;
    } catch (error) {
        console.error('Error al conectar:', error.message);
        throw error;
    }
}

module.exports = { conectarBD };
