(function(){
  function closeDrawer(){
    var drawer = document.getElementById('navDrawer');
    if(drawer) drawer.classList.remove('open');
  }

  function openDrawer(){
    var drawer = document.getElementById('navDrawer');
    if(drawer) drawer.classList.add('open');
  }

  function markActiveLinks(){
    var current = window.location.pathname.replace(/\/$/, '/index.html');
    document.querySelectorAll('.header-bar a[href], .nav-drawer a[href], footer a[href]').forEach(function(anchor){
      try {
        var url = new URL(anchor.getAttribute('href'), window.location.href);
        var target = url.pathname.replace(/\/$/, '/index.html');
        if(target === current) anchor.classList.add('active');
      } catch (error) {
        return;
      }
    });
  }

  function wireDrawer(){
    document.querySelectorAll('[data-nav-open]').forEach(function(button){
      button.addEventListener('click', openDrawer);
    });
    document.querySelectorAll('[data-nav-close]').forEach(function(button){
      button.addEventListener('click', closeDrawer);
    });
    document.querySelectorAll('#navDrawer a[href]').forEach(function(anchor){
      anchor.addEventListener('click', closeDrawer);
    });
    document.addEventListener('keydown', function(event){
      if(event.key === 'Escape') closeDrawer();
      if(event.key === '/' && document.activeElement && !['INPUT', 'TEXTAREA', 'SELECT'].includes(document.activeElement.tagName)){
        var search = document.querySelector('.nav-search, .drawer-search');
        if(search){
          event.preventDefault();
          search.click();
        }
      }
    });
  }

  document.addEventListener('DOMContentLoaded', function(){
    wireDrawer();
    markActiveLinks();
  });
})();
