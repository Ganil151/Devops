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

### Advanced Level
7. **Infrastructure as Code options in GCP?**
   - **Terraform:** Industry standard (Google Provider).
   - **Deployment Manager:** Native GCP tool (YAML/Jinja) - entering maintenance mode.
   - **Config Connector:** Manage GCP resources using Kubernetes YAML manifests.
8. **What is Google Cloud's "Operations Suite"?**
   - Formerly Stackdriver. Includes Monitoring, Logging, Trace, Error Reporting, Debugger, Profiler.
9. **How to minimize container build times?**
   - Use Kaniko cache. Use smaller base images. Order Dockerfile layers (least changing first).

---

## Quiz: GCP DevOps

<details>
<summary><b>1. Default file name for Cloud Build configuration?</b></summary>
A) cloudbuild.yaml<br>
B) build.json<br>
C) gcp-pipeline.yml<br>
D) docker-compose.yml<br>
<br>
<b>Answer: A) cloudbuild.yaml</b>
</details>

<details>
<summary><b>2. Artifact Registry stores:</b></summary>
A) Docker images, npm, Maven, Python packages<br>
B) Source code only<br>
C) Logs<br>
D) VMs<br>
<br>
<b>Answer: A) Docker images, npm, Maven, Python packages</b>
</details>

<details>
<summary><b>3. Cloud Source Repositories supports:</b></summary>
A) Git<br>
B) SVN<br>
C) CVS<br>
D) Mercurial<br>
<br>
<b>Answer: A) Git</b>
</details>

<details>
<summary><b>4. Which tool replaces Stackdriver?</b></summary>
A) Google Cloud Operations Suite<br>
B) Cloud Watch<br>
C) Azure Monitor<br>
D) Splunk<br>
<br>
<b>Answer: A) Google Cloud Operations Suite</b>
</details>

<details>
<summary><b>5. To deploy to GKE using Cloud Build, you interact with:</b></summary>
A) kubectl (via a builder image) or GKE Autopilot<br>
B) SSH<br>
C) FTP<br>
D) Email<br>
<br>
<b>Answer: A) kubectl (via a builder image) or GKE Autopilot</b>
</details>

<details>
<summary><b>6. Cloud Deploy targets:</b></summary>
A) GKE, Cloud Run, Anthos<br>
B) Compute Engine<br>
C) App Engine<br>
D) Firebase<br>
<br>
<b>Answer: A) GKE, Cloud Run, Anthos</b>
</details>

<details>
<summary><b>7. Terraform state should be stored in:</b></summary>
A) GCS Bucket (Remote Backend)<br>
B) Git<br>
C) Local laptop<br>
D) Public website<br>
<br>
<b>Answer: A) GCS Bucket (Remote Backend)</b>
</details>

<details>
<summary><b>8. Cloud Build pricing is based on:</b></summary>
A) Build minutes (120 free/day)<br>
B) Number of builds<br>
C) Storage<br>
D) Users<br>
<br>
<b>Answer: A) Build minutes (120 free/day)</b>
</details>

<details>
<summary><b>9. Error Reporting aggregates:</b></summary>
A) Crashes and exceptions from logs<br>
B) User complaints<br>
C) Billing errors<br>
D) Network errors<br>
<br>
<b>Answer: A) Crashes and exceptions from logs</b>
</details>

<details>
<summary><b>10. Cloud Trace helps with:</b></summary>
A) Latency analysis (Distributed Tracing)<br>
B) Drawing<br>
C) Logging<br>
D) Security<br>
<br>
<b>Answer: A) Latency analysis (Distributed Tracing)</b>
</details>

<details>
<summary><b>11. Can Cloud Build access private VPC resources?</b></summary>
A) Yes, via Private Pools<br>
B) No<br>
<br>
<b>Answer: A) Yes, via Private Pools</b>
</details>

<details>
<summary><b>12. Deployment Manager uses:</b></summary>
A) YAML or Python/Jinja templates<br>
B) HCL<br>
C) C++<br>
D) Java<br>
<br>
<b>Answer: A) YAML or Python/Jinja templates</b>
</details>

<details>
<summary><b>13. "Prometheus" managed service in GCP?</b></summary>
A) Managed Service for Prometheus (part of Monitoring)<br>
B) Function<br>
C) Database<br>
D) None<br>
<br>
<b>Answer: A) Managed Service for Prometheus (part of Monitoring)</b>
</details>

<details>
<summary><b>14. Cloud Profiler measures:</b></summary>
A) CPU and Memory usage of code functions (Continuous Profiling)<br>
B) User profiles<br>
C) Disk speed<br>
D) Network speed<br>
<br>
<b>Answer: A) CPU and Memory usage of code functions (Continuous Profiling)</b>
</details>

<details>
<summary><b>15. Skaffold is used for:</b></summary>
A) Local Kubernetes development loop (iterative build/deploy)<br>
B) Production<br>
C) Testing only<br>
D) Nothing<br>
<br>
<b>Answer: A) Local Kubernetes development loop (iterative build/deploy)</b>
</details>

<details>
<summary><b>16. Config Connector lets you:</b></summary>
A) Manage GCP resources using K8s manifests<br>
B) Connect wires<br>
C) Connect databases<br>
D) Nothing<br>
<br>
<b>Answer: A) Manage GCP resources using K8s manifests</b>
</details>

<details>
<summary><b>17. Can you run Cloud Build locally?</b></summary>
A) Yes, using `cloud-build-local` (though deprecated/limited, mostly test via submission)<br>
B) No<br>
<br>
<b>Answer: A) Yes, using `cloud-build-local` (though deprecated/limited, mostly test via submission)</b>
</details>

<details>
<summary><b>18. Cloud Deploy "Promote" action:</b></summary>
A) Moves a release from one stage to next (e.g., Staging -> Prod)<br>
B) Advertises it<br>
C) Deletes it<br>
D) Builds it<br>
<br>
<b>Answer: A) Moves a release from one stage to next (e.g., Staging -> Prod)</b>
</details>

<details>
<summary><b>19. Is Container Registry deprecated?</b></summary>
A) Yes, in favor of Artifact Registry<br>
B) No<br>
<br>
<b>Answer: A) Yes, in favor of Artifact Registry</b>
</details>

<details>
<summary><b>20. Log Sink destination can be:</b></summary>
A) Storage Bucket, Pub/Sub, BigQuery, Another Project<br>
B) Printer<br>
C) Email<br>
D) None<br>
<br>
<b>Answer: A) Storage Bucket, Pub/Sub, BigQuery, Another Project</b>
</details>

<details>
<summary><b>21. SL I / SLO / SLA?</b></summary>
A) Indicator (Metric), Objective (Goal), Agreement (Contract)<br>
B) Terms<br>
C) Acronyms<br>
D) Nothing<br>
<br>
<b>Answer: A) Indicator (Metric), Objective (Goal), Agreement (Contract)</b>
</details>