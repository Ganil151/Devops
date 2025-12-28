# Google Cloud Security

Comprehensive guide to GCP security services including IAM, Cloud KMS, and Security Command Center.

## Identity and Access Management (IAM)
```bash
# List IAM policies
gcloud projects get-iam-policy my-project

# Add IAM policy binding
gcloud projects add-iam-policy-binding my-project \
  --member="user:john@example.com" \
  --role="roles/compute.instanceAdmin"

# Create service account
gcloud iam service-accounts create my-service-account \
  --display-name="My Service Account"

# Generate service account key
gcloud iam service-accounts keys create key.json \
  --iam-account=my-service-account@my-project.iam.gserviceaccount.com

# Create custom role
gcloud iam roles create myCustomRole \
  --project=my-project \
  --title="My Custom Role" \
  --description="Custom role for specific permissions" \
  --permissions="compute.instances.get,compute.instances.list"
```

## Cloud Key Management Service (KMS)
```bash
# Create key ring
gcloud kms keyrings create my-keyring \
  --location=us-central1

# Create crypto key
gcloud kms keys create my-key \
  --location=us-central1 \
  --keyring=my-keyring \
  --purpose=encryption

# Encrypt file
gcloud kms encrypt \
  --key=my-key \
  --keyring=my-keyring \
  --location=us-central1 \
  --plaintext-file=plaintext.txt \
  --ciphertext-file=ciphertext.enc

# Decrypt file
gcloud kms decrypt \
  --key=my-key \
  --keyring=my-keyring \
  --location=us-central1 \
  --ciphertext-file=ciphertext.enc \
  --plaintext-file=decrypted.txt
```

## Secret Manager
```bash
# Create secret
gcloud secrets create my-secret \
  --data-file=secret.txt

# Access secret
gcloud secrets versions access latest \
  --secret=my-secret

# Add new version
echo "new-secret-value" | gcloud secrets versions add my-secret \
  --data-file=-

# Grant access to secret
gcloud secrets add-iam-policy-binding my-secret \
  --member="serviceAccount:my-service-account@my-project.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## Security Command Center
```bash
# List findings
gcloud scc findings list organizations/123456789

# Create notification config
gcloud scc notifications create my-notification \
  --organization=123456789 \
  --pubsub-topic=projects/my-project/topics/scc-notifications \
  --filter='state="ACTIVE"'

# List assets
gcloud scc assets list organizations/123456789
```

## Binary Authorization
```bash
# Create policy
gcloud container binauthz policy import policy.yaml

# Create attestor
gcloud container binauthz attestors create my-attestor \
  --attestation-authority-note=projects/my-project/notes/my-note

# Sign image
gcloud container binauthz attestations sign-and-create \
  --artifact-url=gcr.io/my-project/my-image:latest \
  --attestor=my-attestor \
  --keyversion=projects/my-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key/cryptoKeyVersions/1
