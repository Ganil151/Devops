# 🧪 Hands-On Labs & Challenges

## Lab 1: "The Multi-Cloud Bridge"
**Objective**: Architecture a cross-cloud event-driven workflow.

### Scenario
An enterprise uses AWS for its primary data ingestion but leverages Azure for its specialized machine learning functions. You need to trigger an Azure Function whenever a new message arrives in an AWS SQS queue.

### Architecture
1. **Producer**: A script (Python) sending JSON data to an **AWS SQS** queue.
2. **Bridge**: An AWS Lambda function acting as a "Forwarder".
3. **Consumer**: An **Azure Function** (HTTP Triggered) that receives the data and processes it.

### Your Tasks
- [ ] Create an AWS SQS queue using Terraform.
- [ ] Create an Azure Function app with an HTTP endpoint.
- [ ] Write a Lambda function that:
    - Triggers on SQS messages.
    - Sends a POST request to the Azure Function URL.
    - Implements basic authentication (Function Key).
- [ ] Verify the message flow from AWS console to Azure monitoring.

---

## Lab 2: "Zero-Downtime Deployment"
**Objective**: Configure a Load Balancer to perform a Blue/Green deployment strategy.

### Scenario
Your application `v1` (Blue) is running. You want to deploy `v2` (Green) and switch traffic only after `v2` is fully verified, with the ability to roll back instantly.

### Infrastructure (IaC: Terraform or Bicep)
1. **Load Balancer**: A single ALB (AWS) or Application Gateway (Azure).
2. **Target Groups**:
    - `tg-blue`: Points to instances running `v1`.
    - `tg-green`: Points to instances running `v2`.

### Your Tasks
- [ ] Provision the Load Balancer and the two Target Groups.
- [ ] Set the LB Listener rule to forward 100% of traffic to `tg-blue`.
- [ ] Deploy `v2` instances into `tg-green`.
- [ ] Perform a health check on `v2` by accessing the Target Group directly (or via a test listener port).
- [ ] Update the Listener rule to shift 100% traffic to `tg-green`.
- [ ] **Bonus**: Reconfigure the rule to do a "Canary" shift (80/20 split) before going 100% Green.

---

## 🏁 Final Project: The Resilient API
Combine all concepts into a single project:
- Build a REST API on **AWS ECS Fargate**.
- Front it with an **Application Load Balancer**.
- Configure **Auto Scaling** based on concurrent requests.
- Log all transactional data to an **SQS queue** for asynchronous processing.
- document the entire stack using a single `main.tf` file.
