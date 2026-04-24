# Testing in DevOps

Complete guide to testing strategies, tools, and practices in DevOps environments.

## Testing Pyramid

### Unit Testing (70%)
```bash
# Fast, isolated tests
# Developer-focused
# High coverage target
# Mock external dependencies

# Example: Jest (JavaScript)
describe('Calculator', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(add(1, 2)).toBe(3);
  });
});

# Example: pytest (Python)
def test_add():
    assert add(1, 2) == 3

# Example: JUnit (Java)
@Test
public void testAdd() {
    assertEquals(3, Calculator.add(1, 2));
}
```

### Integration Testing (20%)
```bash
# Component interaction testing
# API and database integration
# Service communication validation

# Example: API Testing
curl -X POST http://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# Database Integration Test
def test_user_creation():
    user = create_user("John", "john@example.com")
    saved_user = db.get_user(user.id)
    assert saved_user.name == "John"
```

### End-to-End Testing (10%)
```bash
# Full user journey validation
# UI automation
# Cross-browser testing
# Performance validation

# Example: Selenium WebDriver
from selenium import webdriver
driver = webdriver.Chrome()
driver.get("https://example.com")
driver.find_element_by_id("login").click()
assert "Dashboard" in driver.title
```

## Security Testing

### SAST (Static Application Security Testing)
```bash
# Code analysis without execution
# Early vulnerability detection
# IDE integration

# SonarQube
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000

# Checkmarx
cx scan create --project-name "MyApp" --source-dir ./src

# Semgrep
semgrep --config=auto ./src
```

### DAST (Dynamic Application Security Testing)
```bash
# Runtime security testing
# Black-box testing approach
# Production-like environment

# OWASP ZAP
zap-baseline.py -t http://example.com

# Burp Suite
java -jar burpsuite_community.jar

# Nikto
nikto -h http://example.com
```

### IAST (Interactive Application Security Testing)
```bash
# Runtime code analysis
# Real-time vulnerability detection
# Combines SAST and DAST benefits

# Contrast Security
# Agent-based approach
java -javaagent:contrast.jar -jar myapp.jar

# Veracode IAST
# Runtime analysis with code insight
```

## Performance Testing

### Load Testing
```bash
# Normal expected load
# Performance baseline
# Response time validation

# Apache JMeter
jmeter -n -t test-plan.jmx -l results.jtl

# Artillery
artillery run load-test.yml

# k6
k6 run --vus 10 --duration 30s script.js
```

### Stress Testing
```bash
# Beyond normal capacity
# Breaking point identification
# System behavior under stress

# Example k6 stress test
import http from 'k6/http';
import { check } from 'k6';

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
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

### Volume Testing
```bash
# Large amounts of data
# Database performance
# Storage capacity testing

# Database volume test
for i in {1..1000000}; do
  mysql -e "INSERT INTO users (name, email) VALUES ('User$i', 'user$i@example.com');"
done
```

## CI/CD Testing Integration

### Pipeline Testing Stages
```yaml
# GitHub Actions Example
name: CI/CD Pipeline
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Unit Tests
        run: npm test
      
      - name: Integration Tests
        run: npm run test:integration
      
      - name: Security Scan
        uses: securecodewarrior/github-action-add-sarif@v1
        with:
          sarif-file: security-results.sarif
      
      - name: Performance Tests
        run: k6 run performance-test.js
      
      - name: Deploy to Staging
        if: github.ref == 'refs/heads/main'
        run: ./deploy-staging.sh
      
      - name: E2E Tests
        run: npm run test:e2e
```

### Quality Gates
```bash
# SonarQube Quality Gate
# Minimum coverage: 80%
# No critical vulnerabilities
# Technical debt ratio < 5%

# Jenkins Pipeline Quality Gate
pipeline {
    stages {
        stage('Quality Gate') {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }
    }
}
```

## Test Automation Tools

### Web UI Testing
```bash
# Selenium WebDriver
# Cross-browser automation
# Multiple language bindings

# Cypress
# Modern web testing
# Real-time browser testing
describe('Login Flow', () => {
  it('should login successfully', () => {
    cy.visit('/login');
    cy.get('[data-cy=username]').type('user@example.com');
    cy.get('[data-cy=password]').type('password');
    cy.get('[data-cy=submit]').click();
    cy.url().should('include', '/dashboard');
  });
});

# Playwright
# Multi-browser support
# Auto-wait capabilities
const { test, expect } = require('@playwright/test');

