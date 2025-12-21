# SQS Fundamentals & Concepts

Amazon Simple Queue Service (SQS) is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications.

## 1. What is SQS?

SQS eliminates the complexity and overhead associated with managing and operating message-oriented middleware and empowers developers to focus on differentiating work. Using SQS, you can send, store, and receive messages between software components at any volume, without losing messages or requiring other services to be available.

### Core Benefits
- **Decoupling**: Services can communicate without being online at the same time.
- **Scalability**: SQS handles any volume of messages without manual intervention.
- **Durability**: Messages are stored across multiple servers and data centers.
- **Reliability**: Guarantees delivery (at least once for Standard, exactly once for FIFO).

## 2. Queue Types: Standard vs. FIFO

| Feature | Standard Queues | FIFO Queues |
| :--- | :--- | :--- |
| **Throughput** | Nearly unlimited (3,000 TPS per command) | Up to 3,000 TPS with batching |
| **Delivery** | At-least-once | Exactly-once |
| **Ordering** | Best-effort (No guarantee) | First-In-First-Out (Strict guarantee) |
| **Message Deduplication** | No | Yes (via MessageDeduplicationId) |
| **Use Cases** | Decoupling, Async processing, Scaling | Banking transactions, Order processing |

## 3. Key Concepts

### Visibility Timeout
The period of time during which SQS prevents other consumers from receiving and processing a message that has already been retrieved.
- **Default**: 30 seconds.
- **Maximum**: 12 hours.
- **Pro-Tip**: If your processing takes longer than the timeout, the message becomes visible again, leading to duplicate processing.

### Message Retention Period
How long a message stays in the queue before being automatically deleted if not processed.
- **Default**: 4 days.
- **Range**: 60 seconds to 14 days.

### Delay Queues
Postpone the delivery of new messages to a queue for a specific number of seconds.
- **Use Case**: Give a downstream system time to process a related resource before the queue message arrives.

### Dead-Letter Queues (DLQ)
A queue where messages are sent if the source queue cannot process them successfully after a certain number of attempts (Redrive Policy).
- **Benefit**: Isolate problematic messages for troubleshooting without blocking the main workflow.

## 4. SQS vs. Other Services

- **SQS vs. SNS**: SQS is **Pull** (polling); SNS is **Push** (fan-out).
- **SQS vs. Kinesis**: SQS is for discrete tasks; Kinesis is for large-scale stream processing and ordering within shards.

## 5. Security Summary
- **IAM Policies**: Control who can send/receive messages.
- **Resource-based Policies**: Control access from other AWS accounts.
- **Encryption**: KMS (SSE-KMS) used for data at rest.

---
**Next Step**: Learn how to use SQS in the [Hands-on SQS Guide](../../Intermediate-Level/11-Application-Integration/sqs-hands-on.md)
