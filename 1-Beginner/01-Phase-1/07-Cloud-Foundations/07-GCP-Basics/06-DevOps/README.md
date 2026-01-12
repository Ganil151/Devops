# Google Cloud DevOps

Comprehensive guide to GCP DevOps services including Cloud Build, Cloud Deploy, and CI/CD pipelines.

## Cloud Build
```yaml
# cloudbuild.yaml
steps:
# Build the container image
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/my-app:$COMMIT_SHA', '.']

# Push the container image to Container Registry
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/my-app:$COMMIT_SHA']

# Deploy to Cloud Run
- name: 'gcr.io/cloud-builders/gcloud'
  args:
  - 'run'
  - 'deploy'
  - 'my-app'
  - '--image'
  - 'gcr.io/$PROJECT_ID/my-app:$COMMIT_SHA'
  - '--region'
  - 'us-central1'
  - '--platform'
  - 'managed'
  - '--allow-unauthenticated'

images:
- 'gcr.io/$PROJECT_ID/my-app:$COMMIT_SHA'
```

```bash
# Trigger build manually
gcloud builds submit --config=cloudbuild.yaml .

# Create build trigger
gcloud builds triggers create github \
  --repo-name=my-repo \
  --repo-owner=my-username \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml

# List builds
gcloud builds list

# View build logs
gcloud builds log BUILD_ID
```

## Cloud Deploy
```yaml
# clouddeploy.yaml
apiVersion: deploy.cloud.google.com/v1
kind: DeliveryPipeline
metadata:
  name: my-pipeline
description: My application delivery pipeline
serialPipeline:
  stages:
  - targetId: staging
    profiles: []
  - targetId: production
    profiles: []
---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: staging
description: Staging environment
gke:
  cluster: projects/my-project/locations/us-central1/clusters/staging-cluster
---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: production
description: Production environment
gke:
  cluster: projects/my-project/locations/us-central1/clusters/prod-cluster
```

```bash
# Apply delivery pipeline
gcloud deploy apply --file=clouddeploy.yaml --region=us-central1

# Create release
gcloud deploy releases create release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1 \
  --images=my-app=gcr.io/my-project/my-app:latest

# Promote release
gcloud deploy releases promote \
  --release=release-001 \
  --delivery-pipeline=my-pipeline \
  --region=us-central1
```

## Artifact Registry
```bash
# Create repository
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=us-central1

# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Tag and push image
docker tag my-app us-central1-docker.pkg.dev/my-project/my-repo/my-app:latest
docker push us-central1-docker.pkg.dev/my-project/my-repo/my-app:latest

# List artifacts
gcloud artifacts docker images list us-central1-docker.pkg.dev/my-project/my-repo
```

## Cloud Source Repositories
```bash
# Create repository
gcloud source repos create my-repo

# Clone repository
gcloud source repos clone my-repo

# Add remote to existing Git repo
git remote add google https://source.developers.google.com/p/my-project/r/my-repo
```

## Infrastructure as Code with Deployment Manager
```yaml
# template.yaml
resources:
- name: my-instance
  type: compute.v1.instance
  properties:
    zone: us-central1-a
    machineType: zones/us-central1-a/machineTypes/e2-medium
    disks:
    - deviceName: boot
      type: PERSISTENT
      boot: true
      autoDelete: true
      initializeParams:
        sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts
    networkInterfaces:
    - network: global/networks/default
      accessConfigs:
      - name: External NAT
        type: ONE_TO_ONE_NAT
```

```bash
# Deploy template
gcloud deployment-manager deployments create my-deployment \
  --config=template.yaml

# Update deployment
gcloud deployment-manager deployments update my-deployment \
  --config=template.yaml

# Delete deployment
gcloud deployment-manager deployments delete my-deployment
```

This guide covers GCP DevOps services for continuous integration and deployment automation.

## Real World Scenarios

