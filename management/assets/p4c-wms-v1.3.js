let K={pages:[],columns:['In Process','Review','Staging','Deployed']};const $=s=>document.querySelector(s);function esc(s){return(s||'').toString().replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));}async function load(){try{let r=await fetch('../data/web-page-kanban.json?'+Date.now());K=await r.json()}catch(e){try{let r=await fetch('data/web-page-kanban.json?'+Date.now());K=await r.json()}catch(x){}}renderKanban();}function renderKanban(){let n=$('#pageNames'),b=$('#board');if(!n||!b)return;n.innerHTML='';b.innerHTML='';K.pages.sort((a,b)=>a.order-b.order).forEach(p=>{n.insertAdjacentHTML('beforeend','<div class="page-name"><div class="code">'+esc(p.CodeID)+'</div><b>'+esc(p.pageName)+'</b><div class="mini">'+esc(p.stage)+' · '+esc(p.fileName)+'</div></div>')});K.columns.forEach(c=>{let col=document.createElement('section');col.className='col';col.innerHTML='<h2>'+esc(c)+'</h2>';K.pages.filter(p=>p.status===c).sort((a,b)=>a.order-b.order).forEach(p=>{col.insertAdjacentHTML('beforeend','<div class="ticket"><div class="code">'+esc(p.CodeID)+'</div><b>'+esc(p.pageName)+'</b><div class="mini">'+esc(p.route)+'</div><div class="stage">'+esc(p.stage)+'</div><p>'+esc(p.description)+'</p></div>')});b.appendChild(col)});}function buildCommand(action){let code=$('#codeid').value,name=$('#pagename').value,route=$('#route').value,file=$('#filename').value,prompt=$('#promptfolder').value,status=$('#status').value,desc=$('#description').value;let cmd='cd "M:\Mi unidad\Pro4Chem-Web-Ai\WMS"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\P4C-WMS-V1.3-Web-Page-Kanban-Admin.ps1 `
  -Action "'+action+'" `
  -CodeID "'+code+'" `
  -PageName "'+name+'" `
  -Route "'+route+'" `
  -FileName "'+file+'" `
  -PromptFolder "'+prompt+'" `
  -Status "'+status+'" `
  -Description "'+desc.replace(/"/g,"'")+'"';$('#cmd').value=cmd;}document.addEventListener('DOMContentLoaded',load);
