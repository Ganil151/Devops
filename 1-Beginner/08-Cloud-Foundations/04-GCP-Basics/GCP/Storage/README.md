# Google Cloud Storage Services

Comprehensive guide to GCP storage solutions including Cloud Storage, Persistent Disks, and databases.

## Cloud Storage
```bash
# Create bucket
gsutil mb gs://my-unique-bucket-name

# Upload file
gsutil cp myfile.txt gs://my-unique-bucket-name/

# Download file
gsutil cp gs://my-unique-bucket-name/myfile.txt ./downloaded-file.txt

# Sync directory
gsutil -m rsync -r ./local-directory gs://my-unique-bucket-name/remote-directory

# Set bucket lifecycle
gsutil lifecycle set lifecycle.json gs://my-unique-bucket-name

# Enable versioning
gsutil versioning set on gs://my-unique-bucket-name

# Set public access
gsutil iam ch allUsers:objectViewer gs://my-unique-bucket-name
```

## Persistent Disks
```bash
# Create persistent disk
gcloud compute disks create my-disk \
  --size=100GB \
  --zone=us-central1-a \
  --type=pd-ssd

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
  --disk=my-disk \
  --zone=us-central1-a

# Create snapshot
gcloud compute disks snapshot my-disk \
  --snapshot-names=my-snapshot \
  --zone=us-central1-a

# Create disk from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=my-snapshot \
  --zone=us-central1-a
```

## Cloud SQL
```bash
# Create Cloud SQL instance
gcloud sql instances create my-instance \
  --database-version=MYSQL_8_0 \
  --tier=db-n1-standard-1 \
  --region=us-central1

# Create database
gcloud sql databases create mydatabase \
  --instance=my-instance

# Create user
gcloud sql users create myuser \
  --instance=my-instance \
  --password=mypassword

# Connect to instance
gcloud sql connect my-instance --user=root
```

## Firestore
```bash
# Create Firestore database
gcloud firestore databases create --region=us-central

# Import data
gcloud firestore import gs://my-bucket/export-folder

# Export data
gcloud firestore export gs://my-bucket/export-folder
```

This guide covers GCP storage services for data management and persistence.