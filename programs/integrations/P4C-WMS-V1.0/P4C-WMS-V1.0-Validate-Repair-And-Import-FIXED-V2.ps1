# P4C-WMS-V1.0-Validate-Repair-And-Import-FIXED-V2.ps1
<#
FIXED V2
Corrige el error:
  Export-Csv : No se puede anexar contenido CSV ... columna: catalogVersion

Causa:
  El archivo existente logs\image-import-log.csv fue creado por una versión anterior con una columna llamada catalogVersion.
  La versión FIXED generaba filas con platformVersion, pero al usar -Append PowerShell exige que todas las columnas coincidan.

Solución V2:
  - Todas las filas de importación incluyen AMBAS columnas: catalogVersion y platformVersion.
  - Se agrega función Export-P4CCsvSafe para anexar CSV de forma segura.
  - Si el CSV existente tiene columnas incompatibles, se archiva automáticamente con timestamp y se crea uno nuevo.
  - También se usa -Force cuando se anexa para tolerar columnas adicionales.
  - Mantiene la corrección anterior para omitir .gdoc/.gsheet/.gslides y otros accesos directos de Google Drive.
  - Crea todas las carpetas base antes de copiar.
  - No despliega a GitHub ni Cloudflare.
#>
param(
    [string]$SiteRoot = "M:\Mi unidad\devweb\pro4chem-site",
    [string]$DevRoot = "M:\Mi unidad\devweb\pro4chem-dev",
    [string]$SourceImages = "M:\Mi unidad\Pro4Chem-Web-Ai\Images\v21\Images",
    [switch]$OverwriteImages = $false,
    [switch]$RunGitStatus = $true
)
$ErrorActionPreference = "Stop"
$PlatformVersion = "P4C-WMS-V1.0"
$CatalogVersion = "P4C-WMS-V1.0"

$RequiredDirs = @(
    "$SiteRoot\management",
    "$SiteRoot\management\pages",
    "$SiteRoot\management\assets",
    "$SiteRoot\assets",
    "$SiteRoot\assets\css",
    "$SiteRoot\assets\js",
    "$SiteRoot\public",
    "$SiteRoot\public\images",
    "$SiteRoot\public\images\core",
    "$SiteRoot\public\images\v21",
    "$SiteRoot\public\images\v21\all",
    "$SiteRoot\public\images\future",
    "$SiteRoot\public\images\staging",
    "$SiteRoot\public\images\marketing",
    "$SiteRoot\public\images\marketing\monthly",
    "$SiteRoot\config",
    "$SiteRoot\logs",
    "$SiteRoot\programs",
    "$SiteRoot\programs\integrations",
    "$SiteRoot\programs\integrations\P4C-WMS-V1.0",
    "$SiteRoot\reports",
    "$SiteRoot\reports\wms-validation",
    "$DevRoot\public",
    "$DevRoot\public\images",
    "$DevRoot\public\images\incoming",
    "$DevRoot\public\images\incoming\v21",
    "$DevRoot\generated",
    "$DevRoot\generated\drafts",
    "$DevRoot\generated\drafts\stage1",
    "$DevRoot\generated\drafts\stage3",
    "$DevRoot\approved-dev",
    "$DevRoot\logs"
)
foreach($d in $RequiredDirs){ New-Item -ItemType Directory -Force -Path $d | Out-Null }

$SkipExtensions = @('.gdoc','.gsheet','.gslides','.gform','.gdraw','.gmap','.shortcut','.tmp')
$SkipNames = @('desktop.ini','thumbs.db','.ds_store')
$CopyLog = New-Object System.Collections.Generic.List[object]

