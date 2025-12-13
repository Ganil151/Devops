# Observability in DevOps

Complete guide to observability practices, tools, and implementation strategies.

## Observability Fundamentals

### Three Pillars of Observability
```bash
# Metrics - Numerical measurements over time
- System performance indicators
- Business KPIs and SLIs
- Resource utilization data
- Aggregated time-series data

# Logs - Discrete event records
- Application events and errors
- System and security logs
- Audit trails and transactions
- Structured and unstructured data

# Traces - Request flow through systems
- Distributed system call paths
- Service dependencies and latency
- Error propagation analysis
- Performance bottleneck identification
```

### Observability vs Monitoring
```bash
# Traditional Monitoring
- Known unknowns
- Predefined dashboards
- Threshold-based alerting
- Reactive problem solving

# Observability
- Unknown unknowns
- Exploratory analysis
- Context-rich debugging
- Proactive system understanding
```

## OpenTelemetry Implementation

### OpenTelemetry Architecture
```yaml
# OpenTelemetry Collector Configuration
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  
  prometheus:
    config:
      scrape_configs:
        - job_name: 'otel-collector'
          scrape_interval: 10s
          static_configs:
            - targets: ['0.0.0.0:8888']

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
  
  memory_limiter:
    limit_mib: 512
  
  resource:
    attributes:
      - key: service.name
        from_attribute: service_name
        action: insert
      - key: service.version
        value: "1.0.0"
        action: insert

exporters:
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true
  
  prometheus:
    endpoint: "0.0.0.0:8889"
  
  elasticsearch:
    endpoints: ["http://elasticsearch:9200"]
    logs_index: "otel-logs"
    traces_index: "otel-traces"

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [jaeger]
    
    metrics:
      receivers: [otlp, prometheus]
      processors: [memory_limiter, resource, batch]
      exporters: [prometheus]
    
    logs:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [elasticsearch]
```

### Auto-Instrumentation Setup
```python
# Python OpenTelemetry auto-instrumentation
from opentelemetry import trace, metrics, baggage
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.instrumentation.auto_instrumentation import sitecustomize

# Configure tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

span_processor = BatchSpanProcessor(
    OTLPSpanExporter(endpoint="http://otel-collector:4317", insecure=True)
)
trace.get_tracer_provider().add_span_processor(span_processor)

# Configure metrics
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint="http://otel-collector:4317", insecure=True),
    export_interval_millis=5000,
)
metrics.set_meter_provider(MeterProvider(metric_readers=[metric_reader]))
meter = metrics.get_meter(__name__)

# Custom instrumentation
from flask import Flask, request
import time
import random

app = Flask(__name__)

# Create custom metrics
request_counter = meter.create_counter(
    "http_requests_total",
    description="Total HTTP requests",
    unit="1"
)

request_duration = meter.create_histogram(
    "http_request_duration_seconds",
    description="HTTP request duration",
    unit="s"
)

active_requests = meter.create_up_down_counter(
    "http_active_requests",
    description="Active HTTP requests",
    unit="1"
)

@app.before_request
def before_request():
    request.start_time = time.time()
    active_requests.add(1)

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    
    # Record metrics
    request_counter.add(1, {
        "method": request.method,
        "endpoint": request.endpoint or "unknown",
        "status_code": str(response.status_code)
    })
    
    request_duration.record(duration, {
        "method": request.method,
        "endpoint": request.endpoint or "unknown"
    })
    
    active_requests.add(-1)
    
    return response

@app.route('/api/users/<user_id>')
def get_user(user_id):
    with tracer.start_as_current_span("get_user") as span:
        # Add span attributes
        span.set_attribute("user.id", user_id)
        span.set_attribute("operation", "get_user")
        
        # Add baggage for cross-service context
        baggage.set_baggage("user.id", user_id)
        baggage.set_baggage("request.type", "user_lookup")
        
        # Simulate database call
        with tracer.start_as_current_span("database_query") as db_span:
            db_span.set_attribute("db.system", "postgresql")
            db_span.set_attribute("db.statement", "SELECT * FROM users WHERE id = ?")
            
            # Simulate query time
            time.sleep(random.uniform(0.01, 0.1))
            
            if user_id == "404":
                span.set_attribute("error", True)
                span.record_exception(Exception("User not found"))
                return {"error": "User not found"}, 404
        
        return {"user_id": user_id, "name": f"User {user_id}"}
```

