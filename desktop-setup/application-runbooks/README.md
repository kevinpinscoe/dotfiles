# Desktop Application Runbooks

Runbooks for GUI/desktop applications. Unlike containers, scripts, and CLI tools — which can carry colocated documentation — desktop apps have no natural place to store operational notes, so they live here instead.

## Structure

Each application has its own directory containing a `RUNBOOK.md` and any supporting reference files.

```
application-runbooks/
├── README.md
└── <AppName>/
    ├── RUNBOOK.md          ← procedures, tips, and troubleshooting
    └── <supporting files>
```

Runbooks are not platform-gated. An app directory is created regardless of whether the app runs on one platform or many — the runbook itself documents any platform-specific caveats.

## Current Runbooks

| Application | Runbook | Notes |
|-------------|---------|-------|
| Obsidian | [Obsidian/RUNBOOK.md](Obsidian/RUNBOOK.md) | Spell-check dictionary management |
