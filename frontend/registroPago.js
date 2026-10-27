const $ = id => document.getElementById(id);
            let cuotas = [];
            let creditosDisponibles = [];
            let solicitudCuotas = 0;

            const normalizar = texto => String(texto || '').normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();

            function filtrarCreditos() {
                const texto = normalizar($('buscarCredito').value);
                const anterior = $('credito').value;
                $('credito').innerHTML = '<option value="">Selecciona un crédito</option>';
                const encontrados = creditosDisponibles.filter(c =>
                    normalizar(c.NumeroObligacion + ' ' + c.Cliente).includes(texto));

                for (const c of encontrados) {
                    const op = document.createElement('option');
                    op.value = c.IdCredito;
                    op.textContent = c.NumeroObligacion + ' - ' + c.Cliente;
                    $('credito').appendChild(op);
                }
                if (encontrados.some(c => String(c.IdCredito) === anterior)) {
                    $('credito').value = anterior;
                } else if (encontrados.length === 1) {
                    $('credito').value = String(encontrados[0].IdCredito);
                } else {
                    $('credito').value = '';
                }
                if ($('credito').value !== anterior) {
                    $('buscarCuota').value = '';
                    cargarCuotas();
                }
            }

            function filtrarCuotas() {
                const texto = $('buscarCuota').value.trim();
                const anterior = $('cuota').value;
                $('cuota').innerHTML = '<option value="">Selecciona una cuota</option>';
                const encontradas = cuotas.filter(c => !texto || String(c.NumeroCuota).includes(texto));

                for (const c of encontradas) {
                    const saldo = Math.max(0, Math.round((Number(c.TotalCuota) - Number(c.TotalPagado)) * 100) / 100);
                    const op = document.createElement('option');
                    op.value = c.IdCuota;
                    op.textContent = `Cuota ${c.NumeroCuota} - Saldo ${moneda(saldo)}${saldo === 0 ? ' (Pagada)' : ''}`;
                    op.disabled = saldo === 0;
                    $('cuota').appendChild(op);
                }
                const disponible = Array.from($('cuota').options).find(o => o.value && !o.disabled);
                if (encontradas.some(c => String(c.IdCuota) === anterior) &&
                    !$('cuota').querySelector(`option[value="${anterior}"]`)?.disabled) {
                    $('cuota').value = anterior;
                } else if (disponible) {
                    $('cuota').value = disponible.value;
                }
                actualizarResumen();
            }
            
            const moneda = n => 'Q ' + Number(n || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            
            function aviso(texto, error = false) {
                $('mensaje').textContent = texto;
                $('mensaje').className = 'aviso ' + (error ? 'error' : 'ok');
            }
            
            async function obtener(url) {
                const r = await fetch(url, { cache: 'no-store' });
                const d = await r.json();
                if (!r.ok) throw new Error(d.mensaje || 'No se pudo consultar.');
                return d;
            }
            
            function actualizarResumen() {
                const c = cuotas.find(x => String(x.IdCuota) === $('cuota').value);
                const total = Number(c?.TotalCuota || 0),
                      pagado = Number(c?.TotalPagado || 0);
                const saldo = Math.max(0, Math.round((total - pagado) * 100) / 100);
                
                $('total').textContent = moneda(total);
                $('pagado').textContent = moneda(pagado);$('saldo').textContent = moneda(saldo);
                $('monto').max = saldo.toFixed(2);$('guardar').disabled = !c || saldo <= 0;
            }
            
            async function cargarCuotas() {
                const solicitud = ++solicitudCuotas;
                const credito = $('credito').value;
                $('cuota').innerHTML = '<option value="">Cargando cuotas...</option>';
                cuotas = [];
                actualizarResumen();

                if (!credito) {
                    $('cuota').innerHTML = '<option value="">Selecciona un crédito</option>';
                    return;
                }
                try {
                    const datos = await obtener('/api/cuotas?credito=' + encodeURIComponent(credito));
                    if (solicitud !== solicitudCuotas) return;
                    cuotas = datos;
                    filtrarCuotas();
                } catch (e) {
                    if (solicitud !== solicitudCuotas) return;
                    $('cuota').innerHTML = '<option value="">Error al cargar</option>';
                    aviso(e.message, true);
                }
            }

            async function iniciar() {
                $('guardar').disabled = true;
                try {
                    const [creditos, medios] = await Promise.all([obtener('/api/creditos'), obtener('/api/medios-pago')]);
                    
                    creditosDisponibles = creditos;
                    filtrarCreditos();

                    $('medio').innerHTML = '<option value="">Selecciona un medio</option>';
                    for (const m of medios) {
                        const o = document.createElement('option');
                        o.value = m.IdMedioPago;
                        o.textContent = m.NombreMedio;
                        $('medio').append(o);
                    }

                    if (creditos.length) {
                        $('credito').value = String(creditos[0].IdCredito);
                        await cargarCuotas();
                    }
                } catch (e) {
                    aviso('No se pudieron cargar los datos: ' + e.message, true);
                }
            }
            
            $('buscarCredito').addEventListener('input', filtrarCreditos);
            $('buscarCuota').addEventListener('input', filtrarCuotas);
            $('credito').addEventListener('change', () => {
                $('buscarCuota').value = '';
                cargarCuotas();
            });
            $('cuota').addEventListener('change', actualizarResumen);$('formulario').addEventListener('submit', async e => {
                e.preventDefault();
                const c = cuotas.find(x => String(x.IdCuota) === $('cuota').value);
                const monto = Number($('monto').value),
                      saldo = c ? Math.round((Number(c.TotalCuota) - Number(c.TotalPagado)) * 100) / 100 : 0;
                
                if (!c || !$('credito').value || !Number.isFinite(monto) || monto <= 0 || monto > saldo) {
                    aviso('El monto debe ser mayor a cero y no superar el saldo de la cuota.', true);
                    return;
                }
                
                if (!confirm('¿Registrar el pago de ' + moneda(monto) + '?')) return;
                
                $('guardar').disabled = true;
                try {
                    const r = await fetch('/api/pagos', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            idCuota: c.IdCuota,
                            idMedioPago: Number($('medio').value),
                            numeroRecibo: $('recibo').value.trim(),
                            monto: $('monto').value,
                            referencia: $('referencia').value.trim()
                        })
                    });
                    
                    const d = await r.json();
                    if (!r.ok) throw new Error(d.mensaje || 'No se pudo registrar el pago.');
                    
                    $('monto').value = '';
                    $('recibo').value = '';$('referencia').value = '';
                    await cargarCuotas();
                    aviso(d.mensaje);
                } catch (err) {
                    aviso(err.message, true);
                } finally {
                    actualizarResumen();
                }
            });
            
            iniciar();
