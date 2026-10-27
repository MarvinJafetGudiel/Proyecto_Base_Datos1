const $ = id => document.getElementById(id);
            let vehiculos = [];
            let clientes = [];
            const dinero = n => 'Q ' + Number(n || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            
            function opcion(select, valor, texto) {
                const o = document.createElement('option');
                o.value = valor;
                o.textContent = texto;
                select.appendChild(o);
            }
            
            
            function normalizar(texto) {
                return String(texto || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
            }

            function buscarClientes() {
                const busqueda = normalizar($('buscarCliente').value.trim());
                const seleccion = $('cliente').value;
                const encontrados = clientes.filter(c =>
                    normalizar(c.NombreCompleto).includes(busqueda) ||
                    String(c.DPI || '').includes(busqueda)
                );
                $('cliente').innerHTML = '';
                opcion($('cliente'), '', encontrados.length ? 'Selecciona un cliente' : 'No se encontraron clientes');
                encontrados.forEach(c => opcion($('cliente'), c.IdCliente, `${c.NombreCompleto} · ${c.DPI}`));
                if (encontrados.some(c => String(c.IdCliente) === seleccion)) {
                    $('cliente').value = seleccion;
                }
            }

            function buscarVehiculos() {
                const busqueda = normalizar($('buscarVehiculo').value.trim());
                const seleccion = $('vehiculo').value;
                const encontrados = vehiculos.filter(v =>
                    normalizar(`${v.NombreMarca} ${v.Modelo} ${v.Placa || ''} ${v.VIN} ${v.AnioFabricacion}`).includes(busqueda)
                );
                $('vehiculo').innerHTML = '';
                opcion($('vehiculo'), '', encontrados.length ? 'Selecciona un vehículo' : 'No se encontraron vehículos disponibles');
                encontrados.forEach(v => opcion($('vehiculo'), v.VIN,
                    `${v.NombreMarca} ${v.Modelo} (${v.AnioFabricacion}) · ${v.Placa || 'Sin placa'} · ${dinero(v.ValorAgencia)}`));
                if (encontrados.some(v => v.VIN === seleccion)) {
                    $('vehiculo').value = seleccion;
                }
                actualizar();
            }

            async function cargar() {
                try {
                    const urls = ['/api/clientes', '/api/vendedores', '/api/vehiculos', '/api/creditos'];
                    const respuestas = await Promise.all(urls.map(u => fetch(u, { cache: 'no-store' })));
                    
                    if (respuestas.some(r => !r.ok)) throw Error('No se pudieron consultar los datos del sistema.');
                    
                    const [datosClientes, vendedores, todos, creditos] = await Promise.all(respuestas.map(r => r.json()));
                    clientes = datosClientes;
                    const usados = new Set(creditos.map(c => c.VIN));
                    vehiculos = todos.filter(v => !usados.has(v.VIN) && Number(v.EsNuevo) === 1 && v.IdAgenciaOrigen);
                    
                    [['cliente', 'Selecciona un cliente'], ['vendedor', 'Selecciona un vendedor'], ['vehiculo', 'Selecciona un vehículo']].forEach(([id, t]) => {
                        $(id).innerHTML = '';
                        opcion($(id), '', t);
                    });
                    
                    $('buscarCliente').value = '';
                    $('buscarVehiculo').value = '';
                    buscarClientes();
                    vendedores.forEach(v => opcion($('vendedor'), v.IdVendedor, v.NombreCompleto));
                    buscarVehiculos();
                } catch (e) {
                    $('mensaje').textContent = e.message;
                    $('mensaje').className = 'error';
                }
            }
            
            function actualizar() {
                const v = vehiculos.find(x => x.VIN === $('vehiculo').value);
                const precio = Number(v?.ValorAgencia || 0),
                      enganche = Number($('enganche').value || 0),
                      plazo = Number($('plazo').value || 1),
                      tasa = Number($('tasa').value || 0);
                
                const monto = Math.max(0, precio - enganche);
                let saldo = monto, intereses = 0;
                for (let i = 1; i <= plazo; i++) {
                    const capital = i === plazo ? saldo : Math.round(monto / plazo * 100) / 100;
                    intereses += Math.round(saldo * tasa / 1200 * 100) / 100;
                    saldo = Math.max(0, Math.round((saldo - capital) * 100) / 100);
                }
                const total = monto + intereses + plazo * 265;
                
                $('precio').textContent = dinero(precio);
                $('financiado').textContent = dinero(monto);$('intereses').textContent = dinero(intereses);
                $('total').textContent = dinero(total);$('cuota').textContent = dinero(total / plazo);
            }
            
            $('buscarCliente').addEventListener('input', buscarClientes);
            $('buscarVehiculo').addEventListener('input', buscarVehiculos);
            ['vehiculo', 'enganche', 'plazo', 'tasa'].forEach(id => $(id).addEventListener('input', actualizar));

            $('formulario').addEventListener('submit', async e => {
                e.preventDefault();
                const v = vehiculos.find(x => x.VIN === $('vehiculo').value);
                
                if (!v) {
                    $('mensaje').textContent = 'Selecciona un vehículo disponible.';
                    $('mensaje').className = 'error';
                    return;
                }
                
                if (Number($('enganche').value) >= Number(v.ValorAgencia)) {$('mensaje').textContent = 'El enganche debe ser menor que el valor del vehículo.';
                    $('mensaje').className = 'error';
                    return;
                }
                
                if (!confirm('¿Confirmas registrar este crédito y generar todas sus cuotas?')) return;
                
                $('guardar').disabled = true;
                $('mensaje').textContent = 'Guardando...';$('mensaje').className = '';
                
                try {
                    const r = await fetch('/api/creditos', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            numero: $('numero').value,
                            idCliente: $('cliente').value,
                            idVendedor: $('vendedor').value,
                            vin: $('vehiculo').value,
                            enganche: Number($('enganche').value),
                            plazo: Number($('plazo').value),
                            tasa: Number($('tasa').value)
                        })
                    });
                    
                    const data = await r.json();
                    if (!r.ok) throw Error(data.mensaje || 'Error al registrar.');
                    
                    $('formulario').reset();
                    await cargar();
                    $('mensaje').textContent = data.mensaje;
                    $('mensaje').className = 'ok';
                } catch (err) {
                    $('mensaje').textContent = err.message;
                    $('mensaje').className = 'error';
                } finally {
                    $('guardar').disabled = false;
                }
            });
            
            cargar();
