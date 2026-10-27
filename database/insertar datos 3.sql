USE MAGIS_AUTO;

GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.Marca)
THROW 50001, 'Primero ejecute 03_insertar_catalogos.sql para cargar las marcas.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    ;
    WITH Numeros AS (
    SELECT TOP (150) ROW_NUMBER() OVER (ORDER BY object_id) AS n
    FROM sys.all_objects
    ), Marcas AS (
    SELECT IdMarca, ROW_NUMBER() OVER (ORDER BY IdMarca) AS rn,
    COUNT(*) OVER () AS total
    FROM dbo.Marca
    ), Datos AS (
    SELECT CONCAT('DEMOAUTO', RIGHT('000000000' + CAST(N.n AS VARCHAR(9)),9)) AS VIN,
    M.IdMarca,
    CASE N.n % 10
    WHEN 0 THEN 'Corolla' WHEN 1 THEN 'Civic'
    WHEN 2 THEN 'Tucson' WHEN 3 THEN 'CX-5'
    WHEN 4 THEN 'Sportage' WHEN 5 THEN 'Sentra'
    WHEN 6 THEN 'Swift' WHEN 7 THEN 'Hilux'
    WHEN 8 THEN 'Rio' ELSE 'Versa' END AS Modelo,
    CAST(2015 + (N.n % 12) AS SMALLINT) AS AnioFabricacion,
    CAST(65000 + (N.n % 30) * 5500 + (N.n % 7) * 750 AS DECIMAL(12,2)) AS ValorAgencia,
    CONCAT('D-',RIGHT('000000'+CAST(N.n AS VARCHAR(6)),6)) AS Placa
    FROM Numeros N
    JOIN Marcas M ON M.rn = ((N.n - 1) % M.total) + 1
    )
    INSERT INTO dbo.Vehiculo (VIN, IdMarca, Modelo, AnioFabricacion, ValorAgencia, Placa)
    SELECT D.VIN, D.IdMarca, D.Modelo, D.AnioFabricacion, D.ValorAgencia, D.Placa
    FROM Datos D
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Vehiculo V WHERE V.VIN = D.VIN);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

GO

SELECT COUNT(*) AS TotalVehiculos FROM dbo.Vehiculo;
SELECT TOP (15) V.VIN, M.NombreMarca, V.Modelo, V.AnioFabricacion,
V.ValorAgencia, V.Placa
FROM dbo.Vehiculo V
INNER JOIN dbo.Marca M ON M.IdMarca = V.IdMarca
ORDER BY V.VIN;

GO
