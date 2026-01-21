# 🛠️ Kustomize Challenges

## Challenge 1: The Overlay Project
**Objective**: Setup Environment-specific config.
1.  Create a folder structure: `base/`, `overlays/dev/`, `overlays/prod/`.
2.  Put a simple `deployment.yaml` in `base/`.
3.  In `overlays/prod/kustomization.yaml`, use `resources: - ../../base` and add a `nameSuffix: -prod`.

## Challenge 2: ConfigMap Generator
**Objective**: Automate ConfigMap creation.
1.  Use the `configMapGenerator` in your `kustomization.yaml`.
2.  Generate a ConfigMap from a local file `app.properties`.
3.  Observe how Kustomize appends a hash to the name (e.g., `my-config-f9h2k3`).

## Challenge 3: Patching
**Objective**: Modify specific fields.
1.  Use `patchesStrategicMerge`.
2.  In your `dev` overlay, increase the replica count of the deployment defined in the `base`.
