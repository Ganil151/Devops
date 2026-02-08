# 🌐 Microservices Architecture & Distributed Systems

> **"A microservice is not a size; it's a unit of replacement and independent scaling."**

In this module, we transition from monoliths to **Distributed Ecosystems**. We move beyond simple API calls and master the complexity of **Eventual Consistency**, **Domain-Driven Design (DDD)**, and **Service Meshes**.

---

## 🧭 The High-Level Decision Matrix

| Requirement | Preferred Pattern | Primary Tool |
|:---|:---|:---|
| **Strong Consistency** | Monolithic or Distributed Locking | PostgreSQL / Etcd |
| **High Availability** | Event-Driven Architecture | Kafka / RabbitMQ |
| **Micro-Segmentation** | Service Mesh | Istio / Linkerd |
| **Cross-Service ID** | JWT Propagation | OAuth2 / OIDC |
| **Data Integrity** | Saga Pattern (Transactions) | Temporal / Step Functions |

---

## 🏗️ Architectural Foundations

### 1️⃣ Domain-Driven Design (DDD)
The strategy for defining service boundaries:
- **Bounded Contexts**: ensuring models don't leak across domains (e.g., "User" in Sales vs. "User" in Shipping).
- **Ubiquitous Language**: Aligning code with business terminology.
- **Aggregates**: Grouping domain objects for transactional consistency.

### 2️⃣ Resiliency & The Fallback Layer
Surviving the "Death Star" architecture:
- **Circuit Breakers**: Cutting off failing services to prevent cascading outages.
- **Bulkheads**: Isolating resources so a failure in one service doesn't drain the others.
- **Idempotency**: Ensuring retries don't cause duplicate side effects.

---

## 📚 Technical Deep-Dives

| Component | Objective | Key Laboratory |
|:---|:---|:---|
| **Communication** | Sync vs Async trade-offs | [gRPC vs Event-Driven](./communication/grpc-vs-event-driven/) |
| **Data** | Managing distributed state | [Saga Transactions](./patterns/saga-distributed-transactions/) |
| **Security** | Zero-Trust Identity | [JWT Propagation](./security/oauth2-and-jwt-propagation/) |
| **Mesh** | Traffic Control & Retries | [Istio Configuration](./resiliency/service-mesh-and-retries/) |
| **Observability** | Tracking the "Ghost in the Machine" | [Distributed Tracing (Tracing Lab)](./observability/distributed-tracing-lab.md) |

---

## 🚀 Principal Architect Pro-Tips

1.  **Distributed Monolith Warning**: If you cannot deploy Service A without also deploying Service B, you haven't built microservices; you've built a distributed monolith.
2.  **Shared Databases are an Anti-Pattern**: Two services sharing one database is a "hard coupling" that will eventually lead to deployment gridlock.
3.  **The Fallacy of Distributed Transactions**: Avoid 2PC (Two-Phase Commit). Embrace **Eventual Consistency** and compensation logic (Sagas).
4.  **Network is Unreliable**: Always assume the network is slow, congested, or down. Every cross-service call must have a timeout and a fallback.

---
**Status**: 🏗️ Architectural Blueprint Updated
**Update**: 2026-02-08 (The Architect Update)
**Next Step**: [Service Mesh & Resiliency](./resiliency/service-mesh-and-retries/)
