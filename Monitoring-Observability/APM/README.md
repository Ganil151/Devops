# Application Performance Monitoring (APM)

Complete guide to APM tools, implementation, and best practices for application observability.

## APM Fundamentals

### Key APM Metrics
```bash
# Golden Signals (SRE)
1. Latency - Time to process requests
2. Traffic - Rate of requests
3. Errors - Rate of failed requests
4. Saturation - Resource utilization

# RED Method (for services)
- Rate: Requests per second
- Errors: Error rate
- Duration: Response time distribution

# USE Method (for resources)
- Utilization: Resource usage percentage
- Saturation: Queue length or wait time
- Errors: Error count or rate
```

### APM Components
```bash
# Application Metrics
- Response times and throughput
- Error rates and exceptions
- Database query performance
- External service calls
- Memory and CPU usage

# User Experience Metrics
- Page load times
- User interactions
- Conversion rates
- Bounce rates
- Geographic performance

# Infrastructure Correlation
- Server performance impact
- Network latency effects
- Database performance
- Cache hit rates
- Queue depths
```

## New Relic APM

### Agent Installation and Configuration
```javascript
// Node.js New Relic setup
// newrelic.js
'use strict'

exports.config = {
  app_name: ['My Application'],
  license_key: 'your-license-key',
  logging: {
    level: 'info'
  },
  allow_all_headers: true,
  attributes: {
    exclude: [
      'request.headers.cookie',
      'request.headers.authorization',
      'request.headers.proxyAuthorization',
      'request.headers.setCookie*',
      'request.headers.x*',
      'response.headers.cookie',
      'response.headers.authorization',
      'response.headers.proxyAuthorization',
      'response.headers.setCookie*',
      'response.headers.x*'
    ]
  }
}

// Application instrumentation
require('newrelic');
const express = require('express');
const newrelic = require('newrelic');

const app = express();

// Custom metrics
app.get('/api/users', (req, res) => {
  // Record custom metric
  newrelic.recordMetric('Custom/API/Users/RequestCount', 1);
  
  // Add custom attributes
  newrelic.addCustomAttribute('userId', req.user?.id);
  newrelic.addCustomAttribute('userType', req.user?.type);
  newrelic.addCustomAttribute('endpoint', '/api/users');
  
  // Create custom span
  newrelic.startSegment('database-query', true, () => {
    // Database operation
    return getUsersFromDatabase();
  });
  
  res.json({ users: [] });
});

// Error tracking
app.use((err, req, res, next) => {
  newrelic.noticeError(err, {
    customAttributes: {
      userId: req.user?.id,
      endpoint: req.path,
      method: req.method
    }
  });
  res.status(500).json({ error: 'Internal Server Error' });
});
```

### Python New Relic Integration
```python
# Python New Relic setup
import newrelic.agent
from flask import Flask, request

# Initialize New Relic
newrelic.agent.initialize('newrelic.ini')

app = Flask(__name__)

@newrelic.agent.function_trace()
def process_user_data(user_id):
    """Custom function tracing"""
    # Add custom attributes
    newrelic.agent.add_custom_attribute('user_id', user_id)
    newrelic.agent.add_custom_attribute('function', 'process_user_data')
    
    # Simulate processing
    import time
    time.sleep(0.1)
    
    return {"processed": True}

@app.route('/api/process/<user_id>')
@newrelic.agent.web_transaction(name='process_user')
def process_user(user_id):
    # Record custom metric
    newrelic.agent.record_custom_metric('Custom/Users/ProcessedCount', 1)
    
    # Create custom span
    with newrelic.agent.BackgroundTask(application, 'process_user_data'):
        result = process_user_data(user_id)
    
    return result

# Database query tracing
@newrelic.agent.database_trace('PostgreSQL', 'SELECT', 'users')
def get_user_by_id(user_id):
    # Database operation
    return db.execute("SELECT * FROM users WHERE id = %s", [user_id])

# External service tracing
@newrelic.agent.external_trace('httpbin.org', 'requests')
def call_external_service():
    import requests
    return requests.get('https://httpbin.org/json')
```

## Datadog APM

### Agent Setup and Configuration
```yaml
# datadog.yaml
api_key: "your-api-key"
site: "datadoghq.com"

# APM configuration
apm_config:
  enabled: true
  env: production
  
# Logs configuration
logs_enabled: true
logs_config:
  container_collect_all: true

# Process monitoring
process_config:
  enabled: "true"

# Network monitoring
network_config:
  enabled: true
```

