let clientes = [];
let idEditando = null;
let procesando = false;

function mensaje(texto, error = false) {
    const elemento = document.getElementById('mensaje');
    elemento.textContent = texto;
    elemento.style.color = error ? '#dc3545' : '#16834a';
}

async function cargarClientes() {
    const respuesta = await fetch('/api/clientes?t=' + Date.now(), {
        cache: 'no-store',
        headers: { 'Cache-Control': 'no-cache' }
    });

    if (!respuesta.ok) {
        throw new Error('No se pudo actualizar la lista de clientes.');
    }

    const datos = await respuesta.json();
    if (!Array.isArray(datos)) {
        throw new Error('El servidor no devolvió una lista válida de clientes.');
    }

    clientes = datos;
    mostrarClientes();
    return datos;
}

function mostrarClientes() {
    const buscar = document.getElementById('buscar').value.trim().toLowerCase();
    const tabla = document.getElementById('tablaClientes');
    tabla.innerHTML = '';

    const filtrados = clientes.filter(cliente =>
        String(cliente.NombreCompleto || '').toLowerCase().includes(buscar) ||
        String(cliente.DPI || '').includes(buscar)
    );

    filtrados.forEach(cliente => {
        const fila = document.createElement('tr');
        const valores = [
            cliente.IdCliente,
            cliente.NombreCompleto,
            cliente.DPI,
            cliente.NIT || 'Sin registrar',
            cliente.CorreoElectronico || 'Sin registrar'
        ];

        valores.forEach(valor => {
            const celda = document.createElement('td');
            celda.textContent = valor ?? '';
            fila.appendChild(celda);
        });

        const acciones = document.createElement('td');
        const botones = document.createElement('div');
        botones.className = 'acciones';

        const editar = document.createElement('button');
        editar.type = 'button';
        editar.textContent = 'Editar';
        editar.className = 'azul';
        editar.onclick = () => editarCliente(cliente.IdCliente);

        const eliminar = document.createElement('button');
        eliminar.type = 'button';
        eliminar.textContent = 'Eliminar';
        eliminar.className = 'rojo';
        eliminar.onclick = () => eliminarCliente(cliente.IdCliente);

        botones.appendChild(editar);
        botones.appendChild(eliminar);
        acciones.appendChild(botones);
        fila.appendChild(acciones);
        tabla.appendChild(fila);
    });

    if (filtrados.length === 0) {
        const fila = document.createElement('tr');
        const celda = document.createElement('td');
        celda.colSpan = 6;
        celda.textContent = 'No se encontraron clientes.';
        celda.style.textAlign = 'center';
        fila.appendChild(celda);
        tabla.appendChild(fila);
    }

    document.getElementById('total').textContent = filtrados.length;
}

function nuevoCliente() {
    if (procesando) return;
    idEditando = null;
    document.querySelector('form').reset();
    document.getElementById('tituloFormulario').textContent = 'Registrar nuevo cliente';
    document.getElementById('formulario').style.display = 'block';
    document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
    mensaje('');
}

function editarCliente(id) {
    if (procesando) return;
    const cliente = clientes.find(c => String(c.IdCliente) === String(id));
    if (!cliente) return;

    idEditando = id;
    document.getElementById('nombre').value = cliente.NombreCompleto || '';
    document.getElementById('dpi').value = cliente.DPI || '';
    document.getElementById('nit').value = cliente.NIT || '';
    document.getElementById('correo').value = cliente.CorreoElectronico || '';
    document.getElementById('telefonoContacto').value = '';
    document.getElementById('direccionContacto').value = '';
    fetch('/api/clientes/' + id + '/contacto').then(r=>r.json()).then(f=>{if(f[0]){document.getElementById('telefonoContacto').value=f[0].Telefono||'';document.getElementById('direccionContacto').value=f[0].Direccion||'';}}).catch(()=>{});
    document.getElementById('tituloFormulario').textContent = 'Editar cliente #' + id;
    document.getElementById('formulario').style.display = 'block';
    document.getElementById('formulario').scrollIntoView({ behavior: 'smooth' });
    mensaje('');
}

function cerrarFormulario() {
    document.getElementById('formulario').style.display = 'none';
    idEditando = null;
}

function recargarPagina(texto) {
    sessionStorage.setItem('mensajeClientesMAGIS', texto);
    window.location.reload();
}

async function guardarCliente(event) {
    event.preventDefault();
    if (procesando) return;

    const datos = {
        nombre: document.getElementById('nombre').value.trim(),
        dpi: document.getElementById('dpi').value.trim(),
        nit: document.getElementById('nit').value.trim(),
        correo: document.getElementById('correo').value.trim()
    };

    const editando = idEditando !== null;
    const id = idEditando;
    const url = editando ? '/api/clientes/' + id : '/api/clientes';
    procesando = true;
    const botonGuardar = document.querySelector('form button[type="submit"]');
    botonGuardar.disabled = true;
    mensaje('Guardando cliente...');

    try {
        const respuesta = await fetch(url, {
            method: editando ? 'PUT' : 'POST',
            headers: { 'Content-Type': 'application/json' },
            cache: 'no-store',
            body: JSON.stringify(datos)
        });
        const resultado = await respuesta.json();
        if (!respuesta.ok) {
            throw new Error(resultado.mensaje || 'No se pudo guardar el cliente.');
        }

        const idContacto = editando ? id : resultado.idCliente;
        const telefonoContacto = document.getElementById('telefonoContacto').value.trim();
        const direccionContacto = document.getElementById('direccionContacto').value.trim();
        if (idContacto && (telefonoContacto || direccionContacto)) {
            try {
                const rc = await fetch('/api/clientes/' + idContacto + '/contacto', {
                    method:'PUT',headers:{'Content-Type':'application/json'},
                    body:JSON.stringify({telefono:telefonoContacto,direccion:direccionContacto})
                });
                if(!rc.ok) mensaje('Cliente guardado; revisa el contacto por separado.', true);
            } catch(e) { mensaje('Cliente guardado; no se pudo guardar el contacto.', true); }
        }
        cerrarFormulario();
        document.getElementById('buscar').value = '';

        let listaActualizada;
        try {
            listaActualizada = await cargarClientes();
        } catch (error) {
            recargarPagina(resultado.mensaje || 'Cliente guardado correctamente.');
            return;
        }

        const actualizado = listaActualizada.some(cliente =>
            String(cliente.DPI) === datos.dpi &&
            String(cliente.NombreCompleto) === datos.nombre &&
            (!editando || String(cliente.IdCliente) === String(id))
        );

        if (!actualizado) {
            recargarPagina(resultado.mensaje || 'Cliente guardado correctamente.');
            return;
        }

        mensaje(resultado.mensaje || 'Cliente guardado correctamente.');
    } catch (error) {
        mensaje(error.message, true);
    } finally {
        procesando = false;
        botonGuardar.disabled = false;
    }
}

async function eliminarCliente(id) {
    if (procesando) return;
    if (!confirm('¿Seguro que deseas eliminar este cliente?')) return;

    procesando = true;
    mensaje('Eliminando cliente...');
    try {
        const respuesta = await fetch('/api/clientes/' + id, {
            method: 'DELETE',
            cache: 'no-store'
        });
        const resultado = await respuesta.json();
        if (!respuesta.ok) {
            throw new Error(resultado.mensaje || 'No se pudo eliminar el cliente.');
        }

        let listaActualizada;
        try {
            listaActualizada = await cargarClientes();
        } catch (error) {
            recargarPagina(resultado.mensaje || 'Cliente eliminado correctamente.');
            return;
        }

        if (listaActualizada.some(c => String(c.IdCliente) === String(id))) {
            recargarPagina(resultado.mensaje || 'Cliente eliminado correctamente.');
            return;
        }

        mensaje(resultado.mensaje || 'Cliente eliminado correctamente.');
    } catch (error) {
        mensaje(error.message, true);
    } finally {
        procesando = false;
    }
}

cargarClientes()
    .then(() => {
        const aviso = sessionStorage.getItem('mensajeClientesMAGIS');
        if (aviso) {
            mensaje(aviso);
            sessionStorage.removeItem('mensajeClientesMAGIS');
        }
    })
    .catch(error => mensaje(error.message, true));
