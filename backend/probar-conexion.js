const sql = require('msnodesqlv8');

const conexion = 
    "Driver={ODBC Driver 18 for SQL Server};" +
    "Server=localhost;" +
    "Database=MAGIS_AUTO;" +
    "Trusted_Connection=Yes;" +
    "Encrypt=Yes;" +
    "TrustServerCertificate=Yes;";

sql.query(
    conexion,
    "SELECT COUNT(*) AS TotalPersonas FROM Persona",
    (error, resultados) => {

        if (error) {
            console.log("Error de conexión:");
            console.log(error.message);
        } else {
            console.log("Conexión exitosa a MAGIS-AUTO");
            console.log("Personas registradas:", resultados[0].TotalPersonas);
        }

    }
);