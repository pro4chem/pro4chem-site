(function(){
  const TRANSLATIONS = {
    en: {
      'nav.home':'Home',
      'nav.products':'Portfolio',
      'nav.markets':'Markets',
      'nav.technology':'Technology',
      'nav.about':'About',
      'nav.contact':'Contact'
    },
    es: {
      'nav.home':'Inicio',
      'nav.products':'Portafolio',
      'nav.markets':'Mercados',
      'nav.technology':'Tecnologia',
      'nav.about':'Acerca de',
      'nav.contact':'Contacto'
    }
  };

  function currentLanguage(){
    return localStorage.getItem('p4c-lang') || 'en';
  }

  function applyDataLanguage(lang){
    document.documentElement.lang = lang;
    document.querySelectorAll('[data-en][data-es]').forEach(el => {
      const value = el.getAttribute(`data-${lang}`);
      if(value !== null) el.textContent = value;
    });

    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      const value = TRANSLATIONS[lang] && TRANSLATIONS[lang][key];
      if(value) el.textContent = value;
    });

    document.querySelectorAll('[data-i18n-attr]').forEach(el => {
      const pairs = el.getAttribute('data-i18n-attr').split(',');
      pairs.forEach(pair => {
        const parts = pair.split(':');
        const attr = parts[0] && parts[0].trim();
        const key = parts[1] && parts[1].trim();
        const value = TRANSLATIONS[lang] && TRANSLATIONS[lang][key];
        if(attr && value) el.setAttribute(attr, value);
      });
    });

    document.querySelectorAll('.en,.es').forEach(el => {
      el.hidden = !el.classList.contains(lang);
    });
  }

  window.setLanguage = function(lang){
    const next = lang === 'es' ? 'es' : 'en';
    localStorage.setItem('p4c-lang', next);
    applyDataLanguage(next);
  };

  window.toggleLanguage = function(){
    window.setLanguage(currentLanguage() === 'en' ? 'es' : 'en');
  };

  document.addEventListener('DOMContentLoaded', () => applyDataLanguage(currentLanguage()));
})();
