# GCP Cloud Functions: Scalable Event Ingestion

Google Cloud Functions is a lightweight, compute solution for developers to create single-purpose, stand-alone functions that respond to cloud events without the need to manage a server or a runtime environment.

## 🚀 The "DevOps Why": Event-Driven Microservices
GCP Cloud Functions (GCF) is designed for high-velocity event processing within the Google ecosystem (Pub/Sub, Firebase, Cloud Storage).
- **Simplicity**: Zero server management. Deploy code via `gcloud` or Terraform and let Google handle the rest.
- **Google Ecosystem Tie-in**: Best-in-class integration with BigQuery and Google's ML APIs.
- **Agile Scaling**: Each instance handles one request at a time (Gen 1) or multiple (Gen 2), scaling instantly to handle traffic bursts.

---

## 🏗️ Core Mechanics

### 1. Generational Differences
- **Gen 1**: Traditional GCF. Limits on concurrency and execution time.
- **Gen 2**: Built on **Cloud Run** and **Knative**. Supports longer runtimes (up to 60 mins for HTTP), larger instances (16GB RAM), and concurrency (multiple requests per instance).

### 2. Event Types
- **HTTP Functions**: Triggered via webhooks or standard HTTP requests.
- **Event-Driven Functions**: Triggered by background events seperti:
    - **Cloud Storage**: File upload/delete.
    - **Pub/Sub**: New message arrival.
    - **Firestore**: Database changes.

---

## 🛠️ Infrastructure as Code (Terraform)
Deploying a GCF Gen 2 instance:

```hcl
resource "google_cloudfunctions2_function" "function" {
  name        = "gcf-event-processor"
  location    = "us-central1"
  description = "Processes events from Pub/Sub"

  build_config {
    runtime     = "python310"
    entry_point = "process_event"
    source {
      storage_source {
        bucket = google_storage_bucket.source_bucket.name
        object = google_storage_bucket_object.source_zip.name
      }
    }
  }

  service_config {
    max_instance_count  = 10
    available_memory    = "256Mi"
    timeout_seconds     = 60
  }
}
```

---

## 📂 Real-World Scenario: Real-time Log Audit
**Scenario**: A security audit requires all `IAM` changes to be logged and checked for compliance.
**The Solution**:
1. **Cloud Logging** exports IAM logs to a **Pub/Sub** topic.
2. A **Cloud Function** is triggered by the Pub/Sub message.
3. The function checks the change against a policy (e.g., "No Public S3 Buckets").
4. If non-compliant, it triggers an alert via Slack and logs the event to BigQuery.
