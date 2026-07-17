# Domino Datasets — Persistent Storage Notes

Both `dash-app/` and `shiny-app/` should read/write any files that need to
survive an App restart (uploaded files, cached query results, generated
reports) through a **Domino Dataset**, not the container's local disk.

## Why

- App containers are ephemeral — anything written to local disk is lost on
  restart/republish.
- Datasets are mounted read/write into Workspaces, Apps, and Jobs within the
  project, so both the Dash and Shiny apps can share the same underlying
  files if needed (e.g. a common lookup table DAVNIC used to serve to both
  dashboards).

## Typical mount path

Datasets are mounted under `/mnt/data/<dataset-name>/` inside the running
container. Confirm the exact path for your project's Dataset from
**Data > Datasets** in the Domino UI — it's shown per-dataset.

## Python (Dash) example

```python
import os

DATASET_PATH = "/mnt/data/davnic-shared"
cache_file = os.path.join(DATASET_PATH, "last_query_result.csv")
```

## R (Shiny) example

```r
dataset_path <- "/mnt/data/davnic-shared"
cache_file <- file.path(dataset_path, "last_query_result.csv")
```

## Action items from the DAVNIC scoping

- [ ] Identify every local file path in the current DAVNIC dashboards
      (config files, cached CSVs, uploaded user files, logs).
- [ ] Map each to either a Domino Dataset (persistent, shared) or an
      ephemeral scratch path (fine to lose on restart).
- [ ] Confirm write permissions — Datasets typically require explicit
      read-write mode to be enabled for the project/App.
