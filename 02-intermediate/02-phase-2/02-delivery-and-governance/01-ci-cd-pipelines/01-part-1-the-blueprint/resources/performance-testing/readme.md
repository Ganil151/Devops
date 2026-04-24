# Performance Testing

Complete guide to performance testing tools, strategies, and implementation.

## Performance Testing Types

### Load Testing
```bash
# Normal expected load
# Performance baseline
# Response time validation

# k6 Load Test
import http from 'k6/http';
import { check } from 'k6';

export let options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  let response = http.get('https://api.example.com/users');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

### Stress Testing
```javascript
// k6 Stress Test
export let options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '10m', target: 0 },
  ],
};

export default function() {
  let response = http.get('https://api.example.com');
  check(response, {
    'status is 200': (r) => r.status === 200,
  });
}
```

### Volume Testing
```bash
# Large data volume testing
# Database performance under load
# Storage capacity testing

# JMeter Volume Test
# Test with large datasets
for i in {1..1000000}; do
  curl -X POST http://api.example.com/data \
    -d "data=record_$i"
done
```

## Performance Testing Tools

### Apache JMeter
```xml
<!-- JMeter Test Plan -->
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2">
  <hashTree>
    <TestPlan testname="API Load Test">
      <elementProp name="TestPlan.arguments" elementType="Arguments" guiclass="ArgumentsPanel">
        <collectionProp name="Arguments.arguments"/>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup testname="Users">
        <stringProp name="ThreadGroup.num_threads">100</stringProp>
        <stringProp name="ThreadGroup.ramp_time">60</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
      </ThreadGroup>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

### Artillery
```yaml
# artillery-config.yml
config:
  target: 'https://api.example.com'
  phases:
    - duration: 60
      arrivalRate: 10
    - duration: 120
      arrivalRate: 50
    - duration: 60
      arrivalRate: 10

scenarios:
  - name: "Get users"
    weight: 70
    flow:
      - get:
          url: "/users"
  - name: "Create user"
    weight: 30
    flow:
      - post:
          url: "/users"
          json:
            name: "Test User"
            email: "test@example.com"
```

### Gatling
```scala
// Gatling Performance Test
import io.gatling.core.Predef._
import io.gatling.http.Predef._

class UserSimulation extends Simulation {
  val httpProtocol = http
    .baseUrl("https://api.example.com")
    .acceptHeader("application/json")

  val scn = scenario("User API Test")
    .exec(http("Get Users")
      .get("/users")
      .check(status.is(200)))
    .pause(1)
    .exec(http("Create User")
      .post("/users")
      .body(StringBody("""{"name":"Test","email":"test@example.com"}"""))
      .check(status.is(201)))

  setUp(
    scn.inject(rampUsers(100) during (60 seconds))
  ).protocols(httpProtocol)
}
```

## Database Performance Testing

### SQL Performance Testing
```sql
-- Database Load Testing
-- Generate test data
INSERT INTO users (name, email, created_at)
SELECT 
  'User' || generate_series(1, 1000000),
  'user' || generate_series(1, 1000000) || '@example.com',
  NOW() - (random() * interval '365 days')
FROM generate_series(1, 1000000);

-- Performance queries
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user500000@example.com';

-- Index performance testing
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

### MongoDB Performance Testing
```javascript
// MongoDB Load Test
db.users.insertMany(
  Array.from({length: 1000000}, (_, i) => ({
    name: `User${i}`,
    email: `user${i}@example.com`,
    createdAt: new Date()
  }))
);

// Query performance
db.users.find({email: "user500000@example.com"}).explain("executionStats");

// Index creation and testing
db.users.createIndex({email: 1});
```

## Application Performance Monitoring

### Metrics Collection
```javascript
// Node.js Performance Monitoring
const prometheus = require('prom-client');

// Custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

// Middleware to collect metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  
  next();
});
```

### Memory and CPU Profiling
```bash
# Node.js Profiling
# CPU Profiling
node --prof app.js
node --prof-process isolate-*.log > processed.txt

# Memory Profiling
node --inspect app.js
# Use Chrome DevTools for memory analysis

# Heap Snapshots
const v8 = require('v8');
const fs = require('fs');

function takeHeapSnapshot() {
  const heapSnapshot = v8.writeHeapSnapshot();
  console.log('Heap snapshot written to', heapSnapshot);
}
```

## CI/CD Performance Testing

### GitHub Actions
```yaml
name: Performance Tests
on: [push, pull_request]

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup k6
        run: |
          sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6
      
      - name: Run performance tests
        run: k6 run performance-test.js
      
      - name: Upload results
        uses: actions/upload-artifact@v2
        with:
          name: performance-results
          path: results.json
```

### Jenkins Pipeline
```groovy
pipeline {
    agent any
    
    stages {
        stage('Performance Test') {
            steps {
                sh 'k6 run --out json=results.json performance-test.js'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'results.json'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'reports',
                        reportFiles: 'performance-report.html',
                        reportName: 'Performance Report'
                    ])
                }
            }
        }
    }
}
```

## Performance Benchmarking

### Baseline Establishment
```bash
# Performance Baseline
# Response Time: < 200ms (95th percentile)
# Throughput: > 1000 requests/second
# Error Rate: < 0.1%
# CPU Usage: < 70%
# Memory Usage: < 80%

# Benchmark Script
#!/bin/bash
echo "Running performance benchmark..."

# Run load test
k6 run --vus 50 --duration 5m benchmark.js > results.txt

# Extract metrics
RESPONSE_TIME=$(grep "http_req_duration" results.txt | awk '{print $4}')
THROUGHPUT=$(grep "http_reqs" results.txt | awk '{print $4}')
ERROR_RATE=$(grep "http_req_failed" results.txt | awk '{print $4}')

echo "Response Time (95th): $RESPONSE_TIME"
echo "Throughput: $THROUGHPUT req/s"
echo "Error Rate: $ERROR_RATE%"
```