```

This guide covers GCP security services for identity management and data protection.

## Real World Scenarios

### Scenario 1: Auditing Admin Access
**Context:** Need to track who created/deleted VMs in the last 7 days.
**Solution:**
- **Cloud Audit Logs:** Admin Activity logs are on by default and immutable.
- **Log Explorer:** Query `protoPayload.methodName="beta.compute.instances.insert"`.
**Benefit:** Full visibility and compliance tracking.

### Scenario 2: Preventing Data Exfiltration
**Context:** Ensure sensitive data in VPC cannot be sent to unknown public IPs.
**Solution:**
- **VPC Service Controls:** Define a Service Perimeter.
- **Egress Rules:** Deny egress to internet, only allow access to specific Google Services (BigQuery).
**Benefit:** Mitigates data exfiltration risks.

---

## Interview Questions

### Basic Level
1. **What is Cloud IAM?**
   - Identity and Access Management. Controls Who (Identity) can do What (Role) on Which Resource.
2. **What is a Service Account?**
   - A special Google account that belongs to an application/VM, not a person. Used for machine-to-machine auth.
3. **What are the 3 types of roles?**
   - **Basic (Primitive):** Owner, Editor, Viewer. (Avoid in prod).
   - **Predefined:** Granular roles created by Google (e.g., `roles/storage.objectViewer`).
   - **Custom:** You define exact permissions.

### Intermediate Level
4. **What is Identity-Aware Proxy (IAP)?**
   - Guard access to your apps/VMs using identity (login) rather than VPNs. Allows SSH/RDP without public IPs.
5. **What is Cloud KMS?**
   - Key Management Service. Manage encryption keys (Customer-Managed Encryption Keys - CMEK).
6. **Explain VPC Service Controls.**
   - Creates a security perimeter around your resources (buckets, datasets) to constrain data within the boundary.

### Advanced Level
7. **What is Binary Authorization?**
   - Supply-chain security. Ensures only trusted/signed container images are deployed to GKE.
8. **What is "Workload Identity"?**
   - recommended way for GKE workloads to authenticate to GCP APIs. It maps K8s Service Accounts to GCP Service Accounts.
9. **Difference between CMEK vs CSEK.**
   - **CMEK:** Customer-Managed (You manage key in KMS, Google uses it).
   - **CSEK:** Customer-Supplied (You keep the key, send it with request, Google never stores it).

---

## Quiz: GCP Security

<details>
<summary><b>1. IAM permissions are assigned via:</b></summary>
A) Roles<br>
B) Directly to users<br>
C) Groups only<br>
D) Emails<br>
<br>
<b>Answer: A) Roles</b>
</details>

<details>
<summary><b>2. Lowest privilege Basic Role is:</b></summary>
A) Viewer<br>
B) Editor<br>
C) Owner<br>
D) Admin<br>
<br>
<b>Answer: A) Viewer</b>
</details>

<details>
<summary><b>3. Service Accounts key files are usually:</b></summary>
A) JSON<br>
B) XML<br>
C) YAML<br>
D) Binary<br>
<br>
<b>Answer: A) JSON</b>
</details>

<details>
<summary><b>4. Which service stores API keys and passwords?</b></summary>
A) Secret Manager<br>
B) Storage<br>
C) IAM<br>
D) Compute<br>
<br>
<b>Answer: A) Secret Manager</b>
</details>

<details>
<summary><b>5. Security Command Center is:</b></summary>
A) Central dashboard for vulnerability and threat reporting<br>
B) A firewall<br>
C) A specialized VM<br>
D) A police station<br>
<br>
<b>Answer: A) Central dashboard for vulnerability and threat reporting</b>
</details>

<details>
<summary><b>6. IAP stands for:</b></summary>
A) Identity-Aware Proxy<br>
B) Internet Access Protocol<br>
C) Internal App Proxy<br>
D) Identity Access Point<br>
<br>
<b>Answer: A) Identity-Aware Proxy</b>
</details>

<details>
<summary><b>7. Predefined Roles are maintained by:</b></summary>
A) Google<br>
B) You<br>
C) Nobody<br>
D) AI<br>
<br>
<b>Answer: A) Google</b>
</details>

<details>
<summary><b>8. Can you use IAM Conditions?</b></summary>
A) Yes (e.g., grant access only on weekdays or based on IP)<br>
B) No<br>
<br>
<b>Answer: A) Yes (e.g., grant access only on weekdays or based on IP)</b>
</details>

<details>
<summary><b>9. Organization Policy Service allows:</b></summary>
A) Setting constraints across the hierarchy (e.g., "Disable Serial Port Access" or "Restrict Locations")<br>
B) RBAC<br>
C) Billing<br>
D) Nothing<br>
<br>
<b>Answer: A) Setting constraints across the hierarchy (e.g., "Disable Serial Port Access" or "Restrict Locations")</b>
</details>

<details>
<summary><b>10. Data at rest in GCP is encrypted:</b></summary>
A) By default<br>
B) Never<br>
C) Only if paid<br>
D) Only in US<br>
<br>
<b>Answer: A) By default</b>
</details>

<details>
<summary><b>11. Cloud DLP (Data Loss Prevention) helps:</b></summary>
A) Discover, classify, and redact sensitive data (PII, Credit Cards)<br>
B) Delete data<br>
C) Lose data<br>
D) Save money<br>
<br>
<b>Answer: A) Discover, classify, and redact sensitive data (PII, Credit Cards)</b>
</details>

<details>
<summary><b>12. What is the "Organization" node?</b></summary>
A) The root node of the GCP resource hierarchy<br>
B) A folder<br>
C) A project<br>
D) A user<br>
<br>
<b>Answer: A) The root node of the GCP resource hierarchy</b>
</details>

<details>
<summary><b>13. Access Transparency Logs do what?</b></summary>
A) Log when Google Support accesses your content<br>
B) Make logs transparent<br>
C) Delete logs<br>
D) Nothing<br>
<br>
<b>Answer: A) Log when Google Support accesses your content</b>
</details>

<details>
<summary><b>14. Cloud Armor Policies are attached to:</b></summary>
A) Load Balancer Backend Services<br>
B) VMs<br>
C) VPCs<br>
D) Buckets<br>
<br>
<b>Answer: A) Load Balancer Backend Services</b>
</details>

<details>
<summary><b>15. Is MFA supported in Cloud Identity?</b></summary>
A) Yes (2-Step Verification)<br>
B) No<br>
<br>
<b>Answer: A) Yes (2-Step Verification)</b>
</details>

<details>
<summary><b>16. Shielded VMs use:</b></summary>
A) vTPM and Secure Boot<br>
B) Antivirus<br>
C) Firewalls<br>
D) Magic<br>
<br>
<b>Answer: A) vTPM and Secure Boot</b>
</details>

<details>
<summary><b>17. Which principle should you follow for IAM?</b></summary>
A) Least Privilege<br>
B) Most Privilege<br>
C) All Access<br>
D) Random Access<br>
<br>
<b>Answer: A) Least Privilege</b>
</details>

<details>
<summary><b>18. Workload Identity Federation allows:</b></summary>
A) AWS/Azure/On-prem identities to access GCP resources without service account keys<br>
B) Merging clouds<br>
C) Sharing passwds<br>
D) Nothing<br>
<br>
<b>Answer: A) AWS/Azure/On-prem identities to access GCP resources without service account keys</b>
</details>

<details>
<summary><b>19. Event Threat Detection is part of:</b></summary>
A) Security Command Center Premium<br>
B) Free tier<br>
C) Compute Engine<br>
D) GKE<br>
<br>
<b>Answer: A) Security Command Center Premium</b>
</details>

<details>
<summary><b>20. Recaptcha Enterprise helps prevent:</b></summary>
A) Bot attacks and fraud<br>
B) Viruses<br>
C) DDoS<br>
D) Spam<br>
<br>
<b>Answer: A) Bot attacks and fraud</b>
</details>

<details>
<summary><b>21. Does GCP have a Directory Service?</b></summary>
A) Cloud Identity (or Managed Service for Microsoft AD)<br>
B) No<br>
<br>
<b>Answer: A) Cloud Identity (or Managed Service for Microsoft AD)</b>
</details>