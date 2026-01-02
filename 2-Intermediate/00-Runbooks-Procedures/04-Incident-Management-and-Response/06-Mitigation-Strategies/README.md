# Mitigation Strategies

Mitigation is about **stopping the bleeding**, not finding the root cause. Speed matters more than perfection.

## The Mitigation Hierarchy

### 1. Rollback (Fastest)
Revert to the last known good state.
```bash
# Kubernetes
kubectl rollout undo deployment/api-server

# Git-based deployment
git revert HEAD && git push
```
**When**: Recent deployment caused the issue.
**Time**: < 2 minutes.

### 2. Feature Flag Disable
Turn off the problematic feature without full rollback.
```python
if feature_flags.is_enabled("new_checkout"):
    # New code
else:
    # Old stable code
```
**When**: Specific feature is broken but rest of app is fine.
**Time**: < 30 seconds.

### 3. Traffic Rerouting
Redirect traffic away from failing component.
- **DNS**: Point to backup region.
- **Load Balancer**: Remove unhealthy instances.
- **CDN**: Serve cached version.

**When**: Infrastructure failure in one region/zone.
**Time**: 1-5 minutes.

### 4. Scaling (Horizontal)
Add more capacity to handle load.
```bash
# Kubernetes
kubectl scale deployment/api-server --replicas=10

# AWS
aws autoscaling set-desired-capacity --desired-capacity 20
```
**When**: Performance degradation due to load.
**Time**: 2-5 minutes (depending on boot time).

### 5. Emergency Patch (Slowest)
Deploy a hotfix.
**When**: No other option available.
**Time**: 15-60 minutes.
**Risk**: Highest (could make things worse).

---

## The Decision Tree

```mermaid
graph TD
    Start{Incident Detected} --> Recent{Recent Deploy?}
    Recent -- Yes --> Rollback[Rollback]
    Recent -- No --> Feature{Specific Feature?}
    
    Feature -- Yes --> Flag[Disable Feature Flag]
    Feature -- No --> Infra{Infrastructure Issue?}
    
    Infra -- Yes --> Reroute[Reroute Traffic]
    Infra -- No --> Load{High Load?}
    
    Load -- Yes --> Scale[Scale Up]
    Load -- No --> Patch[Emergency Patch]
    
    style Rollback fill:#0f0,stroke:#333,stroke-width:2px
    style Patch fill:#f66,stroke:#333,stroke-width:2px
```

---

## Mitigation Anti-Patterns

### Anti-Pattern 1: The "Let Me Debug First" Trap
**Problem**: Spending 30 minutes debugging before mitigating.
**Fix**: Mitigate first, debug later.

### Anti-Pattern 2: The "Perfect Fix" Fallacy
**Problem**: Trying to find the perfect solution instead of a quick fix.
**Fix**: Accept that mitigation is temporary. Root cause fix comes later.

### Anti-Pattern 3: The "Untested Hotfix"
**Problem**: Deploying an emergency patch without any testing.
**Fix**: Even in emergencies, test in staging first (if possible).

---

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Debugging During Fire" Outage
**Problem**: Payment processing for a large retail site failed immediately after a 2:00 PM deployment.
**Mistake**: The on-call engineer started "Tailing Logs" and "Checking Database Locks" to find the exact line of code that was failing.
**Crisis**: This "Investigation" took 2 hours. During those 2 hours, the company lost $250,000 in revenue.
**Outcome**: A senior SRE joined the bridge, asked "When was the last deploy?", and immediately ordered a rollback.
**Solution**: The **Rollback** took 2 minutes. The site was restored instantly.
**Result**: The team implemented a "Rollback-First, Debug-Later" policy for any incident starting within 30 minutes of a deployment.

### Scenario 2: The "Poisoned" Feature Flag
**Problem**: A new "AI-Recommended Products" widget was deployed. It worked in staging but caused a "Memory Leak" in production that crashed the web servers every 10 minutes.
**Constraint**: A full rollback was risky because the deployment also included critical security patches that couldn't be reverted.
**Solution**: The team used a **Feature Flag** manager to "Kill" the AI widget globally.
**Outcome**: The widget disappeared from the site, the memory leak stopped immediately, and the security patches stayed in place.
**Result**: MTTR was 45 seconds (the time it took to toggle a button in a UI).

### Scenario 3: The "Region Failure" Reroute
**Problem**: An AWS region (US-EAST-1) experienced a major networking outage, making the application unreachable for 50% of the world.
**Crisis**: Scaling up or patching wasn't an option because the underlying infrastructure was broken.
**Solution**: The team updated their **Route 53 DNS records** to reroute all traffic to their backup region (US-WEST-2).
**Outcome**: Although US-WEST-2 was slightly slower due to latency, 100% of users were able to access the site again within 5 minutes of the DNS propagation.
**Result**: The company prioritized "Multi-Region Active-Active" architecture for all critical services.

---

## ❓ Interview Questions

