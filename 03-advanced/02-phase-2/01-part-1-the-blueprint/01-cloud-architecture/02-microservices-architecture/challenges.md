# Microservices Architecture - Challenges

Advanced hands-on challenges to master microservices patterns and production-ready implementations.

---

## 🎯 Challenge Difficulty Levels

- 🟢 **Beginner**: Fundamental concepts and basic implementations
- 🟡 **Intermediate**: Multi-service interactions and patterns
- 🔴 **Advanced**: Production scenarios with failure handling
- 🟣 **Expert**: Complex distributed systems design

---

## Challenge 1: Design a Saga Pattern 🟡

**Scenario:**  
You're building an e-commerce platform with three services: Order, Inventory, and Payment. Design a Saga to handle the order creation process using **choreography**.

### Requirements:
1. Draw a sequence diagram (Mermaid) showing the happy path
2. Draw a sequence diagram showing a failure scenario with compensation
3. Identify potential issues with this choreography approach
4. Propose how you would implement this with **orchestration** instead

### Deliverables:
- Two Mermaid sequence diagrams
- 300-word comparison of choreography vs orchestration for this use case
- Identify at least 3 edge cases (e.g., partial failures, double-charging)

### Evaluation Criteria:
- ✅ Correct event flow
- ✅ Proper compensation logic
- ✅ Edge case awareness
- ✅ Clear comparison of approaches

---

## Challenge 2: Implement Circuit Breaker 🟡

**Scenario:**  
Your microservice calls an external payment gateway that occasionally fails. Implement a circuit breaker to prevent cascading failures.

### Requirements:
1. Choose a language (Go or Python)
2. Implement a circuit breaker with these states:
   - **Closed**: Normal operation
   - **Open**: Fail fast after threshold
   - **Half-Open**: Test recovery
3. Configure thresholds:
   - Open circuit after 5 consecutive failures
   - Reset timeout: 30 seconds
   - Allow 3 test requests in Half-Open state

### Deliverables:
- Working code implementation
- Unit tests for all three states
- Demonstration of fallback logic (return cached data when circuit is open)

### Test Scenarios:
```python
# Test 1: Circuit opens after 5 failures
for _ in range(5):
    call_payment_gateway()  # All fail
# Next call should fail immediately (circuit open)

# Test 2: Circuit recovers
time.sleep(30)  # Wait for reset timeout
call_payment_gateway()  # Should attempt request (half-open)
# If successful, circuit closes
```

### Bonus:
- Add metrics tracking (requests, failures, circuit state changes)
- Implement exponential backoff in Half-Open state

---

## Challenge 3: Database Per Service Migration 🔴

**Scenario:**  
You have a monolithic application with a shared database. Migrate the "Order" domain to a separate microservice with its own database.

### Current State:
```sql
-- Monolith Database
Table: orders (order_id, customer_id, total_amount, created_at)
Table: customers (customer_id, name, email, address)
Table: order_items (item_id, order_id, product_id, quantity)
Table: products (product_id, name, price, stock)
```

### Requirements:
1. Identify which tables belong to the Order domain
2. Design the new Order Service database schema
3. Handle cross-domain queries (e.g., getting customer name for an order)
4. Implement a data synchronization strategy during migration

### Deliverables:
- Database schema for Order Service
- Data migration plan (step-by-step)
- Strategy for handling foreign key constraints (e.g., customer_id)
- Code example showing how Order Service gets customer data (API call, denormalization, or CQRS)

### Migration Phases:
```
Phase 1: Dual Write (write to both old and new DB)
Phase 2: Route Reads (gradually shift reads to new DB)
Phase 3: Decommission (remove old schema)
```

### Bonus:
- Implement event-driven denormalization (customer data cached in Order DB)
- Handle data consistency issues (eventual consistency)

---

## Challenge 4: Design API Gateway Routing 🟡

**Scenario:**  
You have 5 microservices: User, Order, Product, Payment, Notification. Design an API Gateway that handles routing, authentication, and rate limiting.

### Requirements:
1. Define routes for each service
2. Implement JWT-based authentication
3. Add rate limiting (100 requests/minute per user)
4. Handle service failures gracefully (return cached data or error messages)

### Deliverables:
- Kong or NGINX configuration file
- Example curl commands to test routing
- Rate limiting demonstration

### Example Configuration (Kong):
```yaml
services:
  - name: user-service
    url: http://user-svc:8080
    routes:
      - paths:
          - /api/users
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          minute: 100
```

### Test Scenarios:
1. **Unauthenticated Request**: Should return 401
2. **Authenticated Request**: Should route to correct service
3. **Rate Limit Exceeded**: Should return 429
4. **Service Down**: Should return cached response or 503

---

## Challenge 5: Implement Distributed Tracing 🔴

**Scenario:**  
You have a request flow: `API Gateway → Order Service → Inventory Service → Payment Service`. Implement distributed tracing to track the request across all services.

### Requirements:
1. Use OpenTelemetry (or Jaeger/Zipkin)
2. Propagate trace context across HTTP and message queue boundaries
3. Create spans for each service operation
4. Visualize the trace in Jaeger UI