### Application Instrumentation
```python
# Python Datadog APM
from ddtrace import tracer, patch_all
from ddtrace.contrib.flask import TraceMiddleware
from flask import Flask

# Auto-instrument common libraries
patch_all()

app = Flask(__name__)
TraceMiddleware(app, tracer, service="my-app", distributed_tracing=True)

@app.route('/api/data')
def get_data():
    # Custom span
    with tracer.trace("database.query", service="postgres") as span:
        span.set_tag("query.type", "SELECT")
        span.set_tag("db.statement", "SELECT * FROM users")
        span.set_tag("db.user", "app_user")
        
        # Simulate database query
        import time
        time.sleep(0.1)
        
        return {"data": "example"}

# Custom metrics
from datadog import statsd

@app.route('/api/process')
def process_data():
    # Increment counter
    statsd.increment('api.requests', tags=['endpoint:process', 'env:production'])
    
    # Record timing
    with statsd.timed('api.process.duration', tags=['endpoint:process']):
        # Process data
        time.sleep(0.2)
    
    # Record gauge
    statsd.gauge('api.queue.size', 42, tags=['queue:main'])
    
    return {"status": "processed"}

# Error tracking
@app.errorhandler(Exception)
def handle_exception(e):
    # Add error tags to current span
    span = tracer.current_span()
    if span:
        span.set_tag("error", True)
        span.set_tag("error.msg", str(e))
        span.set_tag("error.type", type(e).__name__)
    
    return {"error": "Internal server error"}, 500
```

### Go Datadog Integration
```go
// Go Datadog APM
package main

import (
    "net/http"
    "time"
    
    "gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
    "gopkg.in/DataDog/dd-trace-go.v1/contrib/net/http"
    "gopkg.in/DataDog/dd-trace-go.v1/contrib/database/sql"
)

func main() {
    // Start tracer
    tracer.Start(
        tracer.WithService("my-go-app"),
        tracer.WithEnv("production"),
    )
    defer tracer.Stop()
    
    // Instrument HTTP server
    mux := httptrace.NewServeMux()
    mux.HandleFunc("/api/users", getUsersHandler)
    
    http.ListenAndServe(":8080", mux)
}

func getUsersHandler(w http.ResponseWriter, r *http.Request) {
    // Create custom span
    span, ctx := tracer.StartSpanFromContext(r.Context(), "get.users")
    defer span.Finish()
    
    // Add tags
    span.SetTag("user.id", r.Header.Get("User-ID"))
    span.SetTag("endpoint", "/api/users")
    
    // Database operation with tracing
    users, err := getUsersFromDB(ctx)
    if err != nil {
        span.SetTag("error", true)
        span.SetTag("error.msg", err.Error())
        http.Error(w, "Internal Server Error", 500)
        return
    }
    
    // Custom metric
    statsd.Incr("api.users.requests", []string{"endpoint:/api/users"}, 1)
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

func getUsersFromDB(ctx context.Context) ([]User, error) {
    // Traced database connection
    db, err := sqltrace.Open("postgres", "postgres://user:pass@host/db")
    if err != nil {
        return nil, err
    }
    
    // Query with context for tracing
    rows, err := db.QueryContext(ctx, "SELECT id, name FROM users")
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var users []User
    for rows.Next() {
        var user User
        err := rows.Scan(&user.ID, &user.Name)
        if err != nil {
            return nil, err
        }
        users = append(users, user)
    }
    
    return users, nil
}
```

## OpenTelemetry Implementation

