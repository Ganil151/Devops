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