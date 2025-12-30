# Safety and Circuit Breakers

The most dangerous thing in production is **uncontrolled automation**. Safety mechanisms prevent your "helper" from becoming a "destroyer."

## The Circuit Breaker Pattern
Borrowed from electrical engineering, a circuit breaker "trips" (disables) automation after repeated failures.

### Implementation Logic
```python
class CircuitBreaker:
    def __init__(self, max_failures=3, timeout=300):
        self.failures = 0
        self.max_failures = max_failures
        self.timeout = timeout
        self.last_failure_time = None
        self.state = "CLOSED"  # CLOSED = working, OPEN = disabled
    
    def call(self, func):
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "HALF_OPEN"  # Try again
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func()
            self.failures = 0
            self.state = "CLOSED"
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure_time = time.time()
            if self.failures >= self.max_failures:
                self.state = "OPEN"
            raise e
```

---

## Core Safety Guardrails

### 1. Retry Throttling
Never attempt the same fix more than **N times** in a given time window.
- **Example**: "Restart service max 3 times per hour."

### 2. Fleet Percentage Limits
Never allow automation to affect more than **X%** of your fleet simultaneously.
- **Example**: "Auto-scale max 20% of instances at once."

### 3. Maintenance Windows
Disable auto-remediation during planned changes to avoid conflicts.
- **Example**: "Pause automation during deploy window (2-3 AM UTC)."

### 4. Dead-Man's Switch
A global "Kill Switch" to disable all automation instantly.
- **Implementation**: Environment variable or feature flag.

### 5. Blast Radius Containment
Test automation in staging first, then canary to 1% of production.

---

## 🏗️ Real-Life Scenario: The "Runaway Scaler"
**Problem**: An auto-scaler is configured to add instances when CPU > 70%.
**Bug**: A code change causes CPU to spike to 100% regardless of load.
**Crisis**: The auto-scaler adds 500 instances in 10 minutes, costing $10,000/hour.
**Outcome**: The company's AWS account is suspended for suspicious activity.
**Fix**: Implement a **Fleet Percentage Limit** (max 50 instances) and a **Cost Alert** that disables scaling if hourly cost > $1,000.

---

## ❓ Interview Questions
1.  **What is a Circuit Breaker and why is it essential for auto-remediation?**
    *   *Answer*: It's a safety mechanism that disables automation after repeated failures, preventing infinite loops and cascading failures. It's essential because it ensures automation doesn't make an outage worse.
2.  **Describe a 'Dead-Man's Switch' in the context of automation.**
    *   *Answer*: It's an emergency control that allows operators to instantly disable all automation across the entire system, typically used during novel or catastrophic failures where automation might interfere with manual recovery.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What does a Circuit Breaker do after max failures?** (Opens/Disables automation)
2.  **True/False: You should allow automation to restart all servers simultaneously.** (False - use fleet limits)
3.  **What is 'Retry Throttling'?** (Limiting the number of retry attempts in a time window)
4.  **Should automation run during maintenance windows?** (No - pause it)
5.  **What is a 'Dead-Man's Switch'?** (Emergency kill switch for all automation)
