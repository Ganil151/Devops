# Google Cloud Platform (GCP) Fundamentals

Comprehensive guide to Google Cloud Platform for DevOps engineers and cloud practitioners.

## What is Google Cloud Platform?

Google Cloud Platform (GCP) is a suite of cloud computing services that provides infrastructure, platform, and software services. GCP offers over 100 products and services including computing, storage, networking, big data, machine learning, and IoT, running on the same infrastructure that Google uses for its end-user products.

## GCP Global Infrastructure

### Regions and Zones

```bash
# List all GCP regions
gcloud compute regions list

# List zones in a specific region
gcloud compute zones list --filter="region:us-central1"

# Set default region and zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

# Get current project configuration
gcloud config list
```

### GCP Infrastructure Components

```
GCP Global Infrastructure
├── Regions (35+ worldwide)
│   ├── Zones (106+ zones)
│   │   └── Data Centers (1+ per zone)
│   └── Multi-Regional (for global services)
├── Points of Presence (200+ worldwide)
│   ├── Cloud CDN
│   └── Google Global Cache
└── Network Infrastructure
    ├── Private Google Network
    └── Dedicated Interconnect
```

## Core GCP Services

### Compute Services

#### Compute Engine (Virtual Machines)
```bash
# List machine types
gcloud compute machine-types list --zones=us-central1-a

# Create VM instance
gcloud compute instances create devops-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --tags=http-server,https-server

# Start/Stop VM
gcloud compute instances start devops-vm --zone=us-central1-a
gcloud compute instances stop devops-vm --zone=us-central1-a

# SSH into VM
gcloud compute ssh devops-vm --zone=us-central1-a

# List instances
gcloud compute instances list

# Delete instance
gcloud compute instances delete devops-vm --zone=us-central1-a

# Create instance from custom image
gcloud compute instances create custom-vm \
    --zone=us-central1-a \
    --image=my-custom-image \
    --image-project=my-project
```

#### Google Kubernetes Engine (GKE)
```bash
# Create GKE cluster
gcloud container clusters create devops-cluster \
    --zone=us-central1-a \
    --num-nodes=3 \
    --machine-type=e2-medium \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \
    --enable-autorepair \
    --enable-autoupgrade

# Get cluster credentials
gcloud container clusters get-credentials devops-cluster --zone=us-central1-a

# Scale cluster
gcloud container clusters resize devops-cluster --num-nodes=5 --zone=us-central1-a

# Upgrade cluster
gcloud container clusters upgrade devops-cluster --zone=us-central1-a

# List clusters
gcloud container clusters list

# Delete cluster
gcloud container clusters delete devops-cluster --zone=us-central1-a
```

#### Cloud Run (Serverless Containers)
```bash
# Deploy container to Cloud Run
gcloud run deploy devops-service \
    --image=gcr.io/my-project/my-app:latest \
    --platform=managed \
    --region=us-central1 \
    --allow-unauthenticated \
    --memory=512Mi \
    --cpu=1 \
    --concurrency=100 \
    --max-instances=10

# List Cloud Run services
gcloud run services list

# Update service
gcloud run services update devops-service \
    --region=us-central1 \
    --memory=1Gi \
    --cpu=2

# Get service URL
gcloud run services describe devops-service --region=us-central1 --format="value(status.url)"

# Delete service
gcloud run services delete devops-service --region=us-central1
```

#### Cloud Functions (Serverless Functions)
```bash
# Deploy function
gcloud functions deploy devops-function \
    --runtime=python39 \
    --trigger-http \
    --allow-unauthenticated \
    --source=. \
    --entry-point=main \
    --memory=256MB \
    --timeout=60s

# List functions
gcloud functions list

# Call function
gcloud functions call devops-function --data='{"name":"DevOps"}'

# View function logs
gcloud functions logs read devops-function

# Delete function
gcloud functions delete devops-function
```

### Storage Services

#### Cloud Storage
```bash
# Create bucket
gsutil mb gs://devops-bucket-$(date +%s)

# Upload file
gsutil cp local-file.txt gs://devops-bucket/

# Download file
gsutil cp gs://devops-bucket/remote-file.txt ./

# Sync directory
gsutil -m rsync -r ./local-folder gs://devops-bucket/folder/

# List buckets
gsutil ls

# List objects in bucket
gsutil ls gs://devops-bucket/

# Set bucket permissions
gsutil iam ch user:user@example.com:objectViewer gs://devops-bucket

# Enable versioning
gsutil versioning set on gs://devops-bucket

# Set lifecycle policy
gsutil lifecycle set lifecycle.json gs://devops-bucket

# Delete bucket
gsutil rm -r gs://devops-bucket
```

