# P4C-WMS-V1.0-Import-Images-To-Catalog.ps1
<#
Purpose:
  Copy Pro4Chem V21 image files into the local GitHub clone used by the Pro4Chem Web Management System,
  then create/update the image catalog used for page creation.

Default source:
  M:\Mi unidad\Pro4Chem-Web-Ai\Images\v21\Images

Default targets:
  X:\devweb\pro4chem-site\public\images\core
  X:\devweb\pro4chem-site\config\image-catalog-p4c-wms-v1.0.json
  X:\devweb\pro4chem-site\logs\image-import-log.csv

P4C-WMS-V1.0 policy:
  - Existing/generated final image assets are used directly from the local GitHub clone.
  - New or changed image work also gets mirrored to the dev incoming area for review.
  - The script does not deploy to GitHub/Cloudflare.
#>
param(
    [string]$SourceImages = "M:\Mi unidad\Pro4Chem-Web-Ai\Images\v21\Images",
    [string]$SiteRoot = "X:\devweb\pro4chem-site",
    [string]$DevRoot = "X:\devweb\pro4chem-dev",
    [switch]$MirrorNewAndChangedToDev = $true,
    [switch]$Overwrite = $false
)
$ErrorActionPreference = "Stop"
$CatalogVersion = "P4C-WMS-V1.0"
$CoreTarget = Join-Path $SiteRoot "public\images\core"
$ConfigDir = Join-Path $SiteRoot "config"
$LogDir = Join-Path $SiteRoot "logs"
$DevIncoming = Join-Path $DevRoot "public\images\incoming"
$IntegrationDir = Join-Path $SiteRoot "programs\integrations\P4C-WMS-V1.0"
foreach($d in @($CoreTarget,$ConfigDir,$LogDir,$DevIncoming,$IntegrationDir)){ New-Item -ItemType Directory -Force -Path $d | Out-Null }
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
$Imported = @()
foreach($item in $Catalog){
    $src = Join-Path $SourceImages $item.fileName
    $dst = Join-Path $CoreTarget $item.fileName
    $devDst = Join-Path $DevIncoming $item.fileName
    $exists = Test-Path $src
    $action = "MISSING_SOURCE"
    if($exists){
        if((Test-Path $dst) -and -not $Overwrite){
            $action = "SKIPPED_EXISTS"
        } else {
            Copy-Item -Path $src -Destination $dst -Force:$Overwrite
            $action = "COPIED_TO_GITHUB_CORE"
        }
        if($MirrorNewAndChangedToDev -and (($item.status -eq "NEW") -or ($item.priority -eq "HIGH"))){
            Copy-Item -Path $src -Destination $devDst -Force
            $action = "$action + MIRRORED_TO_DEV_INCOMING"
        }
    }
    $Imported += [pscustomobject]@{
        timestamp = (Get-Date).ToString("s")
        catalogVersion = $CatalogVersion
        fileName = $item.fileName
        ratio = $item.ratio
        section = $item.section
        status = $item.status
        priority = $item.priority
        sourceExists = $exists
        action = $action
        targetPath = $dst
        devIncomingPath = $devDst
        description = $item.description
    }
}
$CatalogObject = [pscustomobject]@{
    catalogVersion = $CatalogVersion
    sourceDocument = "Pro4Chem_Image_Creation_Master_V20.pdf"
    sourceDocumentId = "P4C-IMG-2026-V20"
    sourceFolder = $SourceImages
    targetCoreFolder = $CoreTarget
    devIncomingFolder = $DevIncoming
    createdAt = (Get-Date).ToString("s")
    images = $Imported
}
$CatalogPath = Join-Path $ConfigDir "image-catalog-p4c-wms-v1.0.json"
$CatalogObject | ConvertTo-Json -Depth 8 | Set-Content -Path $CatalogPath -Encoding UTF8
$CsvPath = Join-Path $ConfigDir "image-catalog-p4c-wms-v1.0.csv"
$Imported | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
$LogPath = Join-Path $LogDir "image-import-log.csv"
if(!(Test-Path $LogPath)){ $Imported | Export-Csv -Path $LogPath -NoTypeInformation -Encoding UTF8 }
else { $Imported | Export-Csv -Path $LogPath -NoTypeInformation -Append -Encoding UTF8 }
# Keep a copy of this integration script in the WMS integration folder.
try { Copy-Item -Path $PSCommandPath -Destination (Join-Path $IntegrationDir (Split-Path $PSCommandPath -Leaf)) -Force } catch {}
Write-Host "P4C-WMS-V1.0 image import completed." -ForegroundColor Green
Write-Host "Catalog JSON: $CatalogPath" -ForegroundColor Cyan
Write-Host "Catalog CSV : $CsvPath" -ForegroundColor Cyan
Write-Host "Core images : $CoreTarget" -ForegroundColor Cyan
Write-Host "Dev incoming: $DevIncoming" -ForegroundColor Cyan
