# ❓ GCP Config Connector Interview & Quiz Questions

## 📋 Interview Questions

**Q1: What is the primary advantage of using Config Connector over Deployment Manager or Terraform?**
**A:** The primary advantage is **GitOps integration** and **continuous reconciliation**. Because it runs as a Kubernetes controller, it constantly monitors for drift and corrects it automatically. It also allows managing app and infra using the same toolset (`kubectl`).

**Q2: Explain 'Workload Identity' in the context of Config Connector.**
**A:** Config Connector uses Workload Identity to bind a Kubernetes Service Account (KSA) to a Google Service Account (GSA). This ensures that the controller has the necessary GCP permissions to manage resources without using long-lived secrets or keys.

**Q3: What are the two main installation modes?**
**A:** 
- **Namespaced Mode**: Links specific namespaces to specific GCP projects (most common for multi-tenant environments).
- **Cluster Mode**: A single project provides all resources (simpler for single-project setups).

**Q4: How do you prevent a cloud resource from being deleted when the K8s object is deleted?**
**A:** By using the annotation `cnrm.cloud.google.com/deletion-policy: "abandon"`.

**Q5: Where do you check for errors if a resource fails to provision?**
**A:** First, check the `status` field of the Kubernetes resource using `kubectl describe`. If that's not enough, check the logs of the Config Connector operator pod in the `cnrm-system` namespace.

---

## 📝 Quiz Section (20+ Questions)

1. **Config Connector runs on which platform?**
   - A) AWS Lambda
   - B) Bare Metal Linux
   - C) Kubernetes (GKE or elsewhere) ✅
   - D) GCP Cloud Shell only

2. **Which command is used to apply a Config Connector manifest?**
   - A) gcloud apply
   - B) kubectl apply ✅
   - C) config-connector deploy
   - D) terraform apply

3. **What does CRD stand for?**
   - A) Cloud Resource Deployment
   - B) Custom Resource Definition ✅
   - C) Central Roadmap Document
   - D) Core Resource Data

4. **In Namespaced mode, where is the GCP Project ID usually defined?**
   - A) In the `cdk.json`
   - B) In the `ConfigConnectorContext` object for the namespace ✅
   - C) In the VM metadata
   - D) In the CLI arguments

5. **Which annotation allows CC to manage a resource without modifying it?**
   - A) mode: read-only
   - B) cnrm.cloud.google.com/management-mode: "unmanaged" ✅
   - C) sync: false
   - D) state: external

6. **What is the default behavior when a K8s object is deleted?**
   - A) The cloud resource is also deleted ✅
   - B) The cloud resource is kept
   - C) A snapshot is taken
   - D) An alert is sent

7. **How does CC handle resource secrets like database passwords?**
   - A) Prints them to the console
   - B) Stores them in Kubernetes Secrets ✅
   - C) Stores them in a local file
   - D) Deletes them after use

8. **Which field in the resource confirms it successfully deployed to GCP?**
   - A) spec.ready
   - B) status.conditions[Ready].status == True ✅
   - C) metadata.deployed
   - D) status.gcpStatus

9. **Can Config Connector manage IAM policies?**
   - A) No
   - B) Yes, via `IAMPolicy` and `IAMPolicyMember` resources ✅
   - C) Only via the console
   - D) Only for S3 buckets

10. **What is 'Config Sync'?**
    - A) A tool to sync files between VMs
    - B) A Google service used to sync Git repositories with Kubernetes clusters, often used with CC for GitOps ✅
    - C) A mobile app
    - D) A backup tool

11. **Which resource type is used for GCS buckets?**
    - A) CloudStorage
    - B) StorageBucket ✅
    - C) S3Bucket
    - D) ObjectStore

12. **Which namespace contains the Config Connector operator pods?**
    - A) default
    - B) kube-system
    - C) cnrm-system ✅
    - D) gcp-connector

13. **What happens if the GCP API is down?**
    - A) The K8s cluster crashes
    - B) CC keeps retrying according to its reconciliation loop ✅
    - C) All resources are deleted
    - D) The user is logged out

14. **Which annotation is used to refer to a resource in another namespace?**
    - A) external-namespace
    - B) resourceRef ✅ (with proper fields)
    - C) cross-link
    - D) scope: global

15. **What is 'Reconciliation' in the context of CC?**
    - A) Calculating bills
    - B) The process of aligning the actual state in GCP with the desired state in K8s YAML ✅
    - C) Merging code branches
    - D) Authenticating users

16. **How do you 'import' an existing bucket named 'prod-data'?**
    - A) Run `cc import bucket prod-data`
    - B) Create a StorageBucket YAML with the name 'prod-data' and apply it ✅
    - C) Use the `fetch` command
    - D) It's not possible

17. **Which tool is often used to visualize Config Connector resources?**
   - A) GCP Console (under Kubernetes Engine > Config) ✅
   - B) Google Maps
   - C) Windows Task Manager
   - D) SQL Server Management Studio

18. **Can Config Connector work in multi-cloud environments?**
    - A) No
    - B) Yes, you can run it on Anthos in other clouds to manage GCP resources ✅
    - C) Only if using AWS
    - D) Only on-premises

19. **What is the 'cnrm-controller-manager'?**
    - A) A human manager at Google
    - B) The pod responsible for executing the reconciliation logic ✅
    - C) A CLI tool
    - D) A browser extension

20. **Which resource is used to represent a GCP billing account?**
    - A) BillingAccount ✅
    - B) MoneyBag
    - C) AccountInfo
    - D) GCPCost

21. **How long is the default reconciliation period?**
    - A) 1 second
    - B) 1 hour
    - C) 10 minutes ✅ (Though adjustable)
    - D) Only on-demand
    - 