### Manual Instrumentation
```javascript
// Node.js manual instrumentation
const { trace, context, baggage } = require('@opentelemetry/api');
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-otlp-grpc');
const { OTLPMetricExporter } = require('@opentelemetry/exporter-otlp-grpc');

// Initialize SDK
const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://otel-collector:4317',
  }),
  metricExporter: new OTLPMetricExporter({
    url: 'http://otel-collector:4317',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

const tracer = trace.getTracer('user-service', '1.0.0');

class UserService {
  async getUser(userId) {
    return tracer.startActiveSpan('UserService.getUser', async (span) => {
      try {
        // Add span attributes
        span.setAttributes({
          'user.id': userId,
          'service.name': 'user-service',
          'operation': 'get_user'
        });
        
        // Create baggage for downstream services
        const bag = baggage.createBaggage({
          'user.id': { value: userId },
          'trace.id': { value: span.spanContext().traceId }
        });
        
        return context.with(baggage.setActiveBaggage(bag), async () => {
          // Simulate database call
          const user = await this.queryDatabase(userId);
          
          if (!user) {
            span.recordException(new Error('User not found'));
            span.setStatus({ code: trace.SpanStatusCode.ERROR, message: 'User not found' });
            throw new Error('User not found');
          }
          
          span.setAttributes({
            'user.found': true,
            'user.type': user.type
          });
          
          return user;
        });
      } catch (error) {
        span.recordException(error);
        span.setStatus({ code: trace.SpanStatusCode.ERROR, message: error.message });
        throw error;
      } finally {
        span.end();
      }
    });
  }
  
  async queryDatabase(userId) {
    return tracer.startActiveSpan('database.query', async (span) => {
      span.setAttributes({
        'db.system': 'postgresql',
        'db.statement': 'SELECT * FROM users WHERE id = $1',
        'db.operation': 'SELECT',
        'db.table': 'users'
      });
      
      // Simulate database query
      await new Promise(resolve => setTimeout(resolve, Math.random() * 100));
      
      return userId !== '404' ? { id: userId, name: `User ${userId}`, type: 'standard' } : null;
    });
  }
}
```

## Distributed Tracing Patterns

### Service Mesh Integration
```yaml
# Istio service mesh with tracing
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
spec:
  values:
    pilot:
      traceSampling: 100.0
    global:
      tracer:
        zipkin:
          address: jaeger-collector:9411
  meshConfig:
    defaultConfig:
      tracing:
        sampling: 100.0
        custom_tags:
          http_request_size:
            header:
              name: content-length
          http_response_size:
            header:
              name: content-length

---
# Telemetry configuration
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: default
  namespace: istio-system
spec:
  tracing:
  - providers:
    - name: jaeger
  metrics:
  - providers:
    - name: prometheus
  accessLogging:
  - providers:
    - name: otel
```

