let creditos = [];
            const dinero = valor => 'Q ' + Number(valor || 0).toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

            async function cargarCreditos() {
                const mensaje = document.getElementById('mensaje');
                try {
                    const respuesta = await fetch('/api/creditos?actualizar=' + Date.now(), { cache: 'no-store' });
                    if (!respuesta.ok) throw new Error('No se pudieron cargar los créditos.');
                    creditos = await respuesta.json();
                    mostrarCreditos();
                } catch (error) {
                    mensaje.textContent = error.message;
                }
            }

            function mostrarCreditos() {
                const buscar = document.getElementById('buscar').value.toLowerCase().trim();
                const tabla = document.getElementById('tablaCreditos');
                tabla.innerHTML = '';
                
                const filtrados = creditos.filter(c =>
                    [c.NumeroObligacion, c.Cliente, c.NombreMarca, c.Modelo, c.VIN, c.NombreEstado]
                        .some(valor => String(valor || '').toLowerCase().includes(buscar))
                );
                
                for (const c of filtrados) {
                    const fila = document.createElement('tr');
                    const valores = [
                        c.NumeroObligacion,
                        c.Cliente,
                        c.NombreMarca + ' ' + c.Modelo,
                        c.NombreEstado,
                        c.PlazoMeses + ' meses',
                        dinero(c.Enganche),
                        dinero(c.MontoFinanciado),
                        dinero(c.TotalIntereses),
                        dinero(c.TotalRecaudable)
                    ];
                    
                    valores.forEach((valor, indice) => {
                        const celda = document.createElement('td');
                        if (indice === 3) {
                            const estado = document.createElement('span');
                            estado.className = 'estado';
                            estado.textContent = valor;
                            celda.appendChild(estado);
                        } else {
                            celda.textContent = valor;
                        }
                        fila.appendChild(celda);
                    });
                    
                    tabla.appendChild(fila);
                }
                
                document.getElementById('total').textContent = filtrados.length;
            }

            cargarCreditos();
