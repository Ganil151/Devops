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

<b>1. Which remediation pattern is best for fixing a memory leak in a stateless app?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: You should delete all files in `/var/log` if the disk is full.</b>
<details>
<summary>Show Answer</summary>
Answer: B** - Only delete rotated, old, or archived logs.
</details>


<b>3. What does HPA stand for in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. Which signal is commonly used to tell a process to 'Reload Config' without a full restart?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. 'Pattern 3' (Proactive Scaling) is triggered by:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. 'Connection Pool Exhaustion' usually results in:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: Graceful restarts should 'Drain' connections before killing the process.</b>
<details>
<summary>Show Answer</summary>
Answer: A** - This prevents dropping user requests.
</details>


<b>8. Deleting cache files is an example of:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. 'Upper Limits' in auto-scaling are essential for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. When a DNS entry is updated during failover, an app might fail because of:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. Which tool can automate Pattern 2 (Disk Cleanup) on Linux?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>12. True/False: 'Stateless' applications are easier to auto-remediate than 'Stateful' ones.</b>
<details>
<summary>Show Answer</summary>
Answer: A** - Restarts don't risk data corruption in stateless apps.
</details>


<b>13. A 'Memory Leak' is best handled by vertical scaling (more RAM) as a:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. What occurs during a 'Rollout Restart' in Kubernetes?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>15. 'Pattern 4' (Reset Pool) is better than a restart because:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. True/False: You should test your Disk Cleanup script on a production DB first.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. 'Saturation' is a metric that measures:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Auto Scaling Groups (ASG) are specific to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. Which pattern fixes 'Thread Hangs' in a JVM application?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. True/False: 'Predictive Scaling' uses ML/Historic data to scale BEFORE the traffic arrives.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>21. 'Zombie Processes' are best handled by:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. 'Zipping' logs instead of deleting them is part of which pattern?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. Why is 'Connection Leaking' dangerous?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. The command `dscacheutil -flushcache` is used on:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>25. Core Remediation Patterns aim to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>
