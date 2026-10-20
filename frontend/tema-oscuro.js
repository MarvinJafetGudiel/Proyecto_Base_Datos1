(() => {
    'use strict';
    const enlaces = [
        ['index.html', 'Panel principal', 'home'],
        ['clientes.html', 'Clientes', 'users'],
        ['vehiculos.html', 'Vehículos', 'car'],
        ['creditos.html', 'Créditos y financiamiento', 'credit'],
        ['nuevoCredito.html', 'Nuevo financiamiento', 'plus'],
        ['cuotas.html', 'Cuotas y pagos', 'calendar'],
        ['registroPago.html', 'Registrar pago', 'wallet'],
        ['gestion.html', 'Garantías y comisiones', 'shield'],
        ['reportes.html', 'Reportes financieros', 'chart']
    ];
    
    const dibujos = {
        home: '<path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1z"/>',
        users: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
        car: '<path d="m5 17-1 3v1h3l1-2h8l1 2h3v-1l-1-3-1.6-8a2 2 0 0 0-2-1.6H8.6a2 2 0 0 0-2 1.6z"/><path d="M5 17h14M6 13h12M4 17H2m18 0h2"/><circle cx="7" cy="16" r="1"/><circle cx="17" cy="16" r="1"/>',
        credit: '<rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20M6 15h4"/>',
        plus: '<path d="M12 5v14M5 12h14" stroke-width="2.5"/>',
        calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18M8 15h3"/>',
        wallet: '<rect x="3" y="6" width="18" height="15" rx="2"/><path d="M3 10h18M16 15h5M6 3h13"/>',
        shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/><path d="m9 12 2 2 4-4"/>',
        chart: '<path d="M4 20V11M10 20V5M16 20v-9M22 20V2" stroke-width="3"/>',
        menu: '<path d="M4 7h16M4 12h16M4 17h16"/>',
        carlogo: '<path d="M4 15 6 9l3-3h6l3 3 2 6v4h-2l-1-2H7l-1 2H4zM5 14h14M9 6l-2 6h10l-2-6"/><circle cx="7" cy="15" r="1"/><circle cx="17" cy="15" r="1"/>'
    };

    function icono(nombre, tamano = 22) {
        return `<svg xmlns="http://www.w3.org/2000/svg" width="${tamano}" height="${tamano}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${dibujos[nombre] || dibujos.home}</svg>`;
    }

    function iniciar() {
        const pagina = location.pathname.split('/').pop() || 'index.html';
        let aside = document.querySelector('.contenedor > aside, .layout > aside');
        let principal = document.querySelector('.contenedor > main, .layout > main');
        
        if (!aside || !principal) {
            const original = document.querySelector('body > main');
            if (!original) return;
            document.body.classList.add('magis-credit-page');
            const contenedor = document.createElement('div');
            contenedor.className = 'contenedor';
            aside = document.createElement('aside');
            aside.className = 'menu';
            document.body.insertBefore(contenedor, original);
            contenedor.append(aside, original);
            original.classList.add('principal');
            principal = original;
        }
        
        aside.classList.add('menu');
        principal.classList.add('principal');
        const titulo = enlaces.find(x => x[0] === pagina)?.[1] || 'Panel principal';
        
        aside.innerHTML = `
            <div class="magis-brand"><span class="magis-brand-icon">${icono('carlogo', 29)}</span><div><strong>MAGIS<span>-AUTO</span></strong><small>SISTEMA DE FINANCIAMIENTO</small></div></div>
            <div class="magis-nav-label">NAVEGACIÓN PRINCIPAL</div>
            <nav class="magis-links" aria-label="Secciones de MAGIS-AUTO">${enlaces.map(([url, texto, icon]) => `<a href="${url}" ${url === pagina ? 'class="activo" aria-current="page"' : ''}>${icono(icon, 19)}<span>${texto}</span></a>`).join('')}</nav>
            <div class="magis-promo"><strong>MAGIS-AUTO</strong><p>Financiamientos bajo control, en un solo lugar.</p>${icono('carlogo', 100)}</div>
            <div class="magis-side-foot">Panel de administración · Guatemala</div>`;
        
        const topbar = document.createElement('div');
        topbar.className = 'magis-topbar';
        topbar.innerHTML = `<div class="magis-top-left"><button type="button" class="magis-mobile-btn" aria-label="Abrir menú" aria-expanded="false">${icono('menu', 20)}</button>${icono('shield', 20)}<strong>${titulo}</strong></div><div class="magis-top-right"><span class="magis-status-dot"></span><span class="magis-status-label">Panel administrativo</span><span class="magis-avatar" title="MAGIS-AUTO">M</span></div>`;
        principal.insertBefore(topbar, principal.firstChild);
        
        const boton = topbar.querySelector('.magis-mobile-btn');
        const overlay = document.createElement('div');
        overlay.className = 'magis-menu-overlay';
        document.body.appendChild(overlay);
        
        function cerrar() {
            document.body.classList.remove('magis-menu-open');
            boton.setAttribute('aria-expanded', 'false');
        }
        
        boton.addEventListener('click', () => {
            const abierto = document.body.classList.toggle('magis-menu-open');
            boton.setAttribute('aria-expanded', String(abierto));
        });
        
        overlay.addEventListener('click', cerrar);
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') cerrar();
        });
        
        const h1 = principal.querySelector(':scope > h1');
        const encabezado = principal.querySelector(':scope > .encabezado');
        const primerElemento = h1 || encabezado;
        
        if (primerElemento) {
            const hero = document.createElement('div');
            hero.className = 'magis-hero';
            const eyebrow = document.createElement('div');
            eyebrow.className = 'magis-eyebrow';
            eyebrow.textContent = 'MAGIS-AUTO  /  GESTIÓN FINANCIERA';
            hero.appendChild(eyebrow);
            primerElemento.before(hero);
            hero.appendChild(primerElemento);
            
            const siguiente = hero.nextElementSibling;
            if (siguiente && siguiente.tagName === 'P') hero.appendChild(siguiente);
        } else if (pagina === 'nuevoCredito.html') {
            const hero = document.createElement('div');
            hero.className = 'magis-hero';
            hero.innerHTML = '<div class="magis-eyebrow">MAGIS-AUTO / GESTIÓN FINANCIERA</div><h1>Nuevo financiamiento</h1><p>Registra créditos, genera cuotas y consulta las condiciones del préstamo.</p>';
            topbar.after(hero);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();