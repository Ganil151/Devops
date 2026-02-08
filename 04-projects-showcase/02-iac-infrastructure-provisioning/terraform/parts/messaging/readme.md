# AWS Messaging & Integration Architectural Patterns

This directory contains 20 common patterns for asynchronous messaging, notifications, and event-driven integration using Amazon SQS, SNS, and EventBridge via Terraform. These services enable decoupled architectures that are scalable, reliable, and cost-effective.

## 📂 Messaging Patterns Overview

| # | Type | Description | File |
|---|------|-------------|------|
| 1 | **Standard SQS** | Simple, high-throughput asynchronous queue. | `01-standard-sqs.tf` |
| 2 | **FIFO SQS** | Strict ordering and exactly-once processing. | `02-fifo-sqs.tf` |
| 3 | **SQS DLQ** | Error handling via Dead Letter Queues. | `03-dead-letter-queue.tf` |
| 4 | **SNS Topic** | Pub/Sub broadcaster for multiple subscribers. | `04-sns-topic.tf` |
| 5 | **SNS FIFO** | Ordered and deduplicated message broadcasting. | `05-sns-fifo-topic.tf` |
| 6 | **SNS-SQS Fan-Out** | Subscribing queues to topics (Fan-out pattern). | `06-sns-sqs-subscription.tf` |
| 7 | **Email Notify** | Direct email notifications from SNS topics. | `07-sns-email-subscription.tf` |
| 8 | **Lambda Notify** | triggering functions via SNS messages. | `08-sns-lambda-subscription.tf` |
| 9 | **KMS Encryption** | Securing queue messages with custom keys. | `09-kms-encrypted-queue.tf` |
| 10 | **SQS Policy** | Granting services permission to send messages. | `10-queue-policy.tf` |
| 11 | **SNS Policy** | restricting topic publishing and subscribing. | `11-sns-topic-policy.tf` |
| 12 | **EB Rule** | routing AWS system events (EC2/S3) to SQS. | `12-eventbridge-rule.tf` |
| 13 | **SNS Filter** | Attribute-based message filtering for subscribers. | `13-sns-filtering.tf` |
| 14 | **Long Polling** | reducing API costs and latency in SQS. | `14-sqs-long-polling.tf` |
| 15 | **SMS Subscription** | Global text message notifications. | `15-sns-sms-subscription.tf` |
| 16 | **Webhook (HTTP)** | triggering external APIs from SNS topics. | `16-sns-http-subscription.tf` |
| 17 | **Mobile Push** | iOS/Android push notifications (APNS/FCM). | `17-sns-platform-application.tf` |
| 18 | **Custom Event Bus**| application-specific EventBridge bus design. | `18-eventbridge-bus.tf` |
| 19 | **API Destination** | sending events to Slack/Zendesk/Datadog. | `19-eventbridge-api-destination.tf` |
| 20 | **Minimalist** | Baseline queue boilerplate. | `20-minimalist-messaging.tf` |

## 🚀 Architectural Best Practices
1.  **Use DLQs**: Always configure a **Dead Letter Queue** for SQS to prevent "poison-pill" messages from being retried indefinitely.
2.  **Fan-Out Pattern**: Subscribe SQS queues to SNS topics instead of having producers send directly to multiple queues. This makes the system more extensible.
3.  **Long Polling**: Enable `receive_wait_time_seconds = 20` to minimize "empty" reads and lower SQS costs.
4.  **Least Privilege Policies**: Use specific Resource Policies (SQS/SNS) instead of generic IAM roles whenever possible to reduce the blast radius.
5.  **Small Payload limit**: SQS and SNS have a 256KB limit. For larger payloads, store the data in **S3** and send a pointer (S3 URI) in the message.

## 🛠 Prerequisites
These resources are standalone but often require IAM permissions for interaction. Refer to the `iam` directory for associated role patterns.
