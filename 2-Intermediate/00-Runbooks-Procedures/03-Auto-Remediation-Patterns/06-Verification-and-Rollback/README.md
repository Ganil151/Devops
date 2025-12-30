# Verification and Rollback

The most critical—and most often skipped—step in auto-remediation is **verification**. Without it, you're flying blind.

## Verification Strategies

### 1. Health Check Verification
After remediation, query the service's health endpoint.
```bash
# Wait for service to stabilize
sleep 30

# Check health
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$response" != "200" ]; then
    echo "Remediation failed - service unhealthy"
    exit 1
fi
```

### 2. Metric-Based Verification
Confirm that the problematic metric has returned to normal.
```python
def verify_disk_cleanup():
    current_usage = get_disk_usage()
    if current_usage < 80:
        return True
    else:
        raise Exception(f"Disk still at {current_usage}%")
```

### 3. Synthetic Transaction
Run a real user workflow to confirm functionality.
```bash
# Test login flow
response=$(curl -X POST https://api.example.com/login \
  -d '{"user":"test","pass":"test"}')
if [[ $response == *"token"* ]]; then
    echo "Login successful"
else
    echo "Login failed - rollback needed"
fi
```

### 4. Timeout-Based Verification
If verification doesn't pass within N seconds, consider it failed.

---

## Rollback Strategies

### 1. Service Rollback
If a restart made things worse, revert to the previous version.
```bash
# Kubernetes
kubectl rollout undo deployment/api-server

# Docker
docker stop new-container && docker start old-container
```

### 2. Configuration Rollback
If a config change caused issues, revert to the previous config.
```bash
# Git-based config
git revert HEAD
kubectl apply -f config.yaml
```

### 3. Scaling Rollback
If auto-scaling caused issues, scale back down.
```bash
# Kubernetes
kubectl scale deployment/api-server --replicas=3
```

### 4. The "Do Nothing" Rollback
Sometimes the best rollback is to stop trying and page a human.

---

## 🏗️ Real-Life Scenario: The "Successful Failure"
**Problem**: An auto-remediation script restarts a database. The script reports "Success."
**Hidden Issue**: The database starts but is in "Read-Only" mode due to a corrupted index.
**Outcome**: The application can't write data. Users see errors. The automation thinks everything is fine.
**Fix**: Add **Verification**: After restart, run a test write query. If it fails, trigger rollback and page the DBA.

---

## ❓ Interview Questions
1.  **Why is verification more important than the remediation action itself?**
    *   *Answer*: Because a remediation can complete successfully without actually fixing the problem. Verification ensures the desired outcome was achieved and prevents false positives.
2.  **What should you do if verification fails?**
    *   *Answer*: Immediately rollback the change (if possible), escalate to a human, and log detailed information about what was attempted and why it failed.

---

## 🧠 Quiz Snippet (5/50+)
1.  **What is the purpose of verification?** (Confirm the remediation actually fixed the problem)
2.  **True/False: You should skip verification to make automation faster.** (False)
3.  **What is a 'Synthetic Transaction'?** (A test that simulates real user behavior)
4.  **How do you rollback a Kubernetes deployment?** (`kubectl rollout undo`)
5.  **What should happen if verification times out?** (Treat as failure and escalate)