#### Persistent Disks
```bash
# Create persistent disk
gcloud compute disks create devops-disk \
    --size=100GB \
    --zone=us-central1-a \
    --type=pd-ssd

# Attach disk to instance
gcloud compute instances attach-disk devops-vm \
    --disk=devops-disk \
    --zone=us-central1-a

# Create snapshot
gcloud compute disks snapshot devops-disk \
    --snapshot-names=devops-disk-snapshot \
    --zone=us-central1-a

# List disks
gcloud compute disks list

# Delete disk
gcloud compute disks delete devops-disk --zone=us-central1-a
```

#### Filestore (Managed NFS)
```bash
# Create Filestore instance
gcloud filestore instances create devops-filestore \
    --zone=us-central1-a \
    --tier=BASIC_HDD \
    --file-share=name=devops-share,capacity=1TB \
    --network=name=default

# List Filestore instances
gcloud filestore instances list

# Mount Filestore (on VM)
sudo mkdir /mnt/devops-share
sudo mount -t nfs -o vers=3 FILESTORE_IP:/devops-share /mnt/devops-share
```

### Database Services

#### Cloud SQL
```bash
# Create Cloud SQL instance
gcloud sql instances create devops-mysql \
    --database-version=MYSQL_8_0 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --root-password=MySecurePassword123 \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=04

# Create database
gcloud sql databases create devops_db --instance=devops-mysql

# Create user
gcloud sql users create devops_user \
    --instance=devops-mysql \
    --password=UserPassword123

# Connect to instance
gcloud sql connect devops-mysql --user=root

# Create backup
gcloud sql backups create --instance=devops-mysql

# List instances
gcloud sql instances list

# Delete instance
gcloud sql instances delete devops-mysql
```

#### Cloud Firestore (NoSQL)
```bash
# Create Firestore database (via console or API)
gcloud firestore databases create --region=us-central1

# Import data
gcloud firestore import gs://devops-bucket/firestore-export/

# Export data
gcloud firestore export gs://devops-bucket/firestore-backup/

# List collections (using client libraries)
# Python example:
from google.cloud import firestore
db = firestore.Client()
collections = db.collections()
```

#### Cloud Spanner (Globally Distributed SQL)
```bash
# Create Spanner instance
gcloud spanner instances create devops-spanner \
    --config=regional-us-central1 \
    --description="DevOps Spanner Instance" \
    --nodes=1

# Create database
gcloud spanner databases create devops-db \
    --instance=devops-spanner

# List instances
gcloud spanner instances list

# Delete instance
gcloud spanner instances delete devops-spanner
```

## Networking in GCP

### Virtual Private Cloud (VPC)

```bash
# Create VPC network
gcloud compute networks create devops-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

# Create subnet
gcloud compute networks subnets create devops-subnet \
    --network=devops-vpc \
    --range=10.0.1.0/24 \
    --region=us-central1

# Create firewall rule
gcloud compute firewall-rules create allow-ssh \
    --network=devops-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-server

gcloud compute firewall-rules create allow-http \
    --network=devops-vpc \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# List networks
gcloud compute networks list

# List subnets
gcloud compute networks subnets list

# List firewall rules
gcloud compute firewall-rules list
```

### Load Balancing

```bash
# Create instance template
gcloud compute instance-templates create devops-template \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server \
    --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx'

# Create managed instance group
gcloud compute instance-groups managed create devops-group \
    --template=devops-template \
    --size=3 \
    --zone=us-central1-a

# Set autoscaling
gcloud compute instance-groups managed set-autoscaling devops-group \
    --zone=us-central1-a \
    --max-num-replicas=10 \
    --min-num-replicas=3 \
    --target-cpu-utilization=0.6

# Create health check
gcloud compute health-checks create http devops-health-check \
    --port=80 \
    --request-path=/

# Create backend service
gcloud compute backend-services create devops-backend \
    --protocol=HTTP \
    --health-checks=devops-health-check \
    --global

# Add backend to service
gcloud compute backend-services add-backend devops-backend \
    --instance-group=devops-group \
    --instance-group-zone=us-central1-a \
    --global

# Create URL map
gcloud compute url-maps create devops-url-map \
    --default-service=devops-backend

# Create HTTP proxy
gcloud compute target-http-proxies create devops-http-proxy \
    --url-map=devops-url-map

# Create forwarding rule
gcloud compute forwarding-rules create devops-forwarding-rule \
    --global \
    --target-http-proxy=devops-http-proxy \
    --ports=80
```

