# 🛠️ Helm Challenges

## Challenge 1: The `values.yaml` Override
**Objective**: Customize a release.
1.  Run `helm create my-app`.
2.  Modify `values.yaml` to change `replicaCount` to 3.
3.  Install the chart: `helm install my-release ./my-app`.
4.  Verify with `kubectl get pods`.

## Challenge 2: Dry Run & Debug
**Objective**: Inspect the generated YAML.
1.  Install a chart using `--dry-run --debug`.
2.  Observe the output.
3.  Modify a template feature (e.g., add a new environment variable) and re-run dry run to verify the syntax.

## Challenge 3: Chart Versioning
**Objective**: Upgrade and Rollback.
1.  Change the `version` in `Chart.yaml`.
2.  Run `helm upgrade my-release ./my-app`.
3.  View history: `helm history my-release`.
4.  Rollback to version 1: `helm rollback my-release 1`.
