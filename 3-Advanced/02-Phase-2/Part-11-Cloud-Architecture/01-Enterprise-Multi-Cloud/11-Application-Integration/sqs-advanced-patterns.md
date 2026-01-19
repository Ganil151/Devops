# Advanced SQS Patterns & Troubleshooting

A deep dive into industrial-grade architectural patterns, optimization strategies, and real-world troubleshooting for SQS.

## 1. Architectural Patterns

### The Worker Pattern (Queue-to-Microservice)
This is the most common pattern. A fleet of workers (EC2, ECS, or Lambda) polls the queue and processes messages.
- **Scaling**: Use **CloudWatch Alarms** on the `ApproximateNumberOfMessagesVisible` metric to trigger Auto Scaling.
- **High Availability**: Distribute workers across multiple Availability Zones.

### The Fan-out Pattern (SNS-to-SQS)
Send a message once to an SNS topic and have it delivered to multiple SQS queues.
- **Benefit**: Decouples producer from multiple consumers. Allows different services to react to the same event in different ways.

### The Claim Check Pattern (Large Messages)
SQS has a message size limit of **256 KB**. For larger payloads (up to gigabytes):
1. Store the payload in **Amazon S3**.
2. Send a "Claim Check" (the S3 bucket/key reference) to the SQS queue.
3. Consumer reads the SQS message, retrieves the payload from S3, processes it, and deletes from both S3 and SQS.
- **Tooling**: Use the **Amazon S3 Extended Client Library for Java** (or equivalent) to automate this.

## 2. Cost Optimization Hacks

### Message Batching
Send, receive, and delete messages in batches of up to 10.
- **Benefit**: Reduces API call costs by up to 90%.
```bash
# Sending a batch of messages
aws sqs send-message-batch --queue-url $QUEUE_URL --entries file://batch-messages.json
```

### Long Polling
Set `ReceiveMessageWaitTimeSeconds` to 20 seconds.
- **Benefit**: Reduces empty responses (where SQS returns 0 messages), significantly lowering costs and increasing efficiency.

## 3. Dealing with Duplicate Messages

In **Standard Queues**, SQS guarantees at-least-once delivery, which means a message might be delivered more than once.
- **Solution 1: Idempotency**. Design your application so that processing the same message twice has no side effects (e.g., check a database before performing an operation).
- **Solution 2: FIFO Queues**. Use FIFO if ordering and exactly-once processing are critical.

## 4. Troubleshooting Guide

| Symptom | Probable Cause | Resolution |
| :--- | :--- | :--- |
| **Messages reappear in queue** | Processing exceeds Visibility Timeout | Increase the `VisibilityTimeout` or extend it while processing via `ChangeMessageVisibility`. |
| **0 messages received** | Short Polling (polling too fast) | Switch to **Long Polling** (WaitTime > 0). |
| **Queue is slower than expected** | Throughput limit reached (FIFO) | Ensure unique `MessageGroupId` values to enable parallel processing in FIFO queues. |
| **Access Denied** | Missing IAM or Queue Policy | Verify the consumer has `sqs:ReceiveMessage` and `sqs:DeleteMessage` permissions in its role. |

## 5. SQS Hacks & Performance Pro-Tips

### The "Hidden" Attribute Hack
Use `ApproximateReceiveCount` to detect "Poison Pill" messages (messages that consistently crash the consumer) before they reach the Redrive Policy limit.
```bash
# Check how many times a message has been attempted
aws sqs receive-message --queue-url $QUEUE_URL --attribute-names ApproximateReceiveCount
```

### Delaying Individual Messages
Instead of delaying the whole queue, you can delay a single message at the point of sending.
```bash
aws sqs send-message --queue-url $QUEUE_URL --message-body "Delayed job" --delay-seconds 60
```

## Summary Checklist
- [ ] Implement Long Polling to save costs and reduce latency.
- [ ] Use Batching for all high-volume operations.
- [ ] Ensure all consumers are idempotent.
- [ ] Configure DLQs for every production queue.
- [ ] Set up CloudWatch Alarms for monitoring queue depth.
