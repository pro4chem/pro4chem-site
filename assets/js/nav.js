(function(){
  const links = [
    { href: '/index.html', key: 'nav.home', en: 'Home', es: 'Inicio' },
    { href: '/portfolio.html', key: 'nav.products', en: 'Portfolio', es: 'Portafolio' },
    { href: '/technology.html', key: 'nav.technology', en: 'Technology', es: 'Tecnologia' },
    { href: '/markets.html', key: 'nav.markets', en: 'Markets', es: 'Mercados' },
    { href: '/about.html', key: 'nav.about', en: 'About', es: 'Acerca de' },
    { href: '/contact.html', key: 'nav.contact', en: 'Contact', es: 'Contacto' }
  ];

  function navHtml(){
    const items = links.map(link => {
      return `<a href="${link.href}" data-i18n="${link.key}" data-en="${link.en}" data-es="${link.es}">${link.en}</a>`;
    }).join('');
    return `<header class="site-header" data-p4c-nav="v2.2">
      <a class="site-brand" href="/index.html" aria-label="Pro4Chem home">
        <img src="/public/images/core/logo-transparent.webp" alt="Pro4Chem" width="140" height="40" loading="eager">
        <span>Pro4Chem</span>
      </a>
      <nav aria-label="Primary navigation">${items}</nav>
      <button class="lang-toggle" type="button" onclick="toggleLanguage()" data-en="EN / ES" data-es="ES / EN">EN / ES</button>
    </header>`;
  }

  function injectHeader(){
    const target = document.getElementById('header-container') || document.querySelector('[data-p4c-header]');
    if(target) target.innerHTML = navHtml();

    const path = window.location.pathname.replace(/\/$/, '/index.html');
    document.querySelectorAll('.site-header a[href]').forEach(anchor => {
      const href = anchor.getAttribute('href');
      if(href && path.endsWith(href.replace(/^\//,''))) anchor.classList.add('active');
    });
  }

  document.addEventListener('DOMContentLoaded', injectHeader);
})();
