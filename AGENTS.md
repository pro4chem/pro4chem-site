# Pro4Chem Site Agent Guidance

Use the repo skill `$pro4chem-page-system` for Pro4Chem page work.

`pro4chem-site` is the deployed/site repository. Default page creation and generated page edits must run through the control repo:

`M:\Mi unidad\devweb\pro4chem-dev`

Direct edits in `pro4chem-site` are allowed only when the user explicitly approves a specific production/site page or emergency correction. Do not create independent page-system manifests, generated draft state, validation exports, or WMS dashboard data in this repo.

Planner-first workflow:

1. Use `M:\Mi unidad\devweb\pro4chem-dev` for page-system commands.
2. Export manifests before planning.
3. Run the planner for the requested page or explicit all-pages scope.
4. Read the latest page-system report before editing.
5. Generate only affected pages when possible.
6. Validate affected pages.
7. Refresh WMS status with `python management\tools\pro4chem_page_system.py status --write-js`.
8. Do not promote to staging or deployed unless the user explicitly approves it.

WMS dashboard:

`M:\Mi unidad\devweb\pro4chem-dev\management\pages\agent-program-system.html`

Browser URL:

`file:///M:/Mi%20unidad/devweb/pro4chem-dev/management/pages/agent-program-system.html`
