---
name: pro4chem-page-system
description: Use for Pro4Chem site work from pro4chem-site while routing normal page creation, edits, WMS status, validation, staging, and rollback through the pro4chem-dev control repo.
---

# Pro4Chem Page System Skill

This is the `pro4chem-site` wrapper for the Pro4Chem Codex Desktop complement.

`pro4chem-site` is treated as the deployed/site repository. For normal page creation, generated page edits, shared design changes, translations, link fixes, WMS status, validation, staging, rollback, or dashboard updates, use the control repo:

`X:\devweb\pro4chem-dev`

Direct edits inside `pro4chem-site` are allowed only when the user explicitly approves a specific production/site page or emergency correction. Do not create independent page-system manifests, status exports, or generated page state in this repo.

Before changing Pro4Chem pages from this project:

1. Confirm whether the request explicitly authorizes a direct `pro4chem-site` edit.
2. If not, switch page-system work to `X:\devweb\pro4chem-dev`.
3. Run `python management/tools/pro4chem_page_system.py export-manifests`.
4. Run `python management/tools/pro4chem_page_system.py plan --page <page-id> --change-type <type> --notes "<request>"`, or use `--scope all-pages` only for shared header, footer, nav, design, or release work.
5. Read `management/data/page-system-last-run.md`.
6. Edit only files named by the plan.
7. Generate affected pages with `python management/tools/pro4chem_page_system.py generate --page <page-id> --export-manifests` when possible.
8. Validate with `python management/tools/pro4chem_page_system.py validate --page <page-id>`.
9. Refresh WMS dashboard status with `python management/tools/pro4chem_page_system.py status --write-js`.
10. Do not promote to staging or deployed unless the user explicitly approves it.

WMS review dashboard:

`X:\devweb\pro4chem-dev\management\pages\agent-program-system.html`

Browser URL:

`file:///X:/devweb/pro4chem-dev/management/pages/agent-program-system.html`

Prompt pattern:

```text
$pro4chem-page-system
I am working from pro4chem-site. Use pro4chem-dev as the planning/control repo. Directly modify pro4chem-site only for this explicitly approved page/task: <specific page and change>.
```
