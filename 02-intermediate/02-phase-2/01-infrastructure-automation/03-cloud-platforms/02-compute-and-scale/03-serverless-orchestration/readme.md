# ⚡ Serverless Orchestration

Serverless computing allows you to build and run applications and services without thinking about servers. It eliminates infrastructure management tasks such as server or cluster provisioning, patching, operating system maintenance, and capacity provisioning.

## 🚀 The Serverless Mindset
In Serverless, you deal with **Functions** and **Events**.
- **Event-Driven**: Your code only runs when triggered (e.g., an S3 upload, an HTTP request, a database change).
- **Sub-second Billing**: You are charged only for the execution time (GB-seconds).
- **Auto-Scale to Zero**: If no one is using your app, you pay nothing.

---

## 🏗️ Cross-Cloud Serverless Ecosystem

| Feature | AWS Lambda | Azure Functions | GCP Cloud Functions |
| :--- | :--- | :--- | :--- |
| **Scaling** | Highly elastic (concurrency) | Consumption plan | Automatic instances |
| **Max Timeout** | 15 Minutes | 10 Minutes (Consumption) | 9 Minutes |
| **Triggers** | 200+ AWS Services | Event Grid / Service Bus | Pub/Sub / Cloud Storage |
| **State** | Stateless (use DynamoDB/Redis)| Stateful (Durable Functions) | Stateless (use Firestore) |

---

## 📂 Cloud Offerings
- [AWS-Lambda](./AWS-Lambda): The industry standard for event-driven compute.
- [Azure-Functions](./Azure-Functions): Powerful bindings and integration with .NET ecosystem.
- [GCP-Cloud-Functions](./GCP-Cloud-Functions): Google's lightweight response to cloud events.