### Cross-Service Context Propagation
```go
// Go service with context propagation
package main

import (
    "context"
    "net/http"
    
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/baggage"
    "go.opentelemetry.io/otel/propagation"
    "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

var tracer = otel.Tracer("order-service")

type OrderService struct {
    userServiceURL string
    httpClient     *http.Client
}

func (s *OrderService) CreateOrder(ctx context.Context, userID, productID string) error {
    ctx, span := tracer.Start(ctx, "OrderService.CreateOrder")
    defer span.End()
    
    // Add span attributes
    span.SetAttributes(
        attribute.String("user.id", userID),
        attribute.String("product.id", productID),
        attribute.String("operation", "create_order"),
    )
    
    // Add baggage for downstream services
    bag, _ := baggage.Parse("user.id=" + userID + ",operation=create_order")
    ctx = baggage.ContextWithBaggage(ctx, bag)
    
    // Validate user exists
    user, err := s.getUser(ctx, userID)
    if err != nil {
        span.RecordError(err)
        return err
    }
    
    span.SetAttributes(
        attribute.String("user.type", user.Type),
        attribute.Bool("user.verified", user.Verified),
    )
    
    // Create order in database
    orderID, err := s.createOrderInDB(ctx, userID, productID)
    if err != nil {
        span.RecordError(err)
        return err
    }
    
    span.SetAttributes(
        attribute.String("order.id", orderID),
        attribute.Bool("order.created", true),
    )
    
    return nil
}

func (s *OrderService) getUser(ctx context.Context, userID string) (*User, error) {
    ctx, span := tracer.Start(ctx, "OrderService.getUser")
    defer span.End()
    
    // Create HTTP request with tracing
    req, err := http.NewRequestWithContext(ctx, "GET", s.userServiceURL+"/users/"+userID, nil)
    if err != nil {
        return nil, err
    }
    
    // Propagate trace context
    otel.GetTextMapPropagator().Inject(ctx, propagation.HeaderCarrier(req.Header))
    
    resp, err := s.httpClient.Do(req)
    if err != nil {
        span.RecordError(err)
        return nil, err
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != 200 {
        err := fmt.Errorf("user service returned %d", resp.StatusCode)
        span.RecordError(err)
        return nil, err
    }
    
    var user User
    if err := json.NewDecoder(resp.Body).Decode(&user); err != nil {
        span.RecordError(err)
        return nil, err
    }
    
    return &user, nil
}

func main() {
    // Initialize tracing
    tp := initTracer()
    defer tp.Shutdown(context.Background())
    
    // Create HTTP client with tracing
    client := &http.Client{
        Transport: otelhttp.NewTransport(http.DefaultTransport),
    }
    
    orderService := &OrderService{
        userServiceURL: "http://user-service:8080",
        httpClient:     client,
    }
    
    // HTTP server with tracing
    mux := http.NewServeMux()
    mux.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
        ctx := r.Context()
        
        // Extract baggage from incoming request
        bag := baggage.FromContext(ctx)
        if member := bag.Member("user.id"); member.Key() != "" {
            // Use baggage value
            userID := member.Value()
        }
        
        err := orderService.CreateOrder(ctx, "user123", "product456")
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }
        
        w.WriteHeader(http.StatusCreated)
    })
    
    // Wrap handler with tracing
    handler := otelhttp.NewHandler(mux, "order-service")
    
    http.ListenAndServe(":8080", handler)
}
```

## Structured Logging

### Structured Logging Implementation
```python
# Python structured logging with OpenTelemetry
import logging
import json
from opentelemetry import trace
from opentelemetry.instrumentation.logging import LoggingInstrumentor

# Configure structured logging
class StructuredFormatter(logging.Formatter):
    def format(self, record):
        # Get current span context
        span = trace.get_current_span()
        trace_id = None
        span_id = None
        
        if span.get_span_context().is_valid:
            trace_id = format(span.get_span_context().trace_id, '032x')
            span_id = format(span.get_span_context().span_id, '016x')
        
        log_entry = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        # Add trace context
        if trace_id:
            log_entry['trace_id'] = trace_id
            log_entry['span_id'] = span_id
        
        # Add custom fields
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        if hasattr(record, 'operation'):
            log_entry['operation'] = record.operation
        
        # Add exception info
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        
        return json.dumps(log_entry)

# Configure logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Add structured formatter
handler = logging.StreamHandler()
handler.setFormatter(StructuredFormatter())
logger.addHandler(handler)

# Instrument logging with OpenTelemetry
LoggingInstrumentor().instrument(set_logging_format=True)

# Usage example
class UserService:
    def __init__(self):
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def get_user(self, user_id):
        # Create structured log entry
        self.logger.info(
            "Fetching user",
            extra={
                'user_id': user_id,
                'operation': 'get_user',
                'service': 'user-service'
            }
        )
        
        try:
            # Simulate user lookup
            if user_id == "404":
                self.logger.warning(
                    "User not found",
                    extra={
                        'user_id': user_id,
                        'operation': 'get_user',
                        'result': 'not_found'
                    }
                )
                return None
            
            user = {'id': user_id, 'name': f'User {user_id}'}
            
            self.logger.info(
                "User fetched successfully",
                extra={
                    'user_id': user_id,
                    'operation': 'get_user',
                    'result': 'success',
                    'user_type': user.get('type', 'standard')
                }
            )
            
            return user
            
        except Exception as e:
            self.logger.error(
                "Failed to fetch user",
                extra={
                    'user_id': user_id,
                    'operation': 'get_user',
                    'result': 'error',
                    'error_type': type(e).__name__
                },
                exc_info=True
            )
            raise
```