### OpenTelemetry Setup
```javascript
// Node.js OpenTelemetry
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');
const { PrometheusExporter } = require('@opentelemetry/exporter-prometheus');

// Initialize SDK
const sdk = new NodeSDK({
  traceExporter: new JaegerExporter({
    endpoint: 'http://jaeger:14268/api/traces',
  }),
  metricExporter: new PrometheusExporter({
    port: 9090,
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

// Manual instrumentation
const { trace, metrics } = require('@opentelemetry/api');

const tracer = trace.getTracer('my-app', '1.0.0');
const meter = metrics.getMeter('my-app', '1.0.0');

// Custom metrics
const requestCounter = meter.createCounter('http_requests_total', {
  description: 'Total number of HTTP requests',
});

const requestDuration = meter.createHistogram('http_request_duration_seconds', {
  description: 'Duration of HTTP requests in seconds',
});

// Express middleware
app.use((req, res, next) => {
  const span = tracer.startSpan(`${req.method} ${req.path}`);
  const startTime = Date.now();
  
  // Add attributes
  span.setAttributes({
    'http.method': req.method,
    'http.url': req.url,
    'http.user_agent': req.get('User-Agent'),
  });
  
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    
    // Update metrics
    requestCounter.add(1, {
      method: req.method,
      status_code: res.statusCode.toString(),
    });
    
    requestDuration.record(duration, {
      method: req.method,
      status_code: res.statusCode.toString(),
    });
    
    // Update span
    span.setAttributes({
      'http.status_code': res.statusCode,
      'http.response_size': res.get('Content-Length') || 0,
    });
    
    if (res.statusCode >= 400) {
      span.recordException(new Error(`HTTP ${res.statusCode}`));
      span.setStatus({ code: trace.SpanStatusCode.ERROR });
    }
    
    span.end();
  });
  
  next();
});
```

### Java OpenTelemetry
```java
// Java OpenTelemetry setup
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.context.Scope;

@RestController
public class UserController {
    
    private static final Tracer tracer = GlobalOpenTelemetry.getTracer("my-app");
    
    @GetMapping("/api/users/{id}")
    public ResponseEntity<User> getUser(@PathVariable String id) {
        Span span = tracer.spanBuilder("get-user")
            .setAttribute("user.id", id)
            .setAttribute("operation", "get-user")
            .startSpan();
        
        try (Scope scope = span.makeCurrent()) {
            // Add custom attributes
            span.setAttribute("service.name", "user-service");
            span.setAttribute("service.version", "1.0.0");
            
            // Database operation
            User user = getUserFromDatabase(id);
            
            if (user == null) {
                span.setStatus(StatusCode.ERROR, "User not found");
                return ResponseEntity.notFound().build();
            }
            
            span.setAttribute("user.found", true);
            return ResponseEntity.ok(user);
            
        } catch (Exception e) {
            span.recordException(e);
            span.setStatus(StatusCode.ERROR, e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
    
    private User getUserFromDatabase(String id) {
        Span dbSpan = tracer.spanBuilder("database-query")
            .setAttribute("db.system", "postgresql")
            .setAttribute("db.statement", "SELECT * FROM users WHERE id = ?")
            .setAttribute("db.operation", "SELECT")
            .startSpan();
        
        try (Scope scope = dbSpan.makeCurrent()) {
            // Simulate database query
            Thread.sleep(50);
            return userRepository.findById(id);
        } catch (Exception e) {
            dbSpan.recordException(e);
            throw e;
        } finally {
            dbSpan.end();
        }
    }
}
```

## Distributed Tracing

### Jaeger Setup
```yaml
# docker-compose.yml for Jaeger
version: '3.8'
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - monitoring

  # OpenTelemetry Collector
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    ports:
      - "4317:4317"   # OTLP gRPC receiver
      - "4318:4318"   # OTLP HTTP receiver
      - "8889:8889"   # Prometheus metrics
    depends_on:
      - jaeger
    networks:
      - monitoring
```

### OpenTelemetry Collector Configuration
```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024
  
  memory_limiter:
    limit_mib: 512
  
  resource:
    attributes:
      - key: environment
        value: production
        action: upsert

exporters:
  jaeger:
    endpoint: jaeger:14250
    tls:
      insecure: true
  
  prometheus:
    endpoint: "0.0.0.0:8889"
  
  logging:
    loglevel: debug

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [jaeger, logging]
    
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [prometheus, logging]
```

## Real User Monitoring (RUM)

