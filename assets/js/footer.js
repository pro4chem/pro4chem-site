(function(){
  function footerHtml(){
    return `<footer class="site-footer" data-p4c-footer="v2.2">
      <div>
        <strong>Pro4Chem Specialty Resins</strong>
        <p data-en="Miami, FL - Heredia, Costa Rica - sales@pro4chem.com - www.pro4chem.com" data-es="Miami, FL - Heredia, Costa Rica - sales@pro4chem.com - www.pro4chem.com">Miami, FL - Heredia, Costa Rica - sales@pro4chem.com - www.pro4chem.com</p>
      </div>
      <nav aria-label="Footer navigation">
        <a href="/portfolio.html" data-en="Portfolio" data-es="Portafolio">Portfolio</a>
        <a href="/technology.html" data-en="Technology" data-es="Tecnologia">Technology</a>
        <a href="/markets.html" data-en="Markets" data-es="Mercados">Markets</a>
        <a href="/contact.html" data-en="Contact Us" data-es="Contactenos">Contact Us</a>
      </nav>
      <button class="lang-toggle" type="button" onclick="toggleLanguage()" data-en="EN / ES" data-es="ES / EN">EN / ES</button>
    </footer>`;
  }

  function injectFooter(){
    const target = document.getElementById('footer-container') || document.querySelector('[data-p4c-footer-container]');
    if(target) target.innerHTML = footerHtml();
  }

  document.addEventListener('DOMContentLoaded', injectFooter);
})();