### Log Correlation and Analysis
```javascript
// Node.js structured logging with correlation
const winston = require('winston');
const { trace, context } = require('@opentelemetry/api');

// Custom format for structured logs
const structuredFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf((info) => {
    // Add trace context
    const span = trace.getActiveSpan();
    if (span) {
      const spanContext = span.spanContext();
      info.trace_id = spanContext.traceId;
      info.span_id = spanContext.spanId;
    }
    
    // Add correlation ID from context
    const correlationId = context.active().getValue('correlationId');
    if (correlationId) {
      info.correlation_id = correlationId;
    }
    
    return JSON.stringify(info);
  })
);

// Configure logger
const logger = winston.createLogger({
  level: 'info',
  format: structuredFormat,
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

// Middleware for correlation ID
function correlationMiddleware(req, res, next) {
  const correlationId = req.headers['x-correlation-id'] || 
                       req.headers['x-request-id'] || 
                       generateCorrelationId();
  
  // Store in context
  const ctx = context.active().setValue('correlationId', correlationId);
  
  context.with(ctx, () => {
    res.setHeader('x-correlation-id', correlationId);
    next();
  });
}

// Usage in application
app.use(correlationMiddleware);

app.get('/api/users/:id', async (req, res) => {
  const userId = req.params.id;
  
  logger.info('Processing user request', {
    user_id: userId,
    operation: 'get_user',
    endpoint: '/api/users/:id',
    method: req.method,
    user_agent: req.get('User-Agent')
  });
  
  try {
    const user = await getUserFromDatabase(userId);
    
    logger.info('User request completed', {
      user_id: userId,
      operation: 'get_user',
      result: 'success',
      response_time_ms: Date.now() - req.startTime
    });
    
    res.json(user);
  } catch (error) {
    logger.error('User request failed', {
      user_id: userId,
      operation: 'get_user',
      result: 'error',
      error_message: error.message,
      error_stack: error.stack
    });
    
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

## Service Level Objectives (SLOs)

### SLO Definition and Implementation
```yaml
# SLO configuration with Sloth
apiVersion: sloth.slok.dev/v1
kind: PrometheusServiceLevel
metadata:
  name: api-availability
  namespace: monitoring
spec:
  service: "api-service"
  labels:
    team: "platform"
    service: "api"
  slis:
    - name: "requests-availability"
      objective: 99.9
      description: "API requests availability SLO"
      sli:
        events:
          error_query: |
            sum(rate(http_requests_total{job="api-service",code=~"5.."}[5m]))
          total_query: |
            sum(rate(http_requests_total{job="api-service"}[5m]))
      alerting:
        name: "APIAvailabilitySLO"
        labels:
          severity: "critical"
          team: "platform"
        annotations:
          summary: "API availability SLO is being burned"
          description: "API availability SLO burn rate is too high"
        page_alert:
          labels:
            severity: "critical"
        ticket_alert:
          labels:
            severity: "warning"

    - name: "requests-latency"
      objective: 95.0
      description: "API requests latency SLO"
      sli:
        events:
          error_query: |
            sum(rate(http_request_duration_seconds_bucket{job="api-service",le="0.5"}[5m]))
          total_query: |
            sum(rate(http_request_duration_seconds_count{job="api-service"}[5m]))
      alerting:
        name: "APILatencySLO"
        labels:
          severity: "warning"
```

### Error Budget Implementation
```python
# Error budget calculation and alerting
import time
from datetime import datetime, timedelta
from prometheus_client.parser import text_string_to_metric_families