function Export-P4CCsvSafe {
    param(
        [Parameter(Mandatory=$true)]$Rows,
        [Parameter(Mandatory=$true)][string]$Path
    )
    $parent = Split-Path $Path -Parent
    if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    if(!(Test-Path -LiteralPath $Path)){
        $Rows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
        return
    }
    try {
        $existingHeader = (Get-Content -LiteralPath $Path -TotalCount 1 -ErrorAction Stop)
        $newHeader = (($Rows | Select-Object -First 1 | ConvertTo-Csv -NoTypeInformation)[0])
        if($existingHeader -ne $newHeader){
            $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $archive = [System.IO.Path]::Combine($parent, ([System.IO.Path]::GetFileNameWithoutExtension($Path) + "-archive-$stamp.csv"))
            Move-Item -LiteralPath $Path -Destination $archive -Force
            $Rows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
            return
        }
        $Rows | Export-Csv -Path $Path -NoTypeInformation -Append -Encoding UTF8 -Force
    } catch {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $fallback = [System.IO.Path]::Combine($parent, ([System.IO.Path]::GetFileNameWithoutExtension($Path) + "-rewrite-$stamp.csv"))
        if(Test-Path -LiteralPath $Path){ Move-Item -LiteralPath $Path -Destination $fallback -Force }
        $Rows | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
    }
}

function Add-CopyLog {
    param($FileName,$Source,$Destination,$Action,$Reason)
    $CopyLog.Add([pscustomobject]@{
        timestamp = (Get-Date).ToString('s')
        catalogVersion = $CatalogVersion
        platformVersion = $PlatformVersion
        fileName = $FileName
        source = $Source
        destination = $Destination
        action = $Action
        reason = $Reason
    }) | Out-Null
}

