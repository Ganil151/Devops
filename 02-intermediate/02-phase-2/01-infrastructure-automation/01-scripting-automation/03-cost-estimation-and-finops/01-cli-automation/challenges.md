# 🛠️ Infracost CLI Challenges

## Challenge 1: The HTML Exporter
**Objective**: Build a shareable report.
1.  Run a breakdown on a Terraform project (or dummy files).
2.  Use `infracost output` to generate an `index.html`.
3.  Add a custom title to the report using the `--title` flag.

## Challenge 2: JSON Key Extraction
**Objective**: Use `jq` with Infracost.
1.  Run `infracost breakdown --format json`.
2.  Use `jq` to extract just the `totalMonthlyCost` value.
3.  Logic: `.totalMonthlyCost | tonumber`.

## Challenge 3: Multi-Project Summary
**Objective**: Aggregate costs.
1.  You have two folders: `prod/` and `dev/`.
2.  Run Infracost on both.
3.  Generate a single Markdown report that summarizes BOTH into one table.