### Implementation Steps:
1. Instrument API Gateway to create root span
2. Propagate trace context in HTTP headers (W3C Trace Context)
3. Each service extracts context and creates child spans
4. For async operations (Kafka), embed trace context in message headers

### Deliverables:
- Instrumented code for all 4 services
- Screenshot of Jaeger UI showing the full trace
- Explanation of how you handled async boundaries

### Example (Python with OpenTelemetry):
```python
from opentelemetry import trace
from opentelemetry.propagate import inject, extract

# Service A (Publisher)
with tracer.start_as_current_span("publish_event"):
    headers = {}
    inject(headers)  # Inject trace context
    producer.send('topic', headers=headers)

# Service B (Consumer)
context = extract(message.headers)
with tracer.start_as_current_span("process_event", context=context):
    process(message)
```

---

## Challenge 6: Chaos Engineering Experiment 🔴

**Scenario:**  
You want to test the resilience of your microservices architecture. Design and execute a chaos engineering experiment.

### Requirements:
1. Choose a failure scenario (e.g., kill a service instance, introduce latency, partition network)
2. Define a hypothesis (e.g., "System should remain available even if Payment Service is down")
3. Execute the experiment in a staging environment
4. Measure the impact (error rate, latency, availability)

### Experiment Template:
```markdown
## Experiment: Payment Service Failure

**Hypothesis**: If Payment Service fails, users can still browse products and add items to cart.

**Method**: 
1. Baseline: Measure normal error rate and latency
2. Introduce failure: Kill all Payment Service pods
3. Observe: Monitor error rate for checkout endpoint
4. Expected: Checkout returns 503, but other endpoints work

**Results**:
- Product browsing: ✅ No impact
- Add to cart: ✅ No impact
- Checkout: ❌ 100% error rate (expected)
- Fallback: ⚠️ No fallback implemented

**Action Items**:
- Implement fallback: Queue orders for later processing
- Add circuit breaker to fail fast
```

### Deliverables:
- Experiment documentation (hypothesis, method, results)
- Monitoring dashboard screenshots (before/after)
- Action plan to address discovered issues

### Tools to Use:
- **Chaos Monkey**: Random pod termination
- **Pumba**: Network failures, latency injection
- **Istio Fault Injection**: HTTP-level failures

---

## Challenge 7: Design Event-Driven Architecture 🔴

**Scenario:**  
Design an event-driven system for an order fulfillment workflow.

### Workflow:
1. User places order → `OrderPlaced` event
2. Inventory reserves stock → `StockReserved` event
3. Payment processes → `PaymentProcessed` event
4. Notification sends email → `EmailSent` event
5. Order confirmed → `OrderConfirmed` event

### Requirements:
1. Choose a message broker (Kafka or RabbitMQ)
2. Define event schemas (JSON or Avro)
3. Handle idempotency (duplicate events)
4. Implement dead letter queues for failed events

### Deliverables:
- Event schema definitions
- Kafka topic design (partitioning strategy)
- Consumer group configuration
- Idempotency implementation (e.g., using event IDs)

### Event Schema Example:
```json
{
  "event_id": "evt-123",
  "event_type": "OrderPlaced",
  "timestamp": "2026-01-19T14:23:15Z",
  "version": "1.0",
  "data": {
    "order_id": "ORD-456",
    "customer_id": "CUST-789",
    "items": [...]
  }
}
```

### Idempotency Check:
```python
def process_event(event):
    if redis.exists(f"processed:{event['event_id']}"):
        logger.info("Duplicate event, skipping")
        return
    
    # Process event
    handle_event(event)
    
    # Mark as processed
    redis.setex(f"processed:{event['event_id']}", 86400, "1")
```

---

## Challenge 8: Implement CQRS Pattern 🟣

**Scenario:**  
Build a product catalog system using CQRS (Command Query Responsibility Segregation).

### Requirements:
1. **Write Side**: PostgreSQL for commands (AddProduct, UpdatePrice)
2. **Read Side**: Elasticsearch for queries (SearchProducts, GetProductDetails)
3. Synchronize using events (via Kafka)
4. Handle eventual consistency

### Architecture:
```
Command → PostgreSQL → Event Bus → Projection → Elasticsearch
Query → Elasticsearch (directly)
```

### Deliverables:
- Command handler code (write to PostgreSQL, publish event)
- Projection code (consume event, update Elasticsearch)
- Query handler code (read from Elasticsearch)
- Demonstration of eventual consistency (query right after command)

### Example:
```python
# Command Handler
def add_product(product_data):
    # Write to PostgreSQL
    product = db.insert_product(product_data)
    
    # Publish event
    event = {
        'event_type': 'ProductAdded',
        'product_id': product.id,
        'data': product_data
    }
    kafka.publish('product-events', event)

# Projection (Event Handler)
def handle_product_added(event):
    # Update Elasticsearch
    es.index(
        index='products',
        id=event['product_id'],
        body=event['data']
    )

# Query Handler
def search_products(query):
    return es.search(index='products', body={'query': query})
```

---

## Challenge 9: Build a Service Mesh Lab 🔴

