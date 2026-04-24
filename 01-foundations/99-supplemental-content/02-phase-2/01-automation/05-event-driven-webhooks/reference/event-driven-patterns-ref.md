# 🦅 Event-Driven Architecture Patterns
*Version 1.0 | Engineering Reactive and Decoupled Systems*

---

## 📖 Overview
Event-Driven Architecture (EDA) is a design pattern where services communicate by emitting and reacting to events. In DevOps, this is used to build "Reactive Infrastructure" (e.g., "When a Tag is created in GitHub, trigger a production deployment").

---

## 🏗️ Core Patterns

### 1. The "Observer" Pattern
Multiple listeners react to a single event.
- **Example**: AWS S3 Object Put triggers:
  1. A Lambda to resize the image.
  2. A Lambda to update the Database.
  3. A SNS notification to the user.

### 2. The "Event Sourcing" Pattern
Instead of storing the current state, you store the entire history of events.
- **Benefit**: Auditability. You can "re-play" events to reconstruct the state at any point in time.

### 3. The "Publish-Subscribe" (Pub/Sub)
A message broker sits in the middle. Producers publish to a **Topic**, and consumers subscribe to it.
- **Tools**: AWS SNS, GCP Pub/Sub, Redis.

---

## ⚙️ Handling Scale: Fan-Out
When a single webhook needs to trigger 10 different tasks.
- **Poor Design**: The webhook listener runs all 10 tasks in a sequence. (Timeout risk!)
- **SRE Design (Fan-Out)**:
  1. Webhook listener publishes one message to an SNS Topic.
  2. SNS fan-outs the message to 10 different SQS queues.
  3. 10 specialized worker groups process their task asynchronously.

---

## 🚀 SRE Strategic Checklist
- [ ] **Decoupling**: Can Service A survive if Service B is down?
- [ ] **Message Ordering**: Does your architecture require events to be processed in a specific sequence (FIFO)?
- [ ] **Poison Pill Handling**: How does your system handle an event that consistently causes the consumer to crash? (Dead Letter Queues).

---

## 🏛️ Comparison Matrix

| Pattern | Latency | Complexity | Durability |
| :--- | :--- | :--- | :--- |
| **Direct Webhook** | Ultra-Low | Low | Low (Source retries only) |
| **Pub/Sub Broker** | Low | Medium | High (Broker persistence) |
| **Event Store** | Medium | High | Extreme (History available) |

---

## ❓ Interview "Deep-Cut" Questions
1. **Describe the "Dual Write" problem in event-driven systems and how to avoid it using the Outbox Pattern.**
2. **What is "Backpressure" and how do message queues help manage it?**
3. **Difference between "Discrete Events" and "Event Streams" (Kafka).**
4. **Explain how "Exactly-Once" processing is achieved in modern brokers.**
5. **Describe a scenario where Event-Driven architecture might be a POOR choice compared to Synchronous APIs.**

---
**Back to foundations**: [Webhook Architecture →](./webhook-architecture-ref.md)
