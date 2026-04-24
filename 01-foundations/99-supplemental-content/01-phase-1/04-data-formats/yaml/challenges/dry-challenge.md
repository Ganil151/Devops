# 🛠️ YAML Challenge: DRY-ify this Configuration

**Task**: The following configuration is repetitive and prone to errors. If the `database_url` changes, the engineer has to update it in three places. Refactor this file using **YAML Anchors (`&`)** and **Aliases (`*`)** to define the common settings once and reuse them.

## Target File: `app_config.yaml`

```yaml
app_dev:
  env: development
  database_url: "db-cluster-prod.aws.internal:5432"
  debug: true
  retry_count: 5
  timeout: 30

app_staging:
  env: staging
  database_url: "db-cluster-prod.aws.internal:5432"
  debug: true
  retry_count: 5
  timeout: 30

app_prod:
  env: production
  database_url: "db-cluster-prod.aws.internal:5432"
  debug: false # Exception: prod has debug false
  retry_count: 5
  timeout: 30
```

## Requirements:
1. Create a "Golden Anchor" for the shared settings.
2. Ensure the `app_prod` environment still has `debug: false`.
3. Save your refactored version as `dry_config_solution.yaml` in the `solutions/` folder.
