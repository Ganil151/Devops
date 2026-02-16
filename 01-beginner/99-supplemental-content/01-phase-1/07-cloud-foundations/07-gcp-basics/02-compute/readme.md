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

## Real World Scenarios

### Scenario 1: Cost Optimization with Preemptible VMs
**Context:** Batch processing job runs every night, fault-tolerant.
**Solution:**
- **Preemptible VMs:** Use Preemptible instances (similar to AWS Spot) for 80% cost savings.
- **MIG:** Use a Managed Instance Group to auto-replace if preempted.
**Benefit:** Significant cost reduction for stateless/batch workloads.

### Scenario 2: Containerizing Legacy Apps
**Context:** Old Java app needs to move to cloud but not ready for K8s complexity.
**Solution:**
- **Cloud Run:** Containerize the app and deploy to Cloud Run.
- **Serverless:** No server management, auto-scaling to zero.
**Benefit:** Modernization without K8s overhead.

---

## Interview Questions

### Basic Level
1. **What is Google Compute Engine (GCE)?**
   - GCP's IaaS offering. Virtual Machines running on Google's infrastructure.
2. **What is the difference between Cloud Run and App Engine?**
   - **Cloud Run:** Runs any container (stateless). Serverless.
   - **App Engine:** PaaS for building apps in specific languages (Standard) or containers (Flexible).
3. **What is a "Machine Type"?**
   - Defines the CPU and RAM resources for a VM (e.g., `e2-medium`, `n1-standard-1`).

### Intermediate Level
4. **What is a Managed Instance Group (MIG)?**
   - A collection of identical VMs managed as a single entity. Supports auto-scaling, auto-healing, and rolling updates.
5. **How does Live Migration work in GCP?**
   - Google keeps your VM running even when a host system event (software update, hardware failure) occurs. It migrates the running instance to another host.
6. **Explain "Shielded VMs".**
   - VMs hardened by a set of security controls (Secure Boot, vTPM, Integrity Monitoring) to defend against rootkits/bootkits.

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) gcloud compute instances create</b>
</details>


<b>2. Which service is best for event-driven serverless functions?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Cloud Functions</b>
</details>


<b>3. Live Migration is a feature of:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Compute Engine</b>
</details>


<b>4. GKE stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Google Kubernetes Engine</b>
</details>


<b>5. For auto-scaling VMs, you should use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Managed Instance Groups (MIG)</b>
</details>


<b>6. Cloud Run scales to:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Zero (0)</b>
</details>


<b>7. App Engine "Standard" environment is optimized for:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Rapid scaling and specific languages (Python, Java, Go, etc.)</b>
</details>


<b>8. Preemptible VMs can be stopped by Google after:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 24 hours (or sooner if needed)</b>
</details>


<b>9. Which GKE mode manages nodes for you?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Autopilot</b>
</details>


<b>10. To run a Windows Server, you use:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Compute Engine</b>
</details>


<b>11. What is a "Custom Machine Type"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) You pick exact CPU and RAM count</b>
</details>


<b>12. Cloud Functions 2nd Gen is built on:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Cloud Run and Eventarc</b>
</details>


<b>13. Which command connects simply to a VM via SSH?</b>
<details>
<summary>Show Answer</summary>
Answer: A) gcloud compute ssh [INSTANCE_NAME]</b>
</details>


<b>14. "Committed Use Discounts" require:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 1 or 3 year contract</b>
</details>


<b>15. Does Compute Engine support GPUs?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes (NVIDIA Tesla, etc.)</b>
</details>


<b>16. What is "Cloud Shell"?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Temporary VM with gcloud/tools pre-installed, accessible via browser</b>
</details>


<b>17. Which is a regional resource?</b>
<details>
<summary>Show Answer</summary>
Answer: D) Subnet (Regional)</b>
</details>


<b>18. Can you run containers on Compute Engine (COs)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes, using "Container-Optimized OS"</b>
</details>


<b>19. Auto-healing in MIGs relies on:</b>
<details>
<summary>Show Answer</summary>
Answer: A) Health Checks</b>
</details>


<b>20. Does stopping a VM stop billing?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Yes for compute, No for storage (disk)</b>
</details>


<b>21. Max duration of a Cloud Function?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 9 minutes (1st gen), 60 mins (2nd gen)</b>
</details>