test('login test', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#username', 'user@example.com');
  await page.fill('#password', 'password');
  await page.click('#submit');
  await expect(page).toHaveURL('/dashboard');
});
```

### API Testing
```bash
# Postman/Newman
newman run collection.json -e environment.json

# REST Assured (Java)
given()
  .contentType(ContentType.JSON)
  .body(user)
.when()
  .post("/api/users")
.then()
  .statusCode(201)
  .body("name", equalTo("John"));

# Supertest (Node.js)
request(app)
  .post('/api/users')
  .send({ name: 'John', email: 'john@example.com' })
  .expect(201)
  .expect('Content-Type', /json/);
```

## Container Testing

### Docker Image Testing
```bash
# Container Structure Test
container-structure-test test --image myapp:latest --config test-config.yaml

# Hadolint (Dockerfile linting)
hadolint Dockerfile

# Trivy (Vulnerability scanning)
trivy image myapp:latest

# Test Configuration
# test-config.yaml
schemaVersion: '2.0.0'
commandTests:
  - name: "check app is installed"
    command: "which"
    args: ["myapp"]
    expectedOutput: ["/usr/local/bin/myapp"]
fileExistenceTests:
  - name: "config file exists"
    path: "/etc/myapp/config.yml"
    shouldExist: true
```

### Kubernetes Testing
```bash
# Helm Test
helm test myapp

# Kubernetes Test Jobs
apiVersion: batch/v1
kind: Job
metadata:
  name: integration-test
spec:
  template:
    spec:
      containers:
      - name: test
        image: test-runner:latest
        command: ["npm", "run", "test:integration"]
      restartPolicy: Never
```

## Test Data Management

### Test Data Generation
```bash
# Faker.js (JavaScript)
const faker = require('faker');
const user = {
  name: faker.name.findName(),
  email: faker.internet.email(),
  address: faker.address.streetAddress()
};

# Factory Boy (Python)
class UserFactory(factory.Factory):
    class Meta:
        model = User
    
    name = factory.Faker('name')
    email = factory.Faker('email')
    created_at = factory.Faker('date_time')
```

### Database Testing
```bash
# Test Database Setup
# Docker Compose for test DB
version: '3'
services:
  test-db:
    image: postgres:13
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: testuser
      POSTGRES_PASSWORD: testpass
    ports:
      - "5433:5432"

# Database Migration Testing
# Test up and down migrations
./migrate up
./run-tests.sh
./migrate down
```

## Monitoring and Reporting

### Test Metrics
```bash
# Key Test Metrics
- Test Coverage Percentage
- Test Execution Time
- Test Pass/Fail Rate
- Defect Detection Rate
- Mean Time to Detection (MTTD)
- Mean Time to Resolution (MTTR)

# Coverage Reports
# Jest Coverage
npm test -- --coverage

# JaCoCo (Java)
mvn jacoco:report

# Coverage.py (Python)
coverage run -m pytest
coverage report
coverage html
```

### Test Reporting
```bash
# Allure Reports
# Generate test reports
allure generate allure-results --clean -o allure-report
allure serve allure-results

# TestNG Reports (Java)
# Built-in HTML reports
# Custom listeners for enhanced reporting

# Mochawesome (Node.js)
# Rich HTML reports for Mocha tests
npm test -- --reporter mochawesome
```

## Best Practices

### Test Strategy
```bash
# Test Early and Often
- Shift-left testing approach
- Test-driven development (TDD)
- Behavior-driven development (BDD)
- Continuous testing in CI/CD

# Test Environment Management
- Environment parity
- Infrastructure as Code for test environments
- Containerized test environments
- Data anonymization for testing

# Test Maintenance
- Regular test review and cleanup
- Flaky test identification and fixing
- Test code quality standards
- Test documentation
```

### Security Testing Best Practices
```bash
# Secure Test Data
- No production data in tests
- Synthetic test data generation
- Data masking and anonymization
- Secure credential management

# Vulnerability Management
- Regular security scans
- Dependency vulnerability checks
- Container image scanning
- Infrastructure security testing
```

---
## 🧭 Additional Modules
- [API Testing](api-testing/readme.md)
- [Integration Testing](integration-testing/readme.md)
- [Performance Testing](performance-testing/readme.md)
- [Security Testing](security-testing/readme.md)
- [Unit Testing](unit-testing/readme.md)
