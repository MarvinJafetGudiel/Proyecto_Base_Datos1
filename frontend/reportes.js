const reportes = [
                {"id": 1, "title": "Créditos emitidos en un período", "reason": "medir volumen de colocaciones"},
                {"id": 2, "title": "Cartera en mora", "reason": "priorizar cobros por días de atraso y saldo vencido"},
                {"id": 3, "title": "Pagos por medio y período", "reason": "identificar el canal de cobro más utilizado"},
                {"id": 4, "title": "Ventas por vendedor", "reason": "comparar colocaciones de crédito"},
                {"id": 5, "title": "Cumpleañeros del mes", "reason": "preparar felicitaciones para clientes"},
                {"id": 6, "title": "Estado de cuenta por cliente", "reason": "consultar obligaciones y saldo por crédito"},
                {"id": 7, "title": "Plan de pagos por crédito", "reason": "visualizar calendario de cuotas y abonos"},
                {"id": 8, "title": "CREDITOS POR ESTADO", "reason": "permite conocer la distribucion de la cartera"},
                {"id": 9, "title": "SALDO PENDIENTE POR CREDITO", "reason": "total de cuotas menos pagos registrados"},
                {"id": 10, "title": "HISTORIAL DE PAGOS POR CLIENTE", "reason": "detalle de recibos y abonos"},
                {"id": 11, "title": "CREDITOS POR AGENCIA", "reason": "compara la actividad comercial"},
                {"id": 12, "title": "VEHICULOS FINANCIADOS POR MARCA", "reason": "identifica marcas mas financiadas"},
                {"id": 13, "title": "INTERESES POR CREDITO", "reason": "facilita revisar el costo financiero"},
                {"id": 14, "title": "CREDITOS CON FIADORES", "reason": "permite revisar las garantias personales"},
                {"id": 15, "title": "CUOTAS CON SALDO PENDIENTE", "reason": "Consulta financiera para control y seguimiento"},
                {"id": 16, "title": "CUOTAS PAGADAS COMPLETAMENTE", "reason": "Consulta financiera para control y seguimiento"},
                {"id": 17, "title": "CUOTAS CON ABONOS PARCIALES", "reason": "Consulta financiera para control y seguimiento"},
                {"id": 18, "title": "RECAUDACION MENSUAL", "reason": "Consulta financiera para control y seguimiento"},
                {"id": 19, "title": "CLIENTES CON MAYOR MONTO FINANCIADO", "reason": "Consulta financiera para control y seguimiento"},
                {"id": 20, "title": "RESUMEN GENERAL DE CARTERA", "reason": "Consulta financiera para control y seguimiento"}
            ];
            
            const $ = id => document.getElementById(id);
            let filasActuales = [];
            
            function cambiarReporte() {
                const r = reportes.find(x => x.id === Number($('reporte').value));$('motivo').textContent = '¿Para qué sirve? ' + r.reason;
                $('tituloResultado').textContent = r.id + '. ' + r.title;
            }
            
            $('reporte').addEventListener('change', cambiarReporte);
            cambiarReporte();
            
            function formatear(valor) {
                if (valor === null || valor === undefined) return '';
                if (typeof valor === 'object') return JSON.stringify(valor);
                return String(valor);
            }
            
            function mostrarCelda(clave, valor) {
                if (valor === null || valor === undefined) return '';
                const s = String(valor);
                if (/fecha|vencimiento/i.test(clave) && /^\d{4}-\d{2}-\d{2}/.test(s)) {
                    const [a, m, d] = s.slice(0, 10).split('-');
                    return `${d}/${m}/${a}`;
                }
                if (typeof valor === 'number' && /monto|saldo|capital|interes|recaud|cuota|pagado|comision|valor|totalfinanciado/i.test(clave)
                    && !/cantidad|numero|id|dias|plazo|porcentaje/i.test(clave)) {
                    return 'Q ' + valor.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                }
                return s;
            }
            
            $('generar').addEventListener('click', async () => {$('generar').disabled = true;
                $('csv').disabled = true;
                $('estado').textContent = 'Consultando SQL Server...';
                
                const parametros = new URLSearchParams();
                ['inicio', 'fin', 'fechaCorte', 'minDias', 'mes', 'idCliente', 'numeroCredito'].forEach(id => {
                    if ($(id).value.trim()) parametros.set(id,$(id).value.trim());
                });
                
                try {
                    const r = await fetch('/api/reportes/' + $('reporte').value + '?' + parametros.toString(), { cache: 'no-store' });
                    const data = await r.json();
                    if (!r.ok) throw Error(data.mensaje || 'Error al consultar.');
                    
                    filasActuales = Array.isArray(data) ? data : [];
                    const cont = $('tabla');
                    cont.replaceChildren();
                    
                    if (!filasActuales.length) {
                        const p = document.createElement('p');
                        p.textContent = 'Sin resultados para los filtros seleccionados.';
                        cont.append(p);
                    } else {
                        const keys = Object.keys(filasActuales[0]);
                        const table = document.createElement('table');
                        const head = document.createElement('thead');
                        const tr = document.createElement('tr');
                        
                        keys.forEach(k => {
                            const th = document.createElement('th');
                            th.textContent = k;
                            tr.append(th);
                        });
                        head.append(tr);
                        table.append(head);
                        
                        const tbody = document.createElement('tbody');
                        filasActuales.forEach(f => {
                            const tr = document.createElement('tr');
                            keys.forEach(k => {
                                const td = document.createElement('td');
                                td.textContent = mostrarCelda(k, f[k]);
                                tr.append(td);
                            });
                            tbody.append(tr);
                        });
                        table.append(tbody);
                        cont.append(table);
                        $('csv').disabled = false;
                    }
                    $('estado').textContent = filasActuales.length + ' registro(s).';
                } catch (e) {
                    filasActuales = [];
                    $('tabla').textContent = e.message;
                    $('estado').textContent = 'Error.';
                } finally {
                    $('generar').disabled = false;
                }
            });
            
            $('csv').addEventListener('click', () => {
                if (!filasActuales.length) return;
                const keys = Object.keys(filasActuales[0]);
                const cell = v => '"' + formatear(v).replace(/"/g, '""') + '"';
                const lines = [keys.map(cell).join(',')].concat(filasActuales.map(f => keys.map(k => cell(f[k])).join(',')));
                const blob = new Blob(['\ufeff' + lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'MAGIS_AUTO_reporte_' + $('reporte').value + '.csv';
                a.click();
                URL.revokeObjectURL(url);
            });
