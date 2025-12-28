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

### Advanced Level
7. **What is GKE Autopilot?**
   - A mode of operation in GKE where Google manages the node configuration, scaling, and security. You pay for pods resources, not nodes.
8. **Discounts: Sustained Use vs. Committed Use.**
   - **Sustained:** Automatic discount for running VMs for a significant portion of the month.
   - **Committed:** Contract for 1 or 3 years for deeper discounts (like AWS Reserved Instances).
9. **What is "Sole-tenant nodes"?**
   - Physical servers dedicated to your project only. Used for compliance (BYOL) or strict isolation requirements.

---

## Quiz: GCP Compute

<details>
<summary><b>1. What is the command to create a VM?</b></summary>
A) gcloud compute instances create<br>
B) gcloud vm create<br>
C) gcloud create instance<br>
D) gcloud maker vm<br>
<br>
<b>Answer: A) gcloud compute instances create</b>
</details>

<details>
<summary><b>2. Which service is best for event-driven serverless functions?</b></summary>
A) Cloud Functions<br>
B) Compute Engine<br>
C) GKE<br>
D) Bare Metal<br>
<br>
<b>Answer: A) Cloud Functions</b>
</details>

<details>
<summary><b>3. Live Migration is a feature of:</b></summary>
A) Compute Engine<br>
B) Cloud Storage<br>
C) VPC<br>
D) None<br>
<br>
<b>Answer: A) Compute Engine</b>
</details>

<details>
<summary><b>4. GKE stands for:</b></summary>
A) Google Kubernetes Engine<br>
B) Google Kernel Engine<br>
C) Global Kubernetes Environment<br>
D) Great King Edward<br>
<br>
<b>Answer: A) Google Kubernetes Engine</b>
</details>

<details>
<summary><b>5. For auto-scaling VMs, you should use:</b></summary>
A) Managed Instance Groups (MIG)<br>
B) Unmanaged Instance Groups<br>
C) Just many VMs<br>
D) Cron script<br>
<br>
<b>Answer: A) Managed Instance Groups (MIG)</b>
</details>

<details>
<summary><b>6. Cloud Run scales to:</b></summary>
A) Zero (0)<br>
B) One (1)<br>
C) Min 2<br>
D) Infinity only<br>
<br>
<b>Answer: A) Zero (0)</b>
</details>

<details>
<summary><b>7. App Engine "Standard" environment is optimized for:</b></summary>
A) Rapid scaling and specific languages (Python, Java, Go, etc.)<br>
B) Custom containers<br>
C) Windows Server<br>
D) GPUs<br>
<br>
<b>Answer: A) Rapid scaling and specific languages (Python, Java, Go, etc.)</b>
</details>

<details>
<summary><b>8. Preemptible VMs can be stopped by Google after:</b></summary>
A) 24 hours (or sooner if needed)<br>
B) 1 hour<br>
C) 7 days<br>
D) Never<br>
<br>
<b>Answer: A) 24 hours (or sooner if needed)</b>
</details>

<details>
<summary><b>9. Which GKE mode manages nodes for you?</b></summary>
A) Autopilot<br>
B) Standard<br>
C) Legacy<br>
D) Manual<br>
<br>
<b>Answer: A) Autopilot</b>
</details>

<details>
<summary><b>10. To run a Windows Server, you use:</b></summary>
A) Compute Engine<br>
B) Cloud Functions<br>
C) App Engine Standard<br>
D) BigQuery<br>
<br>
<b>Answer: A) Compute Engine</b>
</details>

<details>
<summary><b>11. What is a "Custom Machine Type"?</b></summary>
A) You pick exact CPU and RAM count<br>
B) A robot<br>
C) A painted server<br>
D) A legacy type<br>
<br>
<b>Answer: A) You pick exact CPU and RAM count</b>
</details>

<details>
<summary><b>12. Cloud Functions 2nd Gen is built on:</b></summary>
A) Cloud Run and Eventarc<br>
B) App Engine<br>
C) Bare Metal<br>
D) Angular<br>
<br>
<b>Answer: A) Cloud Run and Eventarc</b>
</details>

<details>
<summary><b>13. Which command connects simply to a VM via SSH?</b></summary>
A) gcloud compute ssh [INSTANCE_NAME]<br>
B) ssh root@ip<br>
C) gcloud connect<br>
D) gcloud login<br>
<br>
<b>Answer: A) gcloud compute ssh [INSTANCE_NAME]</b>
</details>

<details>
<summary><b>14. "Committed Use Discounts" require:</b></summary>
A) 1 or 3 year contract<br>
B) Upfront payment only<br>
C) Using Spot instances<br>
D) None<br>
<br>
<b>Answer: A) 1 or 3 year contract</b>
</details>

<details>
<summary><b>15. Does Compute Engine support GPUs?</b></summary>
A) Yes (NVIDIA Tesla, etc.)<br>
B) No<br>
<br>
<b>Answer: A) Yes (NVIDIA Tesla, etc.)</b>
</details>

<details>
<summary><b>16. What is "Cloud Shell"?</b></summary>
A) Temporary VM with gcloud/tools pre-installed, accessible via browser<br>
B) A storage service<br>
C) A database<br>
D) A cost tool<br>
<br>
<b>Answer: A) Temporary VM with gcloud/tools pre-installed, accessible via browser</b>
</details>

<details>
<summary><b>17. Which is a regional resource?</b></summary>
A) Global Address<br>
B) Static IP (can be regional or global)<br>
C) Disk (Zonal or Regional)<br>
D) Subnet (Regional)<br>
<br>
<b>Answer: D) Subnet (Regional)</b>
</details>

<details>
<summary><b>18. Can you run containers on Compute Engine (COs)?</b></summary>
A) Yes, using "Container-Optimized OS"<br>
B) No<br>
<br>
<b>Answer: A) Yes, using "Container-Optimized OS"</b>
</details>

<details>
<summary><b>19. Auto-healing in MIGs relies on:</b></summary>
A) Health Checks<br>
B) Magic<br>
C) Manual intervention<br>
D) Billing<br>
<br>
<b>Answer: A) Health Checks</b>
</details>

<details>
<summary><b>20. Does stopping a VM stop billing?</b></summary>
A) Yes for compute, No for storage (disk)<br>
B) Yes for everything<br>
C) No<br>
D) Only on weekends<br>
<br>
<b>Answer: A) Yes for compute, No for storage (disk)</b>
</details>

<details>
<summary><b>21. Max duration of a Cloud Function?</b></summary>
A) 9 minutes (1st gen), 60 mins (2nd gen)<br>
B) 10 seconds<br>
C) 24 hours<br>
D) Unlimited<br>
<br>
<b>Answer: A) 9 minutes (1st gen), 60 mins (2nd gen)</b>
</details>