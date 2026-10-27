const $ = id => document.getElementById(id);
            const money = x => 'Q ' + Number(x || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            
            async function api(url, options) {
                const r = await fetch(url, { cache: 'no-store', ...options });
                const d = await r.json();
                if (!r.ok) throw Error(d.mensaje || 'Error de servidor');
                return d;
            }
            
            function msg(id, txt) {
                $(id).textContent = txt;
            }
            
            function opciones(id, items, clave, etiqueta) {
                const s = $(id), anterior = s.value;
                s.replaceChildren();
                for (const x of items) {
                    const o = document.createElement('option');
                    o.value = x[clave];
                    o.textContent = etiqueta(x);
                    s.append(o);
                }
                if (items.some(x => String(x[clave]) === anterior)) s.value = anterior;
            }
            
            function tabla(id, rows, cols, action) {
                const cont = $(id);
                cont.replaceChildren();
                if (!rows.length) {
                    cont.textContent = 'Sin registros.';
                    return;
                }
                const t = document.createElement('table'),
                      thead = document.createElement('thead'),
                      h = document.createElement('tr');
                
                for (const [k, n] of cols) {
                    const th = document.createElement('th');
                    th.textContent = n;
                    h.append(th);
                }
                if (action) {
                    const th = document.createElement('th');
                    th.textContent = 'Acción';
                    h.append(th);
                }
                thead.append(h);
                t.append(thead);
                
                const body = document.createElement('tbody');
                for (const r of rows) {
                    const tr = document.createElement('tr');
                    for (const [k] of cols) {
                        const td = document.createElement('td');
                        td.textContent = r[k] ?? '';
                        tr.append(td);
                    }
                    if (action) {
                        const td = document.createElement('td'),
                              b = document.createElement('button');
                        b.className = 'danger';
                        b.textContent = 'Quitar';
                        b.onclick = () => action(r);
                        td.append(b);
                        tr.append(td);
                    }
                    body.append(tr);
                }
                t.append(body);
                cont.append(t);
            }
            
            function datos(form) {
                return Object.fromEntries(new FormData(form).entries());
            }
            
            async function cargarBase() {
                try {
                    const [cl, cr, fi] = await Promise.all(['/api/clientes', '/api/creditos', '/api/fiadores'].map(u => api(u)));
                    opciones('cliente', cl, 'IdCliente', x => x.IdCliente + ' · ' + x.NombreCompleto);
                    opciones('credito', cr, 'IdCredito', x => x.IdCredito + ' · ' + x.NumeroObligacion);
                    opciones('fiador', fi, 'IdFiador', x => x.IdFiador + ' · ' + x.NombreCompleto);
                    await Promise.all([cargarReferencias(), cargarAsignados()]);
                } catch (e) {
                    msg('msgRef', e.message);
                }
            }
            
            async function cargarReferencias() {
                const id = $('cliente').value;
                if (!id) return;
                try {
                    const a = await api('/api/referencias/' + id);
                    msg('contador', a.length + ' referencia(s) · ' + (a.length >= 3 ? 'Mínimo cumplido' : 'Faltan ' + (3 - a.length)));
                    tabla('tablaReferencias', a, [
                        ['NombreCompleto', 'Nombre'],
                        ['DPI', 'DPI'],
                        ['Telefonos', 'Teléfonos'],
                        ['Direcciones', 'Direcciones'],
                        ['Parentesco', 'Relación'],
                        ['LugarTrabajo', 'Trabajo']
                    ], async x => {
                        if (!confirm('¿Quitar esta referencia?')) return;
                        try {
                            await api('/api/referencias/' + x.IdReferencia, { method: 'DELETE' });
                            await cargarReferencias();
                        } catch (e) {
                            msg('msgRef', e.message);
                        }
                    });
                } catch (e) {
                    msg('msgRef', e.message);
                }
            }
            
            async function cargarAsignados() {
                const id = $('credito').value;
                if (!id) return;
                try {
                    const a = await api('/api/creditos/' + id + '/fiadores');
                    tabla('tablaAsignados', a, [
                        ['IdFiador', 'ID'],
                        ['NombreCompleto', 'Fiador'],
                        ['DPI', 'DPI']
                    ], async x => {
                        if (!confirm('¿Quitar este fiador del crédito?')) return;
                        try {
                            await api('/api/creditos/' + id + '/fiadores/' + x.IdFiador, { method: 'DELETE' });
                            await cargarAsignados();
                        } catch (e) {
                            msg('msgAsignar', e.message);
                        }
                    });
                } catch (e) {
                    msg('msgAsignar', e.message);
                }
            }
            
            $('cliente').onchange = cargarReferencias;
            $('credito').onchange = cargarAsignados;
            
            $('formReferencia').onsubmit = async e => {
                e.preventDefault();
                try {
                    await api('/api/referencias', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ ...datos(e.target), idCliente: $('cliente').value })
                    });
                    e.target.reset();
                    msg('msgRef', 'Referencia guardada.');
                    await cargarReferencias();
                } catch (x) {
                    msg('msgRef', x.message);
                }
            };
            
            $('formFiador').onsubmit = async e => {
                e.preventDefault();
                try {
                    await api('/api/fiadores', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(datos(e.target))
                    });
                    e.target.reset();
                    msg('msgFiador', 'Fiador registrado.');
                    await cargarBase();
                } catch (x) {
                    msg('msgFiador', x.message);
                }
            };
            
            $('asignar').onclick = async () => {
                try {
                    await api('/api/creditos/' + $('credito').value + '/fiadores', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ idFiador: $('fiador').value })
                    });
                    msg('msgAsignar', 'Fiador asignado.');
                    await cargarAsignados();
                } catch (e) {
                    msg('msgAsignar', e.message);
                }
            };
            
            $('cargarComisiones').onclick = async () => {
                try {
                    const a = await api('/api/comisiones');
                    tabla('tablaComisiones', a.map(x => ({
                        ...x,
                        TotalCobrado: money(x.TotalCobrado),
                        ComisionDevengada: money(x.ComisionDevengada)
                    })), [
                        ['Vendedor', 'Vendedor'],
                        ['Creditos', 'Créditos'],
                        ['PagosRecibidos', 'Pagos'],
                        ['TotalCobrado', 'Cobrado'],
                        ['ComisionDevengada', 'Comisión']
                    ]);
                } catch (e) {
                    $('tablaComisiones').textContent = e.message;
                }
            };
            
            async function cargarDepreciacion() {
                try {
                    const vin = $('vinFiltro').value.trim().toUpperCase();
                    const a = await api('/api/depreciacion' + (vin ? '?vin=' + encodeURIComponent(vin) : ''));
                    tabla('tablaDepreciacion', a.map(x => ({
                        ...x,
                        ValorAgencia: money(x.ValorAgencia),
                        EstimadoDepreciacion15: money(x.EstimadoDepreciacion15),
                        EstimadoDepreciacion20: money(x.EstimadoDepreciacion20),
                        ValorEstimado: x.ValorEstimado === null ? '' : money(x.ValorEstimado),
                        FechaValoracion: x.FechaValoracion ? String(x.FechaValoracion).slice(0, 10) : ''
                    })), [
                        ['VIN', 'VIN'],
                        ['NombreMarca', 'Marca'],
                        ['Modelo', 'Modelo'],
                        ['ValorAgencia', 'Valor agencia'],
                        ['EstimadoDepreciacion15', '-15%'],
                        ['EstimadoDepreciacion20', '-20%'],
                        ['FechaValoracion', 'Fecha valoración'],
                        ['ValorEstimado', 'Valoración'],
                        ['DepreciacionRealPorcentaje', 'Depreciación %']
                    ]);
                } catch (e) {
                    $('tablaDepreciacion').textContent = e.message;
                }
            }
            
            $('consultarDepreciacion').onclick = cargarDepreciacion;
            
            $('formValoracion').onsubmit = async e => {
                e.preventDefault();
                try {
                    await api('/api/depreciacion', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(datos(e.target))
                    });
                    e.target.reset();
                    msg('msgDep', 'Valoración histórica guardada.');
                    await cargarDepreciacion();
                } catch (x) {
                    msg('msgDep', x.message);
                }
            };
            
            cargarBase();
