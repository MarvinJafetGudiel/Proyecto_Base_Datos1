# MAGIS-AUTO

## Descripción del proyecto

MAGIS-AUTO es nuestro proyecto final del curso de Bases de Datos 1. Es un sistema web para llevar el control de una empresa que vende vehículos por financiamientos.

La idea del proyecto es tener la información organizada en un solo lugar y hacer más fácil el registro de clientes, vehículos, créditos, cuotas y pagos.

## ¿Qué permite hacer?

- Registrar y consultar clientes y vehículos.
- Crear financiamientos y generar sus cuotas.
- Registrar pagos y abonos parciales.
- Consultar los saldos y las cuotas pendientes.
- Guardar referencias personales de los clientes.
- Registrar fiadores y asignarlos a los créditos.
- Consultar las comisiones de los vendedores.
- Llevar un registro de la depreciación de los vehículos.
- Ver el resumen general del negocio y los reportes financieros.

Para crear un financiamiento, el cliente debe tener por lo menos tres referencias personales. Además, los nuevos financiamientos solo permiten vehículos registrados como nuevos y con su agencia de origen.

## Herramientas usadas

- **SQL Server 2022:** para guardar los datos.
- **SQL Server Management Studio:** para trabajar con la base de datos.
- **Node.js y Express:** para conectar el sistema web con SQL Server.
- **HTML, CSS y JavaScript:** para las pantallas y las funcionalidades del sistema.
- **Visual Studio Code:** para editar el proyecto.

## Organización de las carpetas

- **backend:** contiene la conexión con SQL Server y las funciones del servidor.
- **frontend:** contiene las pantallas, los estilos y los archivos JavaScript.
- **database:** contiene los scripts de la base de datos, los procedimientos y los reportes.
- **docs:** contiene los documentos del proyecto.
- **evidencias:** contiene las capturas de las pruebas realizadas.

## Cómo ejecutar el proyecto

El sistema necesita tener SQL Server, Node.js y la base de datos `MAGIS_AUTO` configurados.

1. Abrir SQL Server y comprobar que la base de datos `MAGIS_AUTO` esté disponible.
2. Abrir la carpeta `backend` en una terminal.
3. Si es la primera vez que se ejecuta en esa computadora, escribir:

   ```bash
   npm install
   ```

4. Iniciar el servidor con:

   ```bash
   node index.js
   ```

5. Abrir el navegador y entrar a:

   `http://localhost:3000`

La conexión está configurada en `backend/conexion.js` para usar SQL Server en la misma computadora, con autenticación de Windows. Si se utiliza otra computadora o servidor, se debe revisar la configuración.

## Base de datos

El proyecto trabaja con 17 tablas principales y utiliza procedimientos almacenados para las operaciones del sistema. También incluye 20 reportes financieros para consultar la información del negocio.

Los archivos SQL están en la carpeta `database`. Si la base de datos ya está instalada y funcionando, **no se deben ejecutar otra vez los scripts de creación ni los de insertar datos**, porque podrían afectar la información existente.

Para los últimos ajustes se utilizaron estos archivos:

- `AjustesFinales.sql`
- `VerificacionFinal.sql`


## Pruebas realizadas

Durante el desarrollo probé el registro de clientes, la creación de financiamientos, la generación de cuotas, los pagos parciales, las referencias personales, los fiadores, las comisiones y la depreciación de vehículos. También revisé el funcionamiento del panel principal y varios reportes financieros.

El sistema se ejecutó correctamente en mi computadora. Algunas operaciones de administración de las tablas se trabajan directamente con procedimientos SQL y no tienen una pantalla propia.

