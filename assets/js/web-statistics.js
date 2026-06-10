(function(){
  const stats = {
    version: 'P4C-WEB-STATS-V2.2',
    provider: 'Cloudflare Web Analytics',
    beaconTokenConfigured: false,
    runtime: 'static-safe',
    loadedAt: new Date().toISOString()
  };

  window.P4C_WEB_STATS = Object.assign({}, window.P4C_WEB_STATS || {}, stats);

  document.addEventListener('DOMContentLoaded', () => {
    document.documentElement.setAttribute('data-p4c-web-statistics', 'loaded');
  });
})();
