# Tracing Foundations

As systems move from monoliths to microservices, a single user request might touch 10 different services. Monitoring and logging aren't enough to see the whole picture.

---

## 🧵 1. What is Distributed Tracing?
Distributed tracing tracks the path of a request through the entire system.
- **Trace**: The complete record of a request's journey.
- **Span**: A single unit of work (e.g., an SQL query, a call to an external API) within a trace.

---

## 🏢 2. APM (Application Performance Monitoring)
APM tools combine metrics, logs, and traces to provide a deep look into application health.
- **Top Tools**: Jaeger, Zipkin, New Relic, Datadog.

---

## 🕵️ 3. Context Propagation
The process of passing trace IDs from one service to another via HTTP headers. This allows the tracing system to "stitch" together spans from different servers into a single trace.

---

## 💡 Why use Tracing?
- **Root Cause Analysis**: Find exactly which service in the chain is causing a slow response.
- **Dependency Mapping**: Visualize how your services interact with each other.
- **Performance Budgeting**: Identify which part of your code is taking the most time in a request lifecycle.
