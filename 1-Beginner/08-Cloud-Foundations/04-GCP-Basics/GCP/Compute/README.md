# Google Cloud Compute Services

Comprehensive guide to GCP compute services including Compute Engine, Cloud Run, and App Engine.

## Compute Engine
```bash
# Create VM instance
gcloud compute instances create my-instance \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=web-server

# List instances
gcloud compute instances list

# SSH into instance
gcloud compute ssh my-instance --zone=us-central1-a

# Start/Stop instance
gcloud compute instances start my-instance --zone=us-central1-a
gcloud compute instances stop my-instance --zone=us-central1-a

# Create instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=web-server

# Create managed instance group
gcloud compute instance-groups managed create web-group \
  --template=web-template \
  --size=3 \
  --zone=us-central1-a
```

## Cloud Run
```bash
# Deploy container to Cloud Run
gcloud run deploy my-service \
  --image=gcr.io/my-project/my-app:latest \
  --platform=managed \
  --region=us-central1 \
  --allow-unauthenticated

# Update service
gcloud run services update my-service \
  --region=us-central1 \
  --set-env-vars="ENV=production,DEBUG=false"

# Set traffic allocation
gcloud run services update-traffic my-service \
  --region=us-central1 \
  --to-revisions=my-service-v2=50,my-service-v1=50
```

## App Engine
```bash
# Deploy to App Engine
gcloud app deploy app.yaml

# Set traffic splitting
gcloud app services set-traffic default \
  --splits=v1=50,v2=50

# View logs
gcloud app logs tail -s default

# Create cron jobs
gcloud app deploy cron.yaml
```

## Google Kubernetes Engine (GKE)
```bash
# Create GKE cluster
gcloud container clusters create my-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --enable-autoscaling \
  --min-nodes=1 \
  --max-nodes=10

# Get credentials
gcloud container clusters get-credentials my-cluster --zone=us-central1-a

# Deploy application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

This guide covers GCP compute services for scalable application deployment.