**Scenario:**  
Set up a local Kubernetes cluster with Istio and demonstrate advanced traffic management.

### Requirements:
1. Install Minikube/Kind and Istio
2. Deploy two versions of a service (v1, v2)
3. Configure canary deployment (90% v1, 10% v2)
4. Implement header-based routing (route premium users to v2)
5. Add fault injection (10% delay, 1% abort)

### Deliverables:
- Istio VirtualService manifest
- curl commands demonstrating routing
- Kiali dashboard screenshot showing traffic distribution

### Test Commands:
```bash
# Regular user (90/10 split)
for i in {1..100}; do curl http://service/api; done

# Premium user (100% v2)
curl -H "x-user-segment: premium" http://service/api

# Test fault injection
curl http://service/api  # Some requests delayed/failed
```

---

## Challenge 10: Design Multi-Tenant Architecture 🟣

**Scenario:**  
Design a SaaS platform that serves multiple tenants (companies) with data isolation.

### Requirements:
1. Choose a multi-tenancy model:
   - **Database per Tenant**: Separate DB per company
   - **Schema per Tenant**: Separate schema in shared DB
   - **Row-Level Security**: Shared schema with tenant_id column
2. Handle tenant routing (subdomain-based: `acme.app.com`, `globex.app.com`)
3. Implement tenant context propagation across services
4. Design billing based on tenant usage

### Deliverables:
- Architecture diagram (Mermaid)
- Database schema design
- Middleware code for tenant identification
- Comparison of the three multi-tenancy models

### Example (Tenant Context Propagation):
```python
# Middleware extracts tenant from subdomain
def tenant_middleware(request):
    subdomain = request.headers['Host'].split('.')[0]
    tenant = Tenant.get_by_subdomain(subdomain)
    
    # Add to request context
    request.tenant = tenant
    
    # Propagate to other services
    headers = {'X-Tenant-ID': tenant.id}
    return headers

# Service uses tenant context
def get_orders(request):
    tenant_id = request.headers['X-Tenant-ID']
    return db.query("SELECT * FROM orders WHERE tenant_id = ?", tenant_id)
```

---

## 🏆 Bonus Challenge: Build a Complete Microservices App

**Scenario:**  
Build a fully functional microservices application from scratch.

### Application: Online Food Delivery

### Services:
1. **User Service**: Authentication, user profiles
2. **Restaurant Service**: Restaurant catalog, menus
3. **Order Service**: Order creation, tracking
4. **Delivery Service**: Driver assignment, location tracking
5. **Payment Service**: Payment processing
6. **Notification Service**: Email/SMS notifications

### Requirements:
- All services communicate via REST APIs and Kafka
- Implement circuit breakers and retries
- Use API Gateway (Kong or custom)
- Deploy on Kubernetes with Istio
- Implement distributed tracing
- Add monitoring (Prometheus + Grafana)

### Deliverables:
- Complete source code (GitHub repo)
- Architecture diagram
- Deployment instructions
- Demo video

---

## 📊 Challenge Completion Tracker

| Challenge | Difficulty | Estimated Time | Status |
|-----------|-----------|----------------|--------|
| 1. Saga Pattern | 🟡 | 2-3 hours | ⬜ |
| 2. Circuit Breaker | 🟡 | 3-4 hours | ⬜ |
| 3. Database Per Service | 🔴 | 4-6 hours | ⬜ |
| 4. API Gateway | 🟡 | 2-3 hours | ⬜ |
| 5. Distributed Tracing | 🔴 | 4-5 hours | ⬜ |
| 6. Chaos Engineering | 🔴 | 3-4 hours | ⬜ |
| 7. Event-Driven Arch | 🔴 | 5-6 hours | ⬜ |
| 8. CQRS Pattern | 🟣 | 6-8 hours | ⬜ |
| 9. Service Mesh | 🔴 | 4-5 hours | ⬜ |
| 10. Multi-Tenant | 🟣 | 6-8 hours | ⬜ |
| Bonus: Full App | 🟣 | 40+ hours | ⬜ |

---

## 🎓 Learning Outcomes

After completing these challenges, you will be able to:

✅ Design and implement Saga patterns for distributed transactions  
✅ Build resilient microservices with circuit breakers and retries  
✅ Architect event-driven systems with message brokers  
✅ Implement CQRS and event sourcing patterns  
✅ Deploy and manage service meshes (Istio)  
✅ Design API gateways with authentication and rate limiting  
✅ Implement distributed tracing across services  
✅ Conduct chaos engineering experiments  
✅ Design multi-tenant SaaS architectures  
✅ Build production-ready microservices systems  

---

**Next Steps:**  
1. Choose a challenge based on your skill level
2. Read the requirements carefully
3. Research the patterns and technologies involved
4. Implement the solution
5. Test thoroughly
6. Document your learnings

**Need Help?**  
- Refer to the main [README.md](./readme.md) for pattern explanations
- Check the [boilerplates](./boilerplates/) for code examples
- Review real-world case studies for inspiration

---

**Last Updated:** 2026-01-19  
**Maintainer:** DevOps Advanced Curriculum
