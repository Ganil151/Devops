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