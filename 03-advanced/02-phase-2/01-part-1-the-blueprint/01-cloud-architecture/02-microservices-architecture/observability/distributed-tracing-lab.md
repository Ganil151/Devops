# 🕵️ Lab: Distributed Tracing with OpenTelemetry & Jaeger

> **Scenario**: Your checkout process is slow, but only on Tuesdays. Individual services report "Healthy," but the end-to-end latency is 10 seconds.
> **The Mission**: Implement **Trace Propagation** to visualize the request lifecycle across `Order Service` -> `Payment Service` -> `Fraud Check`.

---

## 🏗️ The Architecture: The "Trace ID" Journey

Distributed tracing works by injecting a unique `traceparent` header (W3C standard) into every request.

1.  **Frontend/Gateway**: Generates a `TraceID`.
2.  **Service A**: Receives `TraceID`, creates a `Span`, and passes the ID to Service B.
3.  **Service B**: Receives same `TraceID`, creates a child `Span`.
4.  **Collector**: All spans are sent asynchronously to a central engine (Jaeger/Honeycomb/Datadog).

---

## 🛠️ Step 1: Instrumenting the Service (Python/FastAPI)

We use **OpenTelemetry (OTel)** because it is vendor-neutral.

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# 1. Initialize Tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# 2. Configure Exporter (Send to Jaeger)
otlp_exporter = OTLPSpanExporter(endpoint="http://jaeger-collector:4317")
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(otlp_exporter))

# 3. Instrument the App
app = FastAPI()
FastAPIInstrumentor.instrument_app(app)

@app.post("/checkout")
async def checkout():
    with tracer.start_as_current_span("fraud-check"):
        # This child span will be linked to the parent TraceID
        result = call_fraud_service()
    return {"status": "processing"}
```

---

## 🛠️ Step 2: Deploying the Jaeger "Ghost" Engine

In Kubernetes, we deploy Jaeger as a sidecar or a dedicated deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  template:
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686 # UI
        - containerPort: 4317  # OTLP gRPC
```

---

## 🛠️ Step 3: Analyzing the "Gantt Chart of Hell"

Once traffic flows, open the Jaeger UI (`http://localhost:16686`).

### 🔍 What to Look For:
1.  **The "Long Tail"**: A single span that is significantly longer than others (e.g., an unindexed DB query).
2.  **The "N+1 Problem"**: 50 tiny spans in a row representing sequential DB calls instead of a batch.
3.  **The "Black Hole"**: Spans that stop abruptly without an error—usually indicating a timeout or an unhandled exception in an async worker.

---

## 🚨 Principal Architect Insights: "Tracing Fatigue"

- **Sampling is Mandatory**: At scale, you cannot trace 100% of requests. Use **Probabilistic Sampling** (e.g., 1%) to reduce overhead and storage costs.
- **Context Over Code**: The value is in the **Metadata**. Inject `customer_id`, `order_tier`, and `k8s.pod.name` into spans.
- **Clock Skew is Real**: In distributed systems, timestamps are never perfectly synced. Jaeger uses **Clock Skew Adjustment** logic, but trust duration over absolute start times.
- **Span Events vs Logs**: Don't put huge logs in spans. Use **Span Events** for high-cardinality state changes (e.g., "Queue Wait Started").

---
**Module**: Microservices Observability
**Next Lab**: [Log Aggregation with EFK Stack](./log-aggregation-lab.md)
