window.P4C_WMS_VERSION = "P4C-WMS-V1.0";
function previewFiles(input){ const grid=document.getElementById('previewGrid'); if(!grid) return; grid.innerHTML=''; [...input.files].forEach(f=>{ const img=document.createElement('img'); img.src=URL.createObjectURL(f); img.style.maxWidth='180px'; img.style.margin='8px'; grid.appendChild(img); }); }
