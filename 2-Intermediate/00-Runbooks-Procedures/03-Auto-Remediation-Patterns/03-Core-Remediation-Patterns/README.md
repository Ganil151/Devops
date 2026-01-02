---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Disk Full" Cascade
**Problem**: A log aggregator fills the local disk on a Kubernetes node. The application can't write new logs and begins crashing with `DiskFull` errors.
**Outcome**: MTTR was 15 minutes manually (SRE has to SSH in, find the logs, delete them, and manually restart the pod). During this time, 2,000 requests were lost.
**Solution**: Implemented Pattern 2 (Log Cleanup). A Prometheus alert triggers a Kubernetes `Job` that cleans up the `/var/log` directory of the affected node.
**Result**: MTTR dropped from 15 minutes to 45 seconds. The app recovered before the on-call engineer even opened their laptop.

### Scenario 2: The Haunted Connection Pool
**Problem**: A legacy monolith has a slow memory leak in its database connection pool. Every Friday at 3:00 PM, the application begins throwing "Too Many Connections" errors.
**Outcome**: Frequent Friday outages and a frustrated SRE team.
**Solution**: Implemented Pattern 4 (Connection Pool Reset). Instead of a full app restart (which takes 5 mins), the system sends a `SIGHUP` signal to the process when connection errors hit a 5% threshold.
**Result**: The pool resets in under 2 seconds. The underlying leak is still scheduled for a developer fix, but the "Pain" of the incident is now automated away.

### Scenario 3: The Black Friday Over-Scale
**Problem**: During a massive sale, the Horizontal Pod Autoscaler (HPA) followed a CPU spike and scaled from 10 pods to 500 pods in 2 minutes.
**Crisis**: This massive scaling event exceeded the company's AWS budget alert within 10 minutes and crashed the internal network load balancer (NLB) which couldn't handle the registration rate.
**Solution**: Refined Pattern 3 (Proactive Scaling) by adding **Safety Limits** (Max Replicas) and using **Predictive Scaling** based on the previous year's traffic rather than just reactive CPU metrics.
**Result**: Stable performance without crashing the NLB or blowing the budget.

---

## ❓ Interview Questions

1.  **When is it safe to automatically restart a service (Pattern 1)?**
    - *Answer*: It is safe when: 1. The service is **Stateless** (meaning a restart doesn't lose user data). 2. You have a **Retry Limit** to prevent "Restart Loops." 3. The service is behind a Load Balancer that can drain traffic during the restart. 4. You have a verified "Healthy" state check after the restart.
2.  **What is the 'Golden Rule' of automated disk cleanup?**
    - *Answer*: Never delete data that hasn't been safely replicated or archived. The cleanup script should target rotated logs (`.gz`), temporary caches, and build artifacts, rather than active database files or critical configuration logs.
3.  **Explain the difference between Horizontal and Vertical Scaling in auto-remediation.**
    - *Answer*: **Horizontal Scaling** (HPA/ASG) adds more instances of a service. It's best for handling traffic spikes. **Vertical Scaling** (VPA) increases the CPU/RAM of an existing instance. It's better for long-term growth or handling memory-intensive jobs that can't be split across nodes.
4.  **Why use signals like `SIGHUP` instead of `SIGKILL` for remediation?**
    - *Answer*: `SIGHUP` (Signal Hang Up) often tells a process to reload its configuration or reset its internal state (like connection pools) without fully terminating. This results in much lower downtime and less impact on users compared to the destructive `SIGKILL`.
5.  **How do you prevent 'Runaway Costs' when using automated scaling?**
    - *Answer*: By implementing **Upper Limits** in your scaling policies. Never leave an Auto Scaling Group with `Max: Infinity`. We also set budget alerts that can trigger a "Safety Break" in the automation.
6.  **What is a 'DNS Cache Flush' and when would you use it as a remediation step?**
    - *Answer*: It clears the local resolver's record of IP-to-Domain mappings. It's used after a "Mainteance migration" or "Failover" event where a domain now points to a new IP, but the application is still trying to connect to the old, dead IP.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. Which remediation pattern is best for fixing a memory leak in a stateless app?**
- A) DNS Flush
- B) Service Restarter
- C) Disk Cleanup
- D) Vertical Scaling

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: You should delete all files in `/var/log` if the disk is full.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: B** - Only delete rotated, old, or archived logs.