class ErrorBudgetCalculator:
    def __init__(self, prometheus_url, slo_config):
        self.prometheus_url = prometheus_url
        self.slo_config = slo_config
    
    def calculate_error_budget(self, service_name, time_window_hours=24):
        """Calculate current error budget for a service"""
        
        # Get SLO configuration for service
        slo = self.slo_config.get(service_name, {})
        target_availability = slo.get('availability', 99.9)
        
        # Calculate allowed error budget
        total_budget = (100 - target_availability) / 100
        
        # Query Prometheus for actual error rate
        end_time = int(time.time())
        start_time = end_time - (time_window_hours * 3600)
        
        error_query = f'''
        sum(rate(http_requests_total{{service="{service_name}",status=~"5.."}[5m])) /
        sum(rate(http_requests_total{{service="{service_name}"}}[5m]))
        '''
        
        actual_error_rate = self.query_prometheus(error_query, start_time, end_time)
        
        # Calculate remaining error budget
        consumed_budget = actual_error_rate / total_budget if total_budget > 0 else 0
        remaining_budget = max(0, 1 - consumed_budget)
        
        return {
            'service': service_name,
            'target_availability': target_availability,
            'total_error_budget': total_budget,
            'actual_error_rate': actual_error_rate,
            'consumed_budget_percentage': consumed_budget * 100,
            'remaining_budget_percentage': remaining_budget * 100,
            'time_window_hours': time_window_hours,
            'status': self.get_budget_status(remaining_budget)
        }
    
    def get_budget_status(self, remaining_budget):
        """Determine error budget status"""
        if remaining_budget > 0.5:
            return 'healthy'
        elif remaining_budget > 0.1:
            return 'warning'
        else:
            return 'critical'
    
    def query_prometheus(self, query, start_time, end_time):
        """Query Prometheus for metrics"""
        # Implementation would make actual HTTP request to Prometheus
        # This is a simplified version
        import requests
        
        params = {
            'query': query,
            'start': start_time,
            'end': end_time,
            'step': '300'
        }
        
        response = requests.get(f"{self.prometheus_url}/api/v1/query_range", params=params)
        data = response.json()
        
        if data['status'] == 'success' and data['data']['result']:
            # Calculate average error rate over time window
            values = data['data']['result'][0]['values']
            error_rates = [float(value[1]) for value in values if value[1] != 'NaN']
            return sum(error_rates) / len(error_rates) if error_rates else 0
        
        return 0

# Usage example
slo_config = {
    'api-service': {
        'availability': 99.9,
        'latency_p95': 200,  # milliseconds
        'latency_p99': 500   # milliseconds
    },
    'user-service': {
        'availability': 99.5,
        'latency_p95': 100,
        'latency_p99': 300
    }
}

calculator = ErrorBudgetCalculator('http://prometheus:9090', slo_config)

# Calculate error budget for API service
budget = calculator.calculate_error_budget('api-service', time_window_hours=24)
print(f"Error budget status: {budget['status']}")
print(f"Remaining budget: {budget['remaining_budget_percentage']:.2f}%")

# Alert if error budget is being consumed too quickly
if budget['status'] == 'critical':
    # Send alert to incident management system
    send_alert({
        'service': budget['service'],
        'message': f"Error budget critically low: {budget['remaining_budget_percentage']:.2f}% remaining",
        'severity': 'critical'
    })
```

## Observability Best Practices

### Observability Strategy
```bash
# 1. Design for Observability
- Instrument from the beginning
- Use consistent naming conventions
- Implement proper error handling
- Add contextual information

# 2. Correlation and Context
- Use correlation IDs across services
- Propagate trace context
- Add business context to telemetry
- Implement structured logging

# 3. Signal Quality
- Focus on actionable metrics
- Reduce noise and false positives
- Implement proper sampling
- Use appropriate cardinality

# 4. Operational Excellence
- Define clear SLIs and SLOs
- Implement error budgets
- Create runbooks and playbooks
- Practice incident response
```

### Implementation Checklist
```bash
# Metrics
✓ Golden signals implemented
✓ Business metrics tracked
✓ SLIs and SLOs defined
✓ Error budgets calculated
✓ Alerting rules configured

# Traces
✓ Distributed tracing enabled
✓ Service dependencies mapped
✓ Critical path instrumented
✓ Context propagation working
✓ Sampling strategy implemented

# Logs
✓ Structured logging adopted
✓ Correlation IDs used
✓ Log levels appropriate
✓ Sensitive data excluded
✓ Retention policies set

# Dashboards and Alerting
✓ Service overview dashboards
✓ SLO-based alerting
✓ Incident response runbooks
✓ On-call procedures defined
✓ Post-incident reviews conducted
```