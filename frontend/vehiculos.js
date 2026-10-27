let vehiculos = [];
let vinEditando = null;
let procesando = false;

function mensaje(texto, error = false) {
    const el = document.getElementById('mensaje');
    el.textContent = texto;
    el.style.color = error ? '#dc3545' : '#16834a';
}

async function pedirDatos(url, opciones = {}) {
    const respuesta = await fetch(url, { cache: 'no-store', ...opciones });
    const datos = await respuesta.json();
    if (!respuesta.ok) throw new Error(datos.mensaje || 'Ocurrió un error.');
    return datos;
}

async function cargarMarcas() {
    const marcas = await pedirDatos('/api/marcas');
    const select = document.getElementById('marca');
    select.innerHTML = '<option value="">Selecciona una marca</option>';
    marcas.forEach(m => {
        const opcion = document.createElement('option');
        opcion.value = m.IdMarca;
        opcion.textContent = m.NombreMarca;
        select.appendChild(opcion);
    });
}

async function cargarAgencias() {
    const agencias = await pedirDatos('/api/agencias');
    const select = document.getElementById('agenciaOrigen');
    select.replaceChildren(new Option('Sin agencia registrada', ''));
    agencias.forEach(a => select.add(new Option(a.NombreAgencia + ' (' + a.Region + ')', a.IdAgencia)));
}

async function cargarVehiculos() {
    const datos = await pedirDatos('/api/vehiculos');
    if (!Array.isArray(datos)) throw new Error('El servidor no devolvió una lista válida.');
    vehiculos = datos;
    mostrarVehiculos();
}

function mostrarVehiculos() {
    const filtro = document.getElementById('buscar').value.trim().toLowerCase();
    const filtrados = vehiculos.filter(v =>
        [v.VIN, v.NombreMarca, v.Modelo, v.Placa].some(valor =>
            String(valor || '').toLowerCase().includes(filtro)
        )
    );
    const tabla = document.getElementById('tablaVehiculos');
    tabla.innerHTML = '';
    filtrados.forEach(v => {
        const tr = document.createElement('tr');
        const valores = [v.VIN, v.NombreMarca, v.Modelo, v.AnioFabricacion,
            Number(v.ValorAgencia).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            v.Placa || 'Sin placa', v.EsNuevo === null ? 'Sin verificar' : v.EsNuevo ? 'Nuevo' : 'Usado', v.AgenciaOrigen || 'Sin registrar'];
        valores.forEach(valor => {
            const td = document.createElement('td');
            td.textContent = valor;
            tr.appendChild(td);
        });
        const td = document.createElement('td');
        const acciones = document.createElement('div');
        acciones.className = 'acciones';
        const editar = document.createElement('button');
        editar.className = 'azul';
        editar.textContent = 'Editar';
        editar.onclick = () => editarVehiculo(v.VIN);
        const eliminar = document.createElement('button');
        eliminar.className = 'rojo';
        eliminar.textContent = 'Eliminar';
        eliminar.onclick = () => eliminarVehiculo(v.VIN);
        acciones.append(editar, eliminar);
        td.appendChild(acciones);
        tr.appendChild(td);
        tabla.appendChild(tr);
    });
    if (!filtrados.length) {
        const tr = document.createElement('tr');
        const td = document.createElement('td');
        td.colSpan = 9;
        td.textContent = 'No se encontraron vehículos.';
        tr.appendChild(td);
        tabla.appendChild(tr);
    }
    document.getElementById('total').textContent = filtrados.length;
}

function nuevoVehiculo() {
    if (procesando) return;
    vinEditando = null;
    document.getElementById('formVehiculo').reset();
    document.getElementById('vin').readOnly = false;
    document.getElementById('tituloFormulario').textContent = 'Registrar nuevo vehículo';
    document.getElementById('formulario').style.display = 'block';
    document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
    mensaje('');
}

function editarVehiculo(vin) {
    if (procesando) return;
    const v = vehiculos.find(x => x.VIN === vin);
    if (!v) return;
    vinEditando = vin;
    document.getElementById('vin').value = v.VIN;
    document.getElementById('vin').readOnly = true;
    document.getElementById('marca').value = v.IdMarca;
    document.getElementById('modelo').value = v.Modelo;
    document.getElementById('anio').value = v.AnioFabricacion;
    document.getElementById('valor').value = v.ValorAgencia;
    document.getElementById('placa').value = v.Placa || '';
    document.getElementById('esNuevo').value = v.EsNuevo === null ? '' : String(Number(v.EsNuevo));
    document.getElementById('agenciaOrigen').value = v.IdAgenciaOrigen || '';
    document.getElementById('tituloFormulario').textContent = 'Editar vehículo';
    document.getElementById('formulario').style.display = 'block';
    document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
    mensaje('');
}

function cerrarFormulario() {
    document.getElementById('formulario').style.display = 'none';
    vinEditando = null;
}

async function guardarVehiculo(event) {
    event.preventDefault();
    if (procesando) return;
    const datos = {
        vin: document.getElementById('vin').value.trim().toUpperCase(),
        idMarca: document.getElementById('marca').value,
        modelo: document.getElementById('modelo').value.trim(),
        anio: document.getElementById('anio').value,
        valor: document.getElementById('valor').value,
        placa: document.getElementById('placa').value.trim(),
        esNuevo: document.getElementById('esNuevo').value,
        idAgencia: document.getElementById('agenciaOrigen').value
    };
    if (!datos.esNuevo || (datos.esNuevo === '1' && !datos.idAgencia)) {
        mensaje('Selecciona la condición y, si es nuevo, su agencia de origen.', true);
        return;
    }
    const editando = vinEditando !== null;
    const vinOriginal = vinEditando;
    procesando = true;
    document.getElementById('btnGuardar').disabled = true;
    mensaje('Guardando vehículo...');
    try {
        const respuesta = await pedirDatos(editando ? '/api/vehiculos/' + encodeURIComponent(vinOriginal) : '/api/vehiculos', {
            method: editando ? 'PUT' : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(datos)
        });
        cerrarFormulario();
        document.getElementById('buscar').value = '';
        await cargarVehiculos();
        mensaje(respuesta.mensaje);
    } catch (error) {
        mensaje(error.message, true);
    } finally {
        procesando = false;
        document.getElementById('btnGuardar').disabled = false;
    }
}

async function eliminarVehiculo(vin) {
    if (procesando || !confirm('¿Deseas eliminar el vehículo ' + vin + '?')) return;
    procesando = true;
    mensaje('Eliminando vehículo...');
    try {
        const respuesta = await pedirDatos('/api/vehiculos/' + encodeURIComponent(vin), { method: 'DELETE' });
        document.getElementById('buscar').value = '';
        await cargarVehiculos();
        mensaje(respuesta.mensaje);
    } catch (error) {
        mensaje(error.message, true);
    } finally {
        procesando = false;
    }
}

document.getElementById('formVehiculo').addEventListener('submit', guardarVehiculo);
Promise.all([cargarMarcas(), cargarAgencias(), cargarVehiculos()]).catch(error => mensaje(error.message, true));