### Cloud CDN

```bash
# Enable Cloud CDN on backend service
gcloud compute backend-services update devops-backend \
    --enable-cdn \
    --global

# Configure cache settings
gcloud compute backend-services update devops-backend \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=3600 \
    --max-ttl=86400 \
    --global
```

## Identity and Access Management (IAM)

### Users and Service Accounts

```bash
# Create service account
gcloud iam service-accounts create devops-sa \
    --description="DevOps Service Account" \
    --display-name="DevOps SA"

# Grant roles to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:devops-sa@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"

# Create and download key
gcloud iam service-accounts keys create devops-sa-key.json \
    --iam-account=devops-sa@PROJECT_ID.iam.gserviceaccount.com

# Grant role to user
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="user:user@example.com" \
    --role="roles/viewer"

# List IAM policy
gcloud projects get-iam-policy PROJECT_ID

# Create custom role
gcloud iam roles create devopsCustomRole \
    --project=PROJECT_ID \
    --title="DevOps Custom Role" \
    --description="Custom role for DevOps team" \
    --permissions="compute.instances.list,compute.instances.get,storage.objects.list"
```

### Organization and Resource Hierarchy

```bash
# List organizations
gcloud organizations list

# Set organization policy
gcloud resource-manager org-policies set-policy policy.yaml \
    --organization=ORGANIZATION_ID

# Create folder
gcloud resource-manager folders create \
    --display-name="DevOps Folder" \
    --organization=ORGANIZATION_ID

# List projects
gcloud projects list

# Create project
gcloud projects create devops-project-$(date +%s) \
    --name="DevOps Project" \
    --folder=FOLDER_ID
```

## Monitoring and Logging

### Cloud Monitoring

```bash
# Create alerting policy
gcloud alpha monitoring policies create \
    --policy-from-file=alerting-policy.yaml

# List metrics
gcloud monitoring metrics list

# Create uptime check
gcloud monitoring uptime create devops-uptime-check \
    --hostname=example.com \
    --path=/ \
    --port=80

# Create notification channel
gcloud alpha monitoring channels create \
    --channel-content-from-file=notification-channel.yaml
```

### Cloud Logging

```bash
# View logs
gcloud logging read "resource.type=gce_instance" --limit=50

# Create log sink
gcloud logging sinks create devops-sink \
    storage.googleapis.com/devops-logs-bucket \
    --log-filter='resource.type="gce_instance"'

# Write log entry
gcloud logging write devops-log "Application started successfully" \
    --severity=INFO

# List log entries
gcloud logging entries list --filter='logName="projects/PROJECT_ID/logs/devops-log"'
```

### Error Reporting

```bash
# List error groups
gcloud error-reporting events list

# Report error (via client library)
# Python example:
from google.cloud import error_reporting
client = error_reporting.Client()
client.report_exception()
```

## DevOps Integration

### Cloud Build

```bash
# Submit build
gcloud builds submit --config=cloudbuild.yaml .

# Create build trigger
gcloud builds triggers create github \
    --repo-name=devops-repo \
    --repo-owner=myorg \
    --branch-pattern="^main$" \
    --build-config=cloudbuild.yaml

# List builds
gcloud builds list

# Get build logs
gcloud builds log BUILD_ID
```

#### Cloud Build Configuration

```yaml
# cloudbuild.yaml
steps:
  # Build Docker image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/devops-app:$BUILD_ID', '.']

# Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/devops-app:$BUILD_ID']

# Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'devops-service'
      - '--image=gcr.io/$PROJECT_ID/devops-app:$BUILD_ID'
      - '--region=us-central1'
      - '--platform=managed'
      - '--allow-unauthenticated'

# Build options
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_HIGHCPU_8'

# Substitutions
substitutions:
  _ENVIRONMENT: 'production'
  _REGION: 'us-central1'

# Timeout
timeout: '1200s'
```

