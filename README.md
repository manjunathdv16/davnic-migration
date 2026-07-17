# DAVNIC → Domino Migration Project

This project hosts both the R/Shiny and Python/Dash dashboards being migrated
off GPS/DAVNIC and onto Domino Apps. Each app is self-contained and published
as a **separate Domino App** within this one project, so they can be scaled,
restarted, and versioned independently.

## Structure

```
davnic-migration/
├── dash-app/               # Python/Dash dashboard(s)
│   ├── app.py
│   ├── app.sh
│   └── requirements.txt
├── shiny-app/               # R/Shiny dashboard(s)
│   ├── app.R
│   ├── app.sh
│   └── (renv.lock or install.R for R package pinning)
├── shared/
│   └── datasets_readme/     # Notes on Domino Dataset mount points used by both apps
└── .domino/                 # Optional: environment Dockerfile instructions, compute config notes
```

## Why two separate apps instead of one

- Independent **hardware tiers**: Shiny dashboards with heavy reactive
  computation may need more CPU/RAM than a lightweight Dash filter view, or
  vice versa. Separate Apps = separate hardware tier settings.
- Independent **restart/publish cycles**: a Shiny code change shouldn't force
  a Dash app rebuild and vice versa.
- Independent **environments**: R and Python dependency sets don't need to
  live in the same compute environment image, which keeps builds faster and
  avoids one language's dependency churn breaking the other.

If your actual DAVNIC dashboards need to share state or a common data layer,
that's handled through **Domino Datasets** (see below), not a shared codebase.

## Migration checklist (carried over from your DAVNIC scoping)

- [ ] **Authentication model**: confirm whether target apps rely on Domino's
      built-in identity headers (`X-Domino-Username` etc., auto-injected) or
      need a custom auth layer bridging over from DAVNIC's existing SSO.
- [ ] **Persistent storage**: replace any DAVNIC local-disk read/write paths
      with a **Domino Dataset** mount (see `shared/datasets_readme/`).
      Datasets persist across app restarts and are shared across
      Workspaces/Apps/Jobs in the project — local container filesystem does
      not persist between App restarts.
- [ ] **WebSocket handling**: Shiny's reactivity depends on a live WebSocket
      connection. Domino's App proxy handles this natively — no manual
      config needed, unlike some other reverse-proxy setups. If you see
      "greyed out" Shiny apps in production, check the Shiny Server session
      timeout settings, not the proxy.
      the app path (`requests_pathname_prefix`), not just the port.
- [ ] **Resource configuration**: pick the App hardware tier based on
      concurrent-user load, not just single-session testing — Shiny in
      particular is single-threaded per session by default and can bottleneck
      under concurrent load without `future`/`promises` async handling.

## Deployment order (recommended)

1. Stand up `dash-app/` first (already validated in the demo project).
2. Stand up `shiny-app/` following the walkthrough below.
3. Wire in real Domino Dataset mounts once both apps run with dummy data.
4. Swap dummy data/logic for the real DAVNIC dashboard code incrementally,
   one dashboard at a time, testing each in a Workspace before publishing.
