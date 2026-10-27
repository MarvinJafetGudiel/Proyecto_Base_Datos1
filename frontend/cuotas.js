const creditoSelect = document.getElementById('credito');
            const buscar = document.getElementById('buscar');
            const mensaje = document.getElementById('mensaje');
            let cuotas = [];

            const dinero = n => 'Q ' + Number(n || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            const fecha = s => {
                if (!s) return '';
                const v = String(s).slice(0, 10).split('-');
                return v.length === 3 ? `${v[2]}/${v[1]}/${v[0]}` : s;
            };
            const total = (arr, campo) => arr.reduce((s, f) => s + Number(f[campo] || 0), 0);

            function estado(f) {
                let pagado = Number(f.TotalPagado || 0), importe = Number(f.TotalCuota || 0);
                if (pagado >= importe - 0.005) return 'Pagada';
                if (pagado > 0) return 'Parcial';
                return 'Pendiente';
            }

            function pintar() {
                const q = buscar.value.trim().toLowerCase();
                const visibles = cuotas.filter(f => String(f.NumeroCuota).includes(q) || estado(f).toLowerCase().includes(q));
                const tbody = document.getElementById('filas');
                tbody.innerHTML = '';

                for (const f of visibles) {
                    const tr = document.createElement('tr');
                    const saldo = Math.max(0, Number(f.TotalCuota) - Number(f.TotalPagado || 0));
                    const valores = [
                        f.NumeroCuota,
                        fecha(f.FechaVencimiento),
                        dinero(f.Capital),
                        dinero(f.Interes),
                        dinero(Number(f.ManejoCuenta) + Number(f.SeguroVehiculo) + Number(f.SeguroVida)),
                        dinero(f.TotalCuota),
                        dinero(f.TotalPagado),
                        dinero(saldo)
                    ];

                    for (const v of valores) {
                        const td = document.createElement('td');
                        td.textContent = v;
                        tr.appendChild(td);
                    }

                    const td = document.createElement('td');
                    const et = document.createElement('span');
                    const e = estado(f);
                    et.className = 'estado ' + (e === 'Pagada' ? 'pagada' : e === 'Parcial' ? 'parcial' : 'pendiente');
                    et.textContent = e;
                    td.appendChild(et);
                    tr.appendChild(td);
                    tbody.appendChild(tr);
                }

                document.getElementById('cantidad').textContent = cuotas.length;
                document.getElementById('programado').textContent = dinero(total(cuotas, 'TotalCuota'));
                document.getElementById('pagado').textContent = dinero(total(cuotas, 'TotalPagado'));
                document.getElementById('saldo').textContent = dinero(cuotas.reduce((s, f) => s + Math.max(0, Number(f.TotalCuota) - Number(f.TotalPagado || 0)), 0));

                if (cuotas.length) mensaje.textContent = `Mostrando ${visibles.length} de ${cuotas.length} cuotas.`;
            }

            async function cargarCreditos() {
                try {
                    const r = await fetch('/api/creditos', { cache: 'no-store' });
                    if (!r.ok) throw Error('No se pudieron consultar los créditos.');
                    const lista = await r.json();
                    creditoSelect.innerHTML = '<option value="">Selecciona un financiamiento</option>';
                    
                    for (const c of lista) {
                        const op = document.createElement('option');
                        op.value = c.IdCredito;
                        op.textContent = `${c.NumeroObligacion} - ${c.Cliente}`;
                        creditoSelect.appendChild(op);
                    }
                    
                    const favorito = lista.find(c => c.NumeroObligacion === 'MAGIS-PRUEBA-001');
                    if (favorito) {
                        creditoSelect.value = favorito.IdCredito;
                        await cargarCuotas();
                    }
                } catch (e) {
                    mensaje.textContent = e.message;
                    mensaje.classList.add('error');
                }
            }

            async function cargarCuotas() {
                const id = creditoSelect.value;
                cuotas = [];
                buscar.value = '';
                pintar();

                if (!id) {
                    mensaje.textContent = 'Selecciona un crédito para ver sus cuotas.';
                    return;
                }

                mensaje.textContent = 'Cargando cuotas...';
                mensaje.classList.remove('error');

                try {
                    const r = await fetch('/api/cuotas?credito=' + encodeURIComponent(id), { cache: 'no-store' });
                    const datos = await r.json();
                    if (!r.ok) throw Error(datos.mensaje || 'Error al consultar cuotas.');
                    cuotas = datos;
                    pintar();
                    if (!cuotas.length) mensaje.textContent = 'Este crédito todavía no tiene cuotas registradas.';
                } catch (e) {
                    mensaje.textContent = e.message;
                    mensaje.classList.add('error');
                }
            }

            creditoSelect.addEventListener('change', cargarCuotas);
            buscar.addEventListener('input', pintar);
            cargarCreditos();