### Scenario 1: Serverless CI/CD Pipeline
**Context:** Deploy a Python API to Cloud Run on every push to GitHub main branch.
**Solution:**
- **Cloud Build:** Connect GitHub repo via Trigger.
- **Build Step:** Use `cloudbuild.yaml` to build container.
- **Deploy Step:** `gcloud run deploy` command.
**Benefit:** Fully managed, pay-per-minute pipeline. No Jenkins server to maintain.

### Scenario 2: Canary Deployment
**Context:** Roll out v2 of an app to 10% of users.
**Solution:**
- **Cloud Run / App Engine:** Use traffic splitting features.
- **Cloud Deploy:** Define a Canary release strategy for GKE.
**Benefit:** Reduced blast radius of bad deployments.

---

## Interview Questions

### Basic Level
1. **What is Cloud Build?**
   - Serverless CI/CD platform. Builds, tests, and deploys. Executes steps defined in YAML.
2. **What is Artifact Registry?**
   - The successor to Container Registry. Stores OCI containers, Maven, npm, Python packages.
3. **What is Cloud Source Repositories?**
   - Private Git repositories hosted on GCP.

### Intermediate Level
4. **Explain Cloud Deploy.**
   - Fully managed continuous delivery service for GKE, Cloud Run, and Anthos. Focuses on the "CD" part (pipeline, promotion, rollback).
5. **How do you trigger a Cloud Build?**
   - Manual CLI (`gcloud builds submit`), Triggers (GitHub/Bitbucket push/PR), or Pub/Sub events.
6. **What are "Substitutions" in Cloud Build?**
   - Variables (like `$PROJECT_ID`, `$COMMIT_SHA`) used in the build configuration files.

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) cloudbuild.yaml</b>
</details>


<b>2. Artifact Registry stores:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Docker images, npm, Maven, Python packages</b>
</details>


<b>3. Cloud Source Repositories supports:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Git</b>
</details>


<b>4. Which tool replaces Stackdriver?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Google Cloud Operations Suite</b>
</details>


<b>5. To deploy to GKE using Cloud Build, you interact with:</b>
<details>
<summary>Show Answer</summary>
Answer: A) kubectl (via a builder image) or GKE Autopilot</b>
</details>


<b>6. Cloud Deploy targets:</b>
<details>
<summary>Show Answer</summary>
Answer: A) GKE, Cloud Run, Anthos</b>
</details>


<b>7. Terraform state should be stored in:</b>
<details>
<summary>Show Answer</summary>
Answer: A) GCS Bucket (Remote Backend)</b>
</details>


<b>8. Cloud Build pricing is based on:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Build minutes (120 free/day)</b>
</details>


<b>9. Error Reporting aggregates:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Crashes and exceptions from logs</b>
</details>


<b>10. Cloud Trace helps with:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Latency analysis (Distributed Tracing)</b>
</details>


<b>11. Can Cloud Build access private VPC resources?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, via Private Pools</b>
</details>


<b>12. Deployment Manager uses:</b>
<details>
<summary>Show Answer</summary>
Answer: A) YAML or Python/Jinja templates</b>
</details>


<b>13. "Prometheus" managed service in GCP?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Managed Service for Prometheus (part of Monitoring)</b>
</details>


<b>14. Cloud Profiler measures:</b>
<details>
<summary>Show Answer</summary>
Answer: A) CPU and Memory usage of code functions (Continuous Profiling)</b>
</details>


<b>15. Skaffold is used for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Local Kubernetes development loop (iterative build/deploy)</b>
</details>


<b>16. Config Connector lets you:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Manage GCP resources using K8s manifests</b>
</details>


<b>17. Can you run Cloud Build locally?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using `cloud-build-local` (though deprecated/limited, mostly test via submission)</b>
</details>


<b>18. Cloud Deploy "Promote" action:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Moves a release from one stage to next (e.g., Staging -> Prod)</b>
</details>


<b>19. Is Container Registry deprecated?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, in favor of Artifact Registry</b>
</details>


<b>20. Log Sink destination can be:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Storage Bucket, Pub/Sub, BigQuery, Another Project</b>
</details>


<b>21. SL I / SLO / SLA?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Indicator (Metric), Objective (Goal), Agreement (Contract)</b>
</details>