function Copy-P4CAssetSafe {
    param(
        [Parameter(Mandatory=$true)][string]$SourcePath,
        [Parameter(Mandatory=$true)][string]$DestinationPath,
        [switch]$Overwrite
    )
    $fileName = Split-Path $SourcePath -Leaf
    $ext = [System.IO.Path]::GetExtension($fileName).ToLowerInvariant()
    if($SkipExtensions -contains $ext -or $SkipNames -contains $fileName.ToLowerInvariant()){
        Add-CopyLog $fileName $SourcePath $DestinationPath 'SKIPPED' "Google Workspace shortcut/metadata or system file"
        return $false
    }
    if(!(Test-Path -LiteralPath $SourcePath -PathType Leaf)){
        Add-CopyLog $fileName $SourcePath $DestinationPath 'SKIPPED' "Source file is not a local leaf file or is unavailable"
        return $false
    }
    $parent = Split-Path $DestinationPath -Parent
    if(!(Test-Path -LiteralPath $parent)){ New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    if((Test-Path -LiteralPath $DestinationPath) -and -not $Overwrite){
        Add-CopyLog $fileName $SourcePath $DestinationPath 'SKIPPED_EXISTS' "Destination already exists; use -OverwriteImages to replace"
        return $true
    }
    try {
        Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force:$Overwrite -ErrorAction Stop
        Add-CopyLog $fileName $SourcePath $DestinationPath 'COPIED' "Copied successfully"
        return $true
    } catch {
        Add-CopyLog $fileName $SourcePath $DestinationPath 'FAILED' $_.Exception.Message
        return $false
    }
}

# Create/repair WMS assets
$CssPath = "$SiteRoot\management\assets\p4c-wms.css"
@'
:root{--bg:#050C1A;--panel:#0C1E3A;--cyan:#00D4FF;--text:rgba(255,255,255,.86);--muted:rgba(255,255,255,.62);--bd:rgba(0,212,255,.25);--mono:Consolas,monospace;--font:Segoe UI,system-ui}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font-family:var(--font);display:flex;line-height:1.6}.side{width:300px;min-height:100vh;position:fixed;left:0;top:0;background:#07111F;border-right:1px solid var(--bd);padding:22px}.side h1{font-size:15px;color:var(--cyan);font-family:var(--mono)}.side a{display:block;color:var(--muted);padding:8px 10px;text-decoration:none;border-left:2px solid transparent}.side a:hover{color:var(--cyan);border-left-color:var(--cyan);background:rgba(0,212,255,.08)}main{margin-left:320px;padding:32px;max-width:1300px}.badge{display:inline-block;border:1px solid var(--bd);border-radius:999px;color:var(--cyan);padding:4px 10px;font-family:var(--mono);font-size:11px}.card{background:var(--panel);border:1px solid var(--bd);border-radius:16px;padding:18px;margin:14px 0}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:14px}code{color:var(--cyan);font-family:var(--mono)}
'@ | Set-Content -Path $CssPath -Encoding UTF8

$JsPath = "$SiteRoot\management\assets\p4c-wms.js"
@'
window.P4C_WMS_VERSION = "P4C-WMS-V1.0";
function previewFiles(input){ const grid=document.getElementById('previewGrid'); if(!grid) return; grid.innerHTML=''; [...input.files].forEach(f=>{ const img=document.createElement('img'); img.src=URL.createObjectURL(f); img.style.maxWidth='180px'; img.style.margin='8px'; grid.appendChild(img); }); }
'@ | Set-Content -Path $JsPath -Encoding UTF8

$MgmtIndex = "$SiteRoot\management\index.html"
@'
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Pro4Chem AI Web Management System — P4C-WMS-V1.0</title><link rel="stylesheet" href="assets/p4c-wms.css"></head><body><aside class="side"><h1>PRO4CHEM<br>P4C-WMS-V1.0</h1><a href="index.html">Dashboard</a><a href="pages/page-factory.html">Page Factory</a><a href="pages/prompt-lab.html">Prompt Lab</a><a href="pages/stage1-review.html">Stage 1 Review</a><a href="pages/stage3-review.html">Stage 3 Review</a><a href="pages/website-graphics-review.html">Graphics Review</a><a href="pages/image-catalog.html">Image Catalog</a><a href="pages/cli-authentication.html">CLI Authentication</a><a href="pages/release-gates.html">Release Gates</a><a href="pages/deploy.html">Deploy</a></aside><main><span class="badge">P4C-WMS-V1.0</span><h1>Pro4Chem AI Web Management System</h1><p>First operational Web Management System platform version. Use this dashboard to create page versions, review locally, manage images, and prepare approved files for staging.</p><div class="grid"><div class="card"><h2>Stage 1</h2><p>Homepage creation/review: hero, pillars, technology platforms, Series 3000 VeloXyl focus, R&D services, CTA.</p></div><div class="card"><h2>Stage 3</h2><p>Expansion page creation/review: market pages, product-series pages, service pages, product finder schema readiness.</p></div><div class="card"><h2>Images</h2><p>Use <code>config/image-catalog-p4c-wms-v1.0.json</code> and assets from <code>public/images/core</code>.</p></div><div class="card"><h2>Deployment Status</h2><p>Core scripts executed. Deployment remains pending until staging and main promotion.</p></div></div></main><script src="assets/p4c-wms.js"></script></body></html>
'@ | Set-Content -Path $MgmtIndex -Encoding UTF8

function New-Page($Name,$Title,$Body){
    $path = "$SiteRoot\management\pages\$Name.html"
    @"
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>$Title — P4C-WMS-V1.0</title><link rel="stylesheet" href="../assets/p4c-wms.css"></head><body><aside class="side"><h1>PRO4CHEM<br>P4C-WMS-V1.0</h1><a href="../index.html">Dashboard</a><a href="page-factory.html">Page Factory</a><a href="prompt-lab.html">Prompt Lab</a><a href="stage1-review.html">Stage 1 Review</a><a href="stage3-review.html">Stage 3 Review</a><a href="website-graphics-review.html">Graphics Review</a><a href="image-catalog.html">Image Catalog</a><a href="cli-authentication.html">CLI Authentication</a><a href="release-gates.html">Release Gates</a><a href="deploy.html">Deploy</a></aside><main><span class="badge">P4C-WMS-V1.0</span><h1>$Title</h1>$Body</main><script src="../assets/p4c-wms.js"></script></body></html>
"@ | Set-Content -Path $path -Encoding UTF8
}
New-Page "page-factory" "Page Factory" "<div class='card'>Create new page versions using local assets from <code>public/images/core</code> and catalog metadata.</div>"
New-Page "prompt-lab" "Prompt Lab" "<div class='card'>Store and test Stage 1 and Stage 3 prompts before local approval.</div>"
New-Page "stage1-review" "Stage 1 Web Page Creation Review" "<div class='card'>Focus: homepage creation and review. Required sections: hero, ticker, strategic pillars, technologies, Series 3000 product cards, Green Bridge, R&D teaser, contact CTA.</div>"
New-Page "stage3-review" "Stage 3 Web Page Creation Review" "<div class='card'>Focus: future expansion pages. Required groups: market sub-pages, product-series pages, R&D service pages, SEO schema, and product finder routing.</div>"
New-Page "website-graphics-review" "Website Graphics Review" "<div class='card'><input type='file' accept='image/webp,image/png,image/jpeg' multiple onchange='previewFiles(this)'><div id='previewGrid'></div></div>"
New-Page "image-catalog" "Image Catalog" "<div class='card'>Catalog file: <code>../../config/image-catalog-p4c-wms-v1.0.json</code>. Use it to select images for page creation.</div>"
New-Page "cli-authentication" "CLI Authentication" "<div class='card'><h2>Qwen CLI</h2><p>Run <code>qwen auth</code> or <code>qwen</code> then <code>/auth</code>. Use your approved provider method.</p></div><div class='card'><h2>Antigravity CLI</h2><p>Run <code>agy</code>. Use browser/keyring login or SSH URL/code flow where applicable.</p></div><div class='card'><h2>Claude CLI</h2><p>Run <code>claude</code> or <code>claude auth login</code>. Use browser sign-in or API/provider configuration where applicable.</p></div>"
New-Page "release-gates" "Release Gates" "<div class='card'>Only locally approved packages can promote to staging. Main remains functional and changes flow staging to main by pull request.</div>"
New-Page "deploy" "Deploy" "<div class='card'>Deployment is pending. Use staging validation before main production deployment.</div>"

$Catalog = @(
    [pscustomobject]@{fileName="homepage_paradigm_shift_hero.webp"; ratio="16:9"; section="Homepage"; status="CREATED"; priority="HIGH"; description="Female senior R&D chemist in dark premium lab at glass molecular design whiteboard; AI neural-network chemistry monitors; cyan task lighting; Pro4Chem logo integrated."}
    [pscustomobject]@{fileName="green_bridge_homepage.webp"; ratio="16:9"; section="Homepage"; status="CREATED"; priority="HIGH"; description="Split-scene technology migration: legacy solvent drums on left, modern waterborne lab on right; male industrial formulator; cyan-lit dispersions."}
    [pscustomobject]@{fileName="ai_dfss_research_team.webp"; ratio="16:9"; section="About"; status="NEW"; priority=""; description="AI-driven chemical research lab; female AI formulation scientist interacting with curved neural-network optimization monitor; cyan glow."}
    [pscustomobject]@{fileName="quality_testing_certification.webp"; ratio="16:9"; section="About"; status="NEW"; priority=""; description="Quality testing lab; male senior quality engineer validating glossy test panels; gloss meter shows 97 GU."}
    [pscustomobject]@{fileName="biosustainability_pillar.webp"; ratio="16:9"; section="About"; status="CREATED"; priority=""; description="Sustainable chemistry lab; female sustainability chemist examining waterbased biobased polymer dispersion; emerald green accent and molecular ring overlay."}
    [pscustomobject]@{fileName="ferraxyl_landing_header.webp"; ratio="16:9"; section="Series 3000 VeloXyl"; status="CREATED"; priority="HIGH"; description="Industrial bridge maintenance engineer spraying steel beam; rust transitions to clean high-gloss black surface; cyan passivation glow; FerraXyl text."}
    [pscustomobject]@{fileName="xeloxyl_landing_header.webp"; ratio="16:9"; section="Series 3000 VeloXyl"; status="CREATED"; priority="HIGH"; description="Wood coating spray booth; female technician applying clear sealer to furniture panels; mirror finish; XeloXyl text."}
    [pscustomobject]@{fileName="luxyl_landing_header.webp"; ratio="16:9"; section="Series 3000 VeloXyl"; status="CREATED"; priority="HIGH"; description="Coastal industrial site; male inspector examining glossy steel with water beading; LuXyl text and cyan ambient glow."}
    [pscustomobject]@{fileName="xeloxyl_vs_nitrocellulose.webp"; ratio="16:9"; section="Series 3000 VeloXyl"; status="NEW"; priority=""; description="Split comparison in QA lab: yellowed nitrocellulose panel vs water-white XeloXyl mirror panel."}
    [pscustomobject]@{fileName="heliozol_landing_header.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Advanced waterborne chemical lab; female chemist before crystal-clear surfactant-free dispersions; HelioZol text."}
    [pscustomobject]@{fileName="ferrazol_series_card.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Waterborne coatings applicator spraying industrial piping; zero foam and fast water resistance; cyan accent surfaces."}
    [pscustomobject]@{fileName="xelozol_series_card.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Furniture finishing specialist applying 2K hybrid clear topcoat to hardwood; water-white clarity."}
    [pscustomobject]@{fileName="tectazol_series_card.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Commercial flat roof; architectural contractor applying white elastomeric cool roof coating with roller."}
    [pscustomobject]@{fileName="oleozol_series_card.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Application test lab; decorative paint formulator comparing waterborne hybrid alkyd with solvent alkyd finish."}
    [pscustomobject]@{fileName="luxzol_series_card.webp"; ratio="16:9"; section="Series 6000 HelioZol"; status="NEW"; priority=""; description="Automotive spray booth; painter applying high-DOI clearcoat to fleet vehicle; mirror finish."}
    [pscustomobject]@{fileName="rd_services_secure_ai.webp"; ratio="16:9"; section="Advanced R&D Services"; status="NEW"; priority=""; description="Secure lab/server room hybrid; senior data scientist at isolated ChemNeural AI terminal; cyan and amber IP-security lighting."}
    [pscustomobject]@{fileName="cognichem_lab_header.webp"; ratio="16:9"; section="Advanced R&D Services"; status="NEW"; priority=""; description="Elite R&D partnership lab; male and female chemist duo collaborating over bespoke formulations; CogniChem text."}
    [pscustomobject]@{fileName="amberxyl_series_card.webp"; ratio="16:9"; section="Remaining Portfolio"; status="CREATED"; priority=""; description="AmberXyl Series 2000; aspirational residential DIY image prompt already created."}
    [pscustomobject]@{fileName="coalezol_series_card.webp"; ratio="16:9"; section="Remaining Portfolio"; status="NEW"; priority=""; description="CoaleZol Series 7000; female scientist at scrub resistance testing machine demonstrating zero-VOC film integration."}
    [pscustomobject]@{fileName="synerxyl_series_card.webp"; ratio="16:9"; section="Remaining Portfolio"; status="NEW"; priority=""; description="SynerXyl Series 8000; specialist at high-shear disperser reading a Hegman gauge."}
    [pscustomobject]@{fileName="natuzol_series_card.webp"; ratio="16:9"; section="Remaining Portfolio"; status="NEW"; priority=""; description="NatuZol Series 9000; female chemist evaluating biobased skin polymer on forearm patch."}
    [pscustomobject]@{fileName="purizol_series_card.webp"; ratio="16:9"; section="Remaining Portfolio"; status="NEW"; priority=""; description="PuriZol Series 10000; female operator monitoring municipal water clarifier."}
    [pscustomobject]@{fileName="emulsacore_tech_icon.webp"; ratio="1:1"; section="Tech Icons"; status="NEW"; priority=""; description="Macro shot: gloved hands pouring water into clear resin vessel; zero foam/cloudiness; concentric ring overlay."}
    [pscustomobject]@{fileName="xylocore_tech_icon.webp"; ratio="1:1"; section="Tech Icons"; status="NEW"; priority=""; description="Macro shot: technician sanding coated wood panel; fine white dust; cyan accent lighting."}
)
$AllImageTarget = "$SiteRoot\public\images\v21\all"
$CoreTarget = "$SiteRoot\public\images\core"
$FutureTarget = "$SiteRoot\public\images\future"
$DevIncoming = "$DevRoot\public\images\incoming\v21"

# Copy all real/local files from source to all/future/dev incoming folders.
if(Test-Path -LiteralPath $SourceImages){
    Get-ChildItem -LiteralPath $SourceImages -File -Force | ForEach-Object {
        $name = $_.Name
        Copy-P4CAssetSafe -SourcePath $_.FullName -DestinationPath (Join-Path $AllImageTarget $name) -Overwrite:$OverwriteImages | Out-Null
        Copy-P4CAssetSafe -SourcePath $_.FullName -DestinationPath (Join-Path $FutureTarget $name) -Overwrite:$OverwriteImages | Out-Null
        Copy-P4CAssetSafe -SourcePath $_.FullName -DestinationPath (Join-Path $DevIncoming $name) -Overwrite:$OverwriteImages | Out-Null
    }
} else {
    Add-CopyLog 'SOURCE_FOLDER' $SourceImages '' 'FAILED' 'SourceImages folder does not exist'
}

# Copy known catalog images to production core when the source file is available and real/local.
$ImageImportRows = @()
foreach($item in $Catalog){
    $src = Join-Path $SourceImages $item.fileName
    $dst = Join-Path $CoreTarget $item.fileName
    $beforeCount = $CopyLog.Count
    $copied = Copy-P4CAssetSafe -SourcePath $src -DestinationPath $dst -Overwrite:$OverwriteImages
    $lastAction = if($CopyLog.Count -gt $beforeCount){ $CopyLog[$CopyLog.Count-1].action } else { 'NO_ACTION' }
    $ImageImportRows += [pscustomobject]@{
        timestamp=(Get-Date).ToString('s')
        catalogVersion=$CatalogVersion
        platformVersion=$PlatformVersion
        fileName=$item.fileName
        ratio=$item.ratio
        section=$item.section
        status=$item.status
        priority=$item.priority
        sourceExists=(Test-Path -LiteralPath $src -PathType Leaf)
        action=$lastAction
        corePath=$dst
        allPath=(Join-Path $AllImageTarget $item.fileName)
        futurePath=(Join-Path $FutureTarget $item.fileName)
        devIncomingPath=(Join-Path $DevIncoming $item.fileName)
        description=$item.description
    }
}

$CatalogObject=[pscustomobject]@{
    catalogVersion=$CatalogVersion
    platformVersion=$PlatformVersion
    sourceDocument='Pro4Chem_Image_Creation_Master_V20.pdf'
    sourceDocumentId='P4C-IMG-2026-V20'
    sourceFolder=$SourceImages
    targetCoreFolder=$CoreTarget
    targetAllFolder=$AllImageTarget
    futureFolder=$FutureTarget
    devIncomingFolder=$DevIncoming
    createdAt=(Get-Date).ToString('s')
    images=$ImageImportRows
}
$CatalogJson="$SiteRoot\config\image-catalog-p4c-wms-v1.0.json"
$CatalogCsv="$SiteRoot\config\image-catalog-p4c-wms-v1.0.csv"
$CatalogObject | ConvertTo-Json -Depth 8 | Set-Content -Path $CatalogJson -Encoding UTF8
$ImageImportRows | Export-Csv -Path $CatalogCsv -NoTypeInformation -Encoding UTF8
$ImportLog="$SiteRoot\logs\image-import-log.csv"
Export-P4CCsvSafe -Rows $ImageImportRows -Path $ImportLog
$CopyLogPath="$SiteRoot\logs\p4c-wms-v1.0-safe-copy-log.csv"
Export-P4CCsvSafe -Rows $CopyLog -Path $CopyLogPath

$RequiredPages = @(
    'management\index.html',
    'management\pages\page-factory.html',
    'management\pages\prompt-lab.html',
    'management\pages\stage1-review.html',
    'management\pages\stage3-review.html',
    'management\pages\website-graphics-review.html',
    'management\pages\image-catalog.html',
    'management\pages\cli-authentication.html',
    'management\pages\release-gates.html',
    'management\pages\deploy.html'
)
$RequiredAssets = @(
    'management\assets\p4c-wms.css',
    'management\assets\p4c-wms.js',
    'config\image-catalog-p4c-wms-v1.0.json',
    'config\image-catalog-p4c-wms-v1.0.csv'
)
$ValidationRows=@()
foreach($p in ($RequiredPages+$RequiredAssets)){
    $full=Join-Path $SiteRoot $p
    $ValidationRows += [pscustomobject]@{
        timestamp=(Get-Date).ToString('s')
        catalogVersion=$CatalogVersion
        platformVersion=$PlatformVersion
        item=$p
        exists=(Test-Path -LiteralPath $full)
        fullPath=$full
    }
}
$BaseDirs = $RequiredDirs | ForEach-Object {
    [pscustomobject]@{
        timestamp=(Get-Date).ToString('s')
        catalogVersion=$CatalogVersion
        platformVersion=$PlatformVersion
        item=$_
        exists=(Test-Path -LiteralPath $_)
    }
}
$ReportDir="$SiteRoot\reports\wms-validation"
$ReportJson=Join-Path $ReportDir ("p4c-wms-v1.0-validation-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".json")
[pscustomobject]@{
    catalogVersion=$CatalogVersion
    platformVersion=$PlatformVersion
    siteRoot=$SiteRoot
    devRoot=$DevRoot
    sourceImages=$SourceImages
    requiredPagesAndAssets=$ValidationRows
    baseDirectories=$BaseDirs
    copyLog=$CopyLog
    stage1Focus='Homepage creation and review'
    stage3Focus='Market, series, service, product finder expansion pages'
    deploymentStatus='Core scripts executed except deployment'
} | ConvertTo-Json -Depth 8 | Set-Content -Path $ReportJson -Encoding UTF8
$ValidationLog="$SiteRoot\logs\p4c-wms-v1.0-validation-log.csv"
Export-P4CCsvSafe -Rows $ValidationRows -Path $ValidationLog

try {
    if($PSCommandPath){ Copy-Item -LiteralPath $PSCommandPath -Destination "$SiteRoot\programs\integrations\P4C-WMS-V1.0\$(Split-Path $PSCommandPath -Leaf)" -Force -ErrorAction SilentlyContinue }
} catch {}

if($RunGitStatus -and (Test-Path "$SiteRoot\.git")){
    Push-Location $SiteRoot
    git status
    Pop-Location
}

Write-Host "P4C-WMS-V1.0 FIXED-V2 completed: validation, repair, safe image import, and catalog update." -ForegroundColor Green
Write-Host "Management index: $MgmtIndex" -ForegroundColor Cyan
Write-Host "Image catalog JSON: $CatalogJson" -ForegroundColor Cyan
Write-Host "Image import log: $ImportLog" -ForegroundColor Cyan
Write-Host "Safe copy log: $CopyLogPath" -ForegroundColor Cyan
Write-Host "Validation report: $ReportJson" -ForegroundColor Cyan