### Frontend RUM Implementation
```javascript
// Browser RUM with custom metrics
class RUMCollector {
    constructor(config) {
        this.config = config;
        this.metrics = [];
        this.init();
    }
    
    init() {
        // Performance observer for navigation timing
        if ('PerformanceObserver' in window) {
            const observer = new PerformanceObserver((list) => {
                for (const entry of list.getEntries()) {
                    this.collectMetric(entry);
                }
            });
            
            observer.observe({ entryTypes: ['navigation', 'resource', 'paint'] });
        }
        
        // Core Web Vitals
        this.collectCoreWebVitals();
        
        // Custom user interactions
        this.trackUserInteractions();
        
        // Error tracking
        this.trackErrors();
    }
    
    collectCoreWebVitals() {
        // Largest Contentful Paint (LCP)
        new PerformanceObserver((entryList) => {
            const entries = entryList.getEntries();
            const lastEntry = entries[entries.length - 1];
            
            this.sendMetric({
                name: 'lcp',
                value: lastEntry.startTime,
                timestamp: Date.now(),
                url: window.location.href
            });
        }).observe({ entryTypes: ['largest-contentful-paint'] });
        
        // First Input Delay (FID)
        new PerformanceObserver((entryList) => {
            for (const entry of entryList.getEntries()) {
                this.sendMetric({
                    name: 'fid',
                    value: entry.processingStart - entry.startTime,
                    timestamp: Date.now(),
                    url: window.location.href
                });
            }
        }).observe({ entryTypes: ['first-input'] });
        
        // Cumulative Layout Shift (CLS)
        let clsValue = 0;
        new PerformanceObserver((entryList) => {
            for (const entry of entryList.getEntries()) {
                if (!entry.hadRecentInput) {
                    clsValue += entry.value;
                }
            }
            
            this.sendMetric({
                name: 'cls',
                value: clsValue,
                timestamp: Date.now(),
                url: window.location.href
            });
        }).observe({ entryTypes: ['layout-shift'] });
    }
    
    trackUserInteractions() {
        // Click tracking
        document.addEventListener('click', (event) => {
            this.sendMetric({
                name: 'user_interaction',
                type: 'click',
                element: event.target.tagName,
                timestamp: Date.now(),
                url: window.location.href
            });
        });
        
        // Page visibility
        document.addEventListener('visibilitychange', () => {
            this.sendMetric({
                name: 'page_visibility',
                visible: !document.hidden,
                timestamp: Date.now(),
                url: window.location.href
            });
        });
    }
    
    trackErrors() {
        // JavaScript errors
        window.addEventListener('error', (event) => {
            this.sendMetric({
                name: 'javascript_error',
                message: event.message,
                filename: event.filename,
                lineno: event.lineno,
                colno: event.colno,
                timestamp: Date.now(),
                url: window.location.href
            });
        });
        
        // Unhandled promise rejections
        window.addEventListener('unhandledrejection', (event) => {
            this.sendMetric({
                name: 'unhandled_rejection',
                reason: event.reason,
                timestamp: Date.now(),
                url: window.location.href
            });
        });
    }
    
    sendMetric(metric) {
        // Send to APM service
        fetch(this.config.endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.config.apiKey}`
            },
            body: JSON.stringify(metric)
        }).catch(err => console.error('Failed to send metric:', err));
    }
}

// Initialize RUM
const rum = new RUMCollector({
    endpoint: 'https://api.example.com/rum',
    apiKey: 'your-api-key'
});
```

## APM Best Practices

### Performance Monitoring Strategy
```bash
# 1. Define SLIs and SLOs
- Response time: 95th percentile < 200ms
- Availability: 99.9% uptime
- Error rate: < 0.1% of requests
- Throughput: Handle 1000 RPS

# 2. Implement proper instrumentation
- Automatic instrumentation for frameworks
- Custom spans for business logic
- Database query tracing
- External service calls

# 3. Error tracking and alerting
- Capture all exceptions
- Add contextual information
- Set up intelligent alerting
- Implement error budgets

# 4. Performance optimization
- Identify bottlenecks
- Optimize database queries
- Implement caching strategies
- Monitor resource utilization
```

### Monitoring Implementation Checklist
```bash
# Application Level
✓ Response time monitoring
✓ Error rate tracking
✓ Throughput measurement
✓ Database performance
✓ External service monitoring
✓ Custom business metrics

# Infrastructure Level
✓ CPU and memory usage
✓ Disk I/O and network
✓ Container metrics
✓ Load balancer health
✓ Cache performance

# User Experience
✓ Real user monitoring
✓ Core Web Vitals
✓ Page load times
✓ User journey tracking
✓ Geographic performance

# Alerting and Incident Response
✓ SLO-based alerting
✓ Escalation procedures
✓ Runbook automation
✓ Post-incident reviews
```