(function () {
  'use strict';
  const $ = id => document.getElementById(id);
  const dinero = valor => 'Q' + Number(valor || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const numero = valor => Number(valor || 0).toLocaleString('es-GT');
  const colores = ['#348bff', '#19c4ee', '#1bd3a2', '#ffad3d', '#ec5a96', '#a879ff', '#7c9cff', '#f17763'];
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  const anio = new Date().getFullYear();
  let actualizando = false;

  async function consultar(url) {
    const respuesta = await fetch(url, { cache: 'no-store' });
    if (!respuesta.ok) throw new Error('No se pudo consultar ' + url);
    return respuesta.json();
  }
  function filas(datos) {
    return Array.isArray(datos) ? datos : [];
  }
  function texto(id, valor) {
    $(id).textContent = valor;
  }
  function donut(id, lista, campo) {
    const total = lista.reduce((a, f) => a + Number(f[campo] || 0), 0);
    if (!total) { $(id).style.background = '#243e5d'; return; }
    let inicio = 0;
    const segmentos = [];
    lista.forEach((item, i) => {
      const fin = inicio + Number(item[campo] || 0) / total * 100;
      segmentos.push(`${colores[i % colores.length]} ${inicio.toFixed(3)}% ${fin.toFixed(3)}%`);
      inicio = fin;
    });
    $(id).style.background = 'conic-gradient(' + segmentos.join(',') + ')';
  }
  function leyenda(id, lista, nombre, cantidad, moneda) {
    const caja = $(id);
    caja.replaceChildren();
    if (!lista.length) { const p = document.createElement('p'); p.className = 'db-empty'; p.textContent = 'No hay registros para este período.'; caja.append(p); return; }
    lista.forEach((item, i) => {
      const fila = document.createElement('div'); fila.className = 'db-legend-row';
      const punto = document.createElement('i'); punto.style.background = colores[i % colores.length];
      const etiqueta = document.createElement('span'); etiqueta.textContent = item[nombre]; etiqueta.title = item[nombre];
      const valor = document.createElement('strong'); valor.textContent = moneda ? dinero(item[cantidad]) : numero(item[cantidad]);
      fila.append(punto, etiqueta, valor); caja.append(fila);
    });
  }
  function pintarMeses(valores) {
    const max = Math.max(...valores, 1);
    const eje = $('ejeMeses'); eje.replaceChildren();
    for (let i = 4; i >= 0; i--) {
      const n = max * i / 4;
      const marca = document.createElement('span');
      marca.textContent = n >= 1000000 ? 'Q' + (n / 1000000).toFixed(1) + 'M' : n >= 1000 ? 'Q' + Math.round(n / 1000) + 'k' : 'Q' + Math.round(n);
      eje.append(marca);
    }
    const barras = $('graficaMeses'); barras.replaceChildren();
    valores.forEach((valor, i) => {
      const columna = document.createElement('div'); columna.className = 'db-bar-col';
      columna.title = meses[i] + ': ' + dinero(valor);
      const barra = document.createElement('div'); barra.className = 'db-bar';
      barra.style.height = (valor ? Math.max(2, valor / max * 87) : 1) + '%';
      const etiqueta = document.createElement('span'); etiqueta.className = 'db-bar-label'; etiqueta.textContent = meses[i];
      columna.append(barra, etiqueta); barras.append(columna);
    });
    texto('totalGrafica', 'Total: ' + dinero(valores.reduce((a, b) => a + b, 0)));
  }
  function pintarEstados(creditos) {
    const conteo = new Map();
    creditos.forEach(c => {
      const estado = String(c.NombreEstado || 'Sin estado');
      conteo.set(estado, (conteo.get(estado) || 0) + 1);
    });
    const lista = Array.from(conteo, ([NombreEstado, Cantidad]) => ({ NombreEstado, Cantidad })).sort((a, b) => b.Cantidad - a.Cantidad);
    texto('creditosDonut', numero(creditos.length));
    donut('graficaEstados', lista, 'Cantidad');
    leyenda('leyendaEstados', lista, 'NombreEstado', 'Cantidad', false);
  }
  function pintarModelos(creditos) {
    const conteo = new Map();
    creditos.forEach(c => {
      const modelo = [c.NombreMarca, c.Modelo].filter(Boolean).join(' ') || 'Sin modelo';
      conteo.set(modelo, (conteo.get(modelo) || 0) + 1);
    });
    const lista = Array.from(conteo, ([nombre, cantidad]) => ({ nombre, cantidad })).sort((a, b) => b.cantidad - a.cantidad).slice(0, 5);
    const caja = $('modelosPopulares'); caja.replaceChildren();
    if (!lista.length) { caja.textContent = 'Todavía no hay créditos registrados.'; return; }
    const max = lista[0].cantidad;
    lista.forEach(item => {
      const fila = document.createElement('div'); fila.className = 'db-model-row';
      const nombre = document.createElement('span'); nombre.className = 'db-model-name'; nombre.textContent = item.nombre; nombre.title = item.nombre;
      const track = document.createElement('div'); track.className = 'db-model-track';
      const fill = document.createElement('div'); fill.className = 'db-model-fill'; fill.style.width = (item.cantidad / max * 100) + '%'; track.append(fill);
      const n = document.createElement('strong'); n.textContent = numero(item.cantidad);
      fila.append(nombre, track, n); caja.append(fila);
    });
  }
  function pintarClientes(clientes) {
    const caja = $('clientesRecientes'); caja.replaceChildren();
    const lista = clientes.slice().sort((a, b) => Number(b.IdCliente) - Number(a.IdCliente)).slice(0, 5);
    if (!lista.length) { caja.textContent = 'Todavía no hay clientes registrados.'; return; }
    lista.forEach(c => {
      const fila = document.createElement('div'); fila.className = 'db-recent-row';
      const nombre = String(c.NombreCompleto || 'Cliente');
      const iniciales = nombre.split(/\s+/).slice(0, 2).map(p => p.charAt(0)).join('').toUpperCase();
      const avatar = document.createElement('span'); avatar.className = 'db-initials'; avatar.textContent = iniciales;
      const etiqueta = document.createElement('span'); etiqueta.className = 'db-recent-name'; etiqueta.textContent = nombre; etiqueta.title = nombre;
      const id = document.createElement('span'); id.className = 'db-recent-id'; id.textContent = '#' + c.IdCliente;
      fila.append(avatar, etiqueta, id); caja.append(fila);
    });
  }
  async function cargarDatos() {
    if (actualizando) return;
    actualizando = true;
    $('actualizar').disabled = true;
    texto('estado', 'Actualizando información de SQL Server…');
    const inicio = `${anio}-01-01`;
    const fin = `${anio}-12-31`;
    const periodo = `?inicio=${inicio}&fin=${fin}`;
    const respuestas = await Promise.allSettled([
      consultar('/api/resumen'),
      consultar('/api/creditos'),
      consultar('/api/clientes'),
      consultar('/api/reportes/3' + periodo)
    ]);
    const fallos = [];
    if (respuestas[0].status === 'fulfilled') {
      const r = respuestas[0].value;
      ['clientes', 'vehiculos', 'creditos'].forEach(k => texto(k, numero(r[k])));
      texto('personasExtra', 'Personas registradas: ' + numero(r.personas));
      texto('cuotasExtra', 'Cuotas programadas: ' + numero(r.cuotas));
    } else fallos.push('indicadores');
    if (respuestas[1].status === 'fulfilled') {
      const c = filas(respuestas[1].value);
      pintarEstados(c); pintarModelos(c);
    } else fallos.push('créditos');
    if (respuestas[2].status === 'fulfilled') pintarClientes(filas(respuestas[2].value));
    else fallos.push('clientes');
    if (respuestas[3].status === 'fulfilled') {
      const medios = filas(respuestas[3].value).map(f => ({ NombreMedio: f.NombreMedio || 'Otro', CantidadPagos: Number(f.CantidadPagos || 0), TotalRecaudado: Number(f.TotalRecaudado || 0) })).sort((a, b) => b.TotalRecaudado - a.TotalRecaudado);
      const total = medios.reduce((s, f) => s + f.TotalRecaudado, 0);
      const pagos = medios.reduce((s, f) => s + f.CantidadPagos, 0);
      texto('recaudado', dinero(total)); texto('pagosExtra', 'Pagos del período: ' + numero(pagos));
      texto('pagosDonut', numero(pagos)); donut('graficaMedios', medios, 'TotalRecaudado');
      leyenda('leyendaMedios', medios, 'NombreMedio', 'TotalRecaudado', true);
    } else fallos.push('medios de pago');

    const consultasMes = meses.map((_, i) => {
      const m = String(i + 1).padStart(2, '0');
      const ultimo = new Date(anio, i + 1, 0).getDate();
      return consultar(`/api/reportes/3?inicio=${anio}-${m}-01&fin=${anio}-${m}-${ultimo}`);
    });
    const mesesRespuesta = await Promise.allSettled(consultasMes);
    const valores = mesesRespuesta.map(r => r.status === 'fulfilled' ? filas(r.value).reduce((s, f) => s + Number(f.TotalRecaudado || 0), 0) : 0);
    pintarMeses(valores);
    if (mesesRespuesta.some(r => r.status === 'rejected')) fallos.push('algunos meses');
    texto('estado', fallos.length ? 'No se pudieron cargar: ' + fallos.join(', ') + '. Revisa el servidor y vuelve a actualizar.' : '● Panel actualizado correctamente con información real de SQL Server.');
    $('estado').style.color = fallos.length ? '#ffc16e' : '#46d9b4';
    $('actualizar').disabled = false;
    actualizando = false;
  }
  function iniciar() {
    texto('anioGrafica', String(anio)); texto('anioMedios', String(anio)); texto('etiquetaAnio', String(anio));
    texto('fechaActual', new Intl.DateTimeFormat('es-GT', { day: 'numeric', month: 'long', year: 'numeric' }).format(new Date()));
    $('actualizar').addEventListener('click', cargarDatos);
    cargarDatos();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', iniciar);
  else iniciar();
})();