1.  **What is the 'Golden Rule' of Mitigation?**
    - *Answer*: **Mitigate First, Debug Later**. Your priority is "Stopping the Bleeding" and restoring service to users. You can investigate the "Why" (Root Cause) once the site is stable.
2.  **When is a 'Rollback' NOT the best option?**
    - *Answer*: 1. When the issue isn't related to a recent change. 2. When a database schema change (migration) has already been applied and cannot be easily reverted without data loss. 3. When the previous version also has the bug.
3.  **Explain the benefit of 'Feature Flags' for incident response.**
    - *Answer*: Feature flags allow for "Surgical Mitigation." They let you disable the *specific* broken part of an application without needing a full redeploy or rollback, minimizing the "Blast Radius" of the fix.
4.  **What is a 'Hotfix' and why is it considered high risk?**
    - *Answer*: A hotfix is a code patch written and deployed under pressure during an incident. It is high risk because there is often no time for full QA/Testing, which can lead to "Secondary Outages" (where the fix causes a new problem).
5.  **How does 'Traffic Rerouting' differ from 'Horizontal Scaling'?**
    - *Answer*: **Scaling** adds more capacity to an existing area. **Rerouting** moves traffic *away* from a broken area to a healthy one (e.g., changing DNS from one data center to another).
6.  **Why should you mitigate even if you don't know the root cause?**
    - *Answer*: Because SREs are measured on **MTTR (Mean Time To Recovery)**. Every minute of user downtime is a violation of the SLA. Finding the root cause is for the Post-Mortem phase; restoring service is for the Incident Response phase.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. What is the primary focus of the Mitigation phase?**
- A) Finding the root cause
- B) Stopping the service impact (Stopping the bleeding)
- C) Writing a post-mortem
- D) Blaming the developer

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: Speed is more important than perfection during mitigation.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. Which mitigation strategy is usually the FASTEST?**
- A) Emergency Patch
- B) Rollback
- C) Scaling
- D) Rewrite the app

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. A 'Feature Flag' allows you to:**
- A) Change the logo
- B) Toggle a specific functionality off without a full deployment
- C) Delete the database
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. 'Rolling back' a Kubernetes deployment is done with:**
- A) git delete
- B) kubectl rollout undo
- C) rm -rf /
- D) help

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'Traffic Rerouting' is best used when:**
- A) The code has a typo
- B) An entire data center or region is failing
- C) A user is angry
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: You should always debug for 1 hour before rolling back.**
- A) False - Rollback immediately if a recent deploy caused the issue.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. 'Horizontal Scaling' involves:**
- A) Making the server bigger (CPU/RAM)
- B) Adding more instances (replicas) of the service
- C) Buying a wider monitor
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. An 'Emergency Patch' is generally:**
- A) The safest option
- B) The riskiest option
- C) The cheapest option
- D) always green

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. What is 'Blast Radius' in mitigation?**
- A) The size of an explosion
- B) The portion of the system or users affected by a change or an outage
- C) The server room door
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: If a database migration can't be reverted, you might be forced to Hotfix.**
- A) True - This is a common scenario.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. 'Failover' refers to:**
- A) Failing a test
- B) Automatically switching traffic to a redundant standby system
- C) Deleting a service
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. Why use 'Canary Deployments' to prevent mitigation crises?**
- A) To test birds
- B) To release code to only 1% of users first to detect bugs early
- C) To make it look cool
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. If you have 100% error rates after a deploy, you should:**
- A) Read the code
- B) **Rollback immediately**
- C) Ask the user to wait
- D) restart the database

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. 'Surgical Mitigation' means:**
- A) Using a scalpel on a server
- B) Fixing only the specific broken component (like via a feature flag)
- C) Fixing everything at once
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: Root cause analysis happens *during* the mitigation phase.**
- A) False - It happens after the incident is mitigated.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'DNS Propagation' time affects which strategy?**
- A) Scaling
- B) Traffic Rerouting
- C) Rollback
- D) Coding

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. What is the 'MTTR' target during mitigation?**
- A) As long as it takes
- B) **Zero (or as close as possible)**
- C) 24 hours
- D) none

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. A 'Circuit Breaker' is an automated way to:**
- A) Turn off the lights
- B) Stop traffic to a failing service to prevent cascading failure
- C) Speed up the site
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: You should always communicate your mitigation plan to the Incident Commander.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Shadow Traffic' helps test fixes by:**
- A) Using dark mode
- B) Mirroring real production traffic to a test service without impacting users
- C) Hiding traffic
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Rate Limiting' can be a mitigation strategy against:**
- A) Slow code
- B) Sudden traffic surges or DDoS attacks
- C) High prices
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Under-mitigating means:**
- A) Fixing too fast
- B) Applying a partial fix that doesn't fully stop the user impact
- C) Forgetting to log
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Mitigation First' mindset is core to which philosophy?**
- A) Waterfall
- B) SRE (Site Reliability Engineering)
- C) Agile
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. Mitigation is to an incident what _____ is to a doctor.**
- A) Surgery
- B) First Aid (Stop the bleeding)
- C) Nutrition
- D) Billing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
