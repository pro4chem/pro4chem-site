(function(){
  function markFooterReady(){
    document.querySelectorAll('footer').forEach(function(footer){
      footer.setAttribute('data-p4c-footer-runtime', 'ready');
    });
  }

  document.addEventListener('DOMContentLoaded', markFooterReady);
})();