</details>

**3. What does HPA stand for in Kubernetes?**
- A) High Power Automation
- B) Horizontal Pod Autoscaler
- C) Heavy Process Archiver
- D) Helpful Person Assistant

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. Which signal is commonly used to tell a process to 'Reload Config' without a full restart?**
- A) SIGTERM
- B) SIGHUP
- C) SIGKILL
- D) SIGINT

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. 'Pattern 3' (Proactive Scaling) is triggered by:**
- A) A service crash
- B) Metrics trending toward a threshold (e.g., CPU > 80%) or predictive schedules
- C) Someone deleting a file
- D) bad weather

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'Connection Pool Exhaustion' usually results in:**
- A) Disk Full errors
- B) "Too Many Connections" or timeout errors from the database
- C) Fast response times
- D) computer reboots

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: Graceful restarts should 'Drain' connections before killing the process.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - This prevents dropping user requests.

</details>

**8. Deleting cache files is an example of:**
- A) Pattern 1 (Restarter)
- B) Pattern 2 (Storage Cleanup)
- C) Pattern 5 (DNS Flush)
- D) A mistake

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. 'Upper Limits' in auto-scaling are essential for:**
- A) Speeding up the network
- B) Budget and resource protection
- C) Hiding logs
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. When a DNS entry is updated during failover, an app might fail because of:**
- A) Lack of memory
- B) Stale DNS Cache (Pattern 5)
- C) CPU spikes
- D) disk space

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. Which tool can automate Pattern 2 (Disk Cleanup) on Linux?**
- A) Excel
- B) Logrotate (or a custom Cron job)
- C) Notepad
- D) Slack

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**12. True/False: 'Stateless' applications are easier to auto-remediate than 'Stateful' ones.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - Restarts don't risk data corruption in stateless apps.

</details>

**13. A 'Memory Leak' is best handled by vertical scaling (more RAM) as a:**
- A) Permanent solution
- B) Temporary "Safety Net" until the code is fixed
- C) Waste of time
- D) secret

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What occurs during a 'Rollout Restart' in Kubernetes?**
- A) The whole cluster reboots
- B) All pods are deleted at once
- C) Pods are replaced one by one to ensure zero downtime
- D) The database is cleared

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**15. 'Pattern 4' (Reset Pool) is better than a restart because:**
- A) Restarts are too fast
- B) It is less disruptive and faster for high-traffic apps
- C) It uses more memory
- D) it looks cooler

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: You should test your Disk Cleanup script on a production DB first.**
- A) False - Test in Staging to ensure you don't delete critical data.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'Saturation' is a metric that measures:**
- A) Water content
- B) How close a resource (CPU/Disk) is to its maximum capacity
- C) The number of users
- D) response time

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Auto Scaling Groups (ASG) are specific to:**
- A) Azure
- B) AWS
- C) Google Cloud
- D) On-premise only

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. Which pattern fixes 'Thread Hangs' in a JVM application?**
- A) DNS Flush
- B) Service Restarter (Pattern 1)
- C) More Disk
- D) Shorter cables

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: 'Predictive Scaling' uses ML/Historic data to scale BEFORE the traffic arrives.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Zombie Processes' are best handled by:**
- A) More memory
- B) Pattern 1 (Targeted process restart or cleanup)
- C) DNS Flush
- D) magic

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Zipping' logs instead of deleting them is part of which pattern?**
- A) Pattern 1
- B) Pattern 2 (Intelligent Cleanup)
- C) Pattern 4
- D) none

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Why is 'Connection Leaking' dangerous?**
- A) It costs money
- B) It eventually saturates the DB connection limit, causing a total outage
- C) It's slow
- D) it's messy

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The command `dscacheutil -flushcache` is used on:**
- A) Linux
- B) macOS
- C) Windows
- D) Android

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. Core Remediation Patterns aim to:**
- A) Replace human SREs
- B) Standardize the response to common "Toil" triggers
- C) Make code harder to read
- D) cause outages

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