### Container Registry and Artifact Registry

```bash
# Configure Docker for GCR
gcloud auth configure-docker

# Tag and push image to GCR
docker tag my-app:latest gcr.io/PROJECT_ID/my-app:latest
docker push gcr.io/PROJECT_ID/my-app:latest

# List images in GCR
gcloud container images list

# Create Artifact Registry repository
gcloud artifacts repositories create devops-repo \
    --repository-format=docker \
    --location=us-central1 \
    --description="DevOps Docker repository"

# Configure Docker for Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Push to Artifact Registry
docker tag my-app:latest us-central1-docker.pkg.dev/PROJECT_ID/devops-repo/my-app:latest
docker push us-central1-docker.pkg.dev/PROJECT_ID/devops-repo/my-app:latest
```

### Cloud Source Repositories

```bash
# Create repository
gcloud source repos create devops-repo

# Clone repository
gcloud source repos clone devops-repo

# List repositories
gcloud source repos list
```

## Infrastructure as Code

### Deployment Manager

```yaml
# deployment.yaml
resources:
- name: devops-vm
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
# Deploy with Deployment Manager
gcloud deployment-manager deployments create devops-deployment \
    --config=deployment.yaml

# Update deployment
gcloud deployment-manager deployments update devops-deployment \
    --config=deployment.yaml

# Delete deployment
gcloud deployment-manager deployments delete devops-deployment

# List deployments
gcloud deployment-manager deployments list
```

### Terraform with GCP

```hcl
# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "devops_vm" {
  name         = "devops-vm"
  machine_type = "e2-medium"
  zone         = var.zone

boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
      type  = "pd-standard"
    }
  }

network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

tags = ["http-server", "https-server"]

metadata_startup_script = file("startup-script.sh")
}

resource "google_storage_bucket" "devops_bucket" {
  name     = "${var.project_id}-devops-bucket"
  location = var.region

versioning {
    enabled = true
  }

lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}
```

## Security Best Practices

### Security Command Center

```bash
# List findings
gcloud scc findings list ORGANIZATION_ID

# Create notification config
gcloud scc notifications create devops-notification \
    --organization=ORGANIZATION_ID \
    --pubsub-topic=projects/PROJECT_ID/topics/security-notifications \
    --filter='state="ACTIVE"'

# List assets
gcloud scc assets list ORGANIZATION_ID
```

### Binary Authorization

```bash
# Create policy
gcloud container binauthz policy import policy.yaml

# Create attestor
gcloud container binauthz attestors create devops-attestor \
    --attestation-authority-note=projects/PROJECT_ID/notes/devops-note \
    --attestation-authority-note-project=PROJECT_ID

# List attestors
gcloud container binauthz attestors list
```

### VPC Security

```bash
# Create private cluster
gcloud container clusters create private-cluster \
    --zone=us-central1-a \
    --enable-private-nodes \
    --master-ipv4-cidr-block=172.16.0.0/28 \
    --enable-ip-alias \
    --cluster-ipv4-cidr=10.0.0.0/14 \
    --services-ipv4-cidr=10.4.0.0/19

# Create Cloud NAT
gcloud compute routers create devops-router \
    --network=devops-vpc \
    --region=us-central1

gcloud compute routers nats create devops-nat \
    --router=devops-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
```

## Cost Management

### Billing and Cost Control

```bash
# List billing accounts
gcloud billing accounts list

# Set project billing
gcloud billing projects link PROJECT_ID \
    --billing-account=BILLING_ACCOUNT_ID

# Create budget
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="DevOps Budget" \
    --budget-amount=1000USD

# Export billing data
gcloud billing accounts get-iam-policy BILLING_ACCOUNT_ID
```

### Resource Quotas

```bash
# List quotas
gcloud compute project-info describe --format="table(quotas.metric,quotas.limit,quotas.usage)"

# Request quota increase (via console or support)
```

### Committed Use Discounts

```bash
# List commitments
gcloud compute commitments list

# Create commitment
gcloud compute commitments create devops-commitment \
    --region=us-central1 \
    --plan=12-month \
    --resources=type=VCPU,amount=100 \
    --resources=type=MEMORY,amount=400
```

This comprehensive GCP fundamentals guide provides DevOps engineers with essential knowledge for effectively using Google Cloud Platform services in modern cloud infrastructure and application deployment workflows.

