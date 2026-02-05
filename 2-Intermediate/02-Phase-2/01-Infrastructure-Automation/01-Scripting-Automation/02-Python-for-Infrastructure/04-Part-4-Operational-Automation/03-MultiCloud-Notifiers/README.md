# ☁️ Multi-Cloud Notifiers: Universal Alerting

In a modern enterprise, you might run workloads on AWS, but store backup logs in Azure or run data processing in GCP. Your alerting system should be **Unified**.

## 🚀 Key Concept: Cloud Detection
A "Smart Notifier" should be able detect its environment by querying local metadata services:
*   **AWS**: `http://169.254.169.254/latest/meta-data/`
*   **Azure**: `http://169.254.169.254/metadata/instance?api-version=2021-02-01`
*   **GCP**: `http://metadata.google.internal/computeMetadata/v1/`

## 🛠️ The Staff Standard: The `notify.py` Module
Instead of writing Slack code in every script, create a single, clean module that handles the complexity of headers, blocks, and routing. In this lab, we build a script that aggregates cloud-specific metadata and sends it to a central channel.

## 🥅 Governance
When using multi-cloud notifiers, use a **Global Prefix** in your messages (e.g., `[AWS-PROD]` or `[AZURE-DR]`). This allows SREs to filter and route messages in their Slack client easily.

---

## 💻 Lab: The Universal Cloud Notifier
See `lab.py` for a script that detects environment metadata and routes it to Slack.
