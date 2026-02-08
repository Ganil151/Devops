# AWS Lambda Architectural Patterns

This directory contains 20 common AWS Lambda patterns for serverless compute using Terraform. Lambda allows you to run code without provisioning or managing servers.

## 📂 Lambda Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Python Basic** | Standard Python runtime deployment. | `01-python-lambda.tf` |
| 2 | **Node.js Basic** | Standard Node.js runtime deployment. | `02-node-lambda.tf` |
| 3 | **Env Vars** | Injecting configuration into the runtime. | `03-env-vars-lambda.tf` |
| 4 | **VPC Lambda** | accessing private resources (RDS, Redis). | `04-vpc-lambda.tf` |
| 5 | **S3 Trigger** | reacting to bucket file events. | `05-s3-trigger-lambda.tf` |
| 6 | **SQS Trigger** | processing background queues. | `06-sqs-trigger-lambda.tf` |
| 7 | **API Gateway** | REST API integration (Proxy type). | `07-api-gateway-rest.tf` |
| 8 | **Scheduled (Cron)**| Recurring jobs via EventBridge rules. | `08-scheduled-lambda.tf` |
| 9 | **Lambda Layer** | Extracting shared libraries and binaries. | `09-lambda-layer.tf` |
| 10 | **Containerized** | Running OCI/Docker images as functions. | `10-container-lambda.tf` |
| 11 | **Alias/Version** | environments for Dev/Stage/Prod. | `11-alias-version.tf` |
| 12 | **Concurrency** | eliminating cold starts in production. | `12-provisioned-concurrency.tf` |
| 13 | **Destinations** | async routing (Success -> SQS, Failure -> SNS). | `13-lambda-destination.tf` |
| 14 | **X-Ray Tracing** | visual performance and error debugging. | `14-xray-tracing.tf` |
| 15 | **Edge Lambda** | Low-latency processing at the CDN edge. | `15-lambda-edge.tf` |
| 16 | **Function URL** | direct HTTPS access without API Gateway. | `16-lambda-url.tf` |
| 17 | **Ephemeral Storage**| Boosting local disk space (/tmp) up to 10GB. | `17-ephemeral-storage.tf` |
| 18 | **ARM/Graviton** | optimized architecture for cost/performance. | `18-lambda-architecture.tf` |
| 19 | **SnapStart** | fast startup for Java-based workloads. | `19-snapstart-lambda.tf` |
| 20 | **Minimalist** | Baseline function boilerplate. | `20-minimalist-lambda.tf` |

## 🚀 Key Best Practices
1.  **Memory over CPU**: Lambda CPU scales with memory. If your function is slow, increase memory.
2.  **Environment Secrets**: Never hardcode secrets. Use **AWS Secrets Manager** and fetch them at runtime.
3.  **VPC Networking**: Only put Lambda in a VPC if it MUST access private resources. VPC networking adds initialization time.
4.  **Least Privilege Role**: Create a specific IAM role per function.
5.  **Monitoring**: Always enable **CloudWatch Logs** and consider **X-Ray** for complex distributed systems.

## 🛠 Usage
Each file is a standalone resource definition. be sure to provide the `role_arn` and any trigger-specific triggers (like `s3_bucket_id` or `sqs_queue_arn`).