## Real World Scenarios

### Scenario 1: Multi-Cloud Strategy
**Context:** Startup wants to use GCP's data and AI services (BigQuery, Vertex AI) but their main app is on AWS.
**Solution:**
- **Interconnectivity:** Use Cloud VPN or Interconnect to link AWS VPC and GCP VPC.
- **Data Transfer:** Use Storage Transfer Service to move data to GCS.
- **Anthos:** Manage clusters on both clouds if needed.
**Benefit:** Best of breed services without full migration.

### Scenario 2: Project Organization for Agencies
**Context:** Agency manages 50 clients. Need separate billing and isolation.
**Solution:**
- **Organization Node:** Root.
- **Folders:** One per Client.
- **Projects:** One per Environment (Dev, Prod) inside Client Folder.
- **Billing:** Sub-billing accounts or separate billing accounts per client if needed (or chargeback).
**Benefit:** Clean isolation, easy billing export, proper IAM inheritance.

---

## Interview Questions

### Basic Level
1. **What is a "Project" in GCP?**
   - The base-level organizing entity. Resources (VMs, Buckets) belong to a project. Billing/IAM is enabled here.
2. **What is `gcloud`?**
   - The primary CLI tool to manage GCP resources.
3. **What is the "Resource Hierarchy"?**
   - Organization -> Folder -> Project -> Resource.

### Intermediate Level
4. **How do you switch projects in `gcloud`?**
   - `gcloud config set project [PROJECT_ID]`
5. **What is the difference between a Region and a Zone?**
   - **Region:** A geographical area (e.g., us-central1). Contains Zones.
   - **Zone:** A deployment area within a region (e.g., us-central1-a). Isolated power/networking failure domain.
6. **What is "Cloud Shell"?**
   - An interactive shell environment for GCP. It is a temporary VM (5GB home dir) with all tools pre-installed.

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Organization</b>
</details>


<b>2. Each resource belongs to exactly one...?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Project</b>
</details>


<b>3. Regional resources include:</b>
<details>
<summary>Show Answer</summary>
Answer: A) App Engine, Subnets</b>
</details>


<b>4. Default VPC mode is?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Auto Mode (One subnet per region)</b>
</details>


<b>5. To init the gcloud CLI locally?</b>
<details>
<summary>Show Answer</summary>
Answer: A) gcloud init (also handles login)</b>
</details>


<b>6. Cloud Billing Account is linked to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) One or more Projects</b>
</details>


<b>7. Service Account Email format?</b>
<details>
<summary>Show Answer</summary>
Answer: A) name@project-id.iam.gserviceaccount.com</b>
</details>


<b>8. Can you move a Project to a different Folder?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes</b>
</details>


<b>9. Pricing Calculator helps to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Estimate costs</b>
</details>


<b>10. Free Tier includes:</b>
<details>
<summary>Show Answer</summary>
Answer: A) $300 Credit (90 days) + Always Free limits</b>
</details>


<b>11. Where do you enable APIs?</b>
<details>
<summary>Show Answer</summary>
Answer: A) "APIs & Services" Dashboard</b>
</details>


<b>12. Global resources include:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Images, Snapshots, VPC Networks, Firewalls, Routes</b>
</details>


<b>13. Zonal resources include:</b>
<details>
<summary>Show Answer</summary>
Answer: A) VM Instances, Persistent Disks</b>
</details>


<b>14. Cloud Console is:</b>
<details>
<summary>Show Answer</summary>
Answer: A) A web-based GUI</b>
</details>


<b>15. Marketplace solutions often include:</b>
<details>
<summary>Show Answer</summary>
Answer: A) "Click to Deploy" functionality</b>
</details>


<b>16. IAM Policy Binding connects:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Member(s), Role, and Condition (optional)</b>
</details>


<b>17. Support Plans levels?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Basic, Standard, Enhanced, Premium</b>
</details>


<b>18. Can you undelete a Project?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, within 30 days usually (pending operations)</b>
</details>


<b>19. Budgets and Alerts can send notifications to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Email and Pub/Sub (for programmatic action)</b>
</details>


<b>20. "Spot VMs" are the successor to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Preemptible VMs (Wait, mostly yes, Spot is the new model with dynamic pricing)</b>
</details>
