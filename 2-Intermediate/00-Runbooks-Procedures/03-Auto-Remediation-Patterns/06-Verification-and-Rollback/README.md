---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Successful Failure"
**Problem**: An auto-remediation script noticed a Database process had died and successfully ran `systemctl restart postgresql`. The script returned `Exit 0` (Success).
**Hidden Issue**: The database started but was in "Read-Only" recovery mode because of a corrupted WAL log. The application could read data but every "Write" request failed.
**Outcome**: Users could see their profiles but couldn't place orders. The automation reported "All Good," so no human investigated for 4 hours.
**Solution**: Added a **Post-Verify Write Check**. The script now attempts to insert a dummy record into a `health_check` table.
**Result**: When the write failed, the script immediately escalated to a human, reducing downtime by 3.5 hours.

### Scenario 2: The Cascading Config Rollback
**Problem**: An SRE team used GitOps to manage Nginx configs. A bad PR was merged that had a syntax error in the SSL block. The auto-remediation (Pattern 1) tried to restart Nginx but it wouldn't come back up.
**Solution**: Implemented a **Local Rollback**. The script was modified to keep a backup of the previous "Known Good" config. If the restart fails, it swaps back to the backup and tries again.
**Outcome**: The site stayed up using the old config while the team fixed the Git repository.
**Result**: 100% Availability maintained during a bad configuration push.

### Scenario 3: The Scaling "Brake"
**Problem**: An auto-scaling rule added 50 instances to a cluster to handle a CPU spike. 
**Crisis**: The new instances were "Healthy" from a CPU perspective, but they couldn't connect to the DB because they weren't in the correct Security Group. Verification (CPU < 80%) passed, but the system was broken.
**Solution**: Implemented **Synthetic Transaction Verification**. The scaling logic now waits for new instances to pass a "Can I talk to the DB?" test before considering the remediation "Verified."
**Result**: The system realized the new nodes were faulty, "Undid" the scaling (Rollback), and alerted the network team.

---

## ❓ Interview Questions

1.  **Explain why 'Command Success' is not the same as 'Issue Resolved'.**
    - *Answer*: A command can execute perfectly (e.g., `docker start container`) while the underlying problem persists (e.g., the container is in a crash-loop). Verification must check the **State** of the system (is it serving traffic?), not just the result of the action.
2.  **What is a 'Synthetic Transaction' and why is it the gold standard for verification?**
    - *Answer*: It is an automated test that mimics a real user action (e.g., logging in). It is the gold standard because it verifies the entire stack (Network, App, DB) is working together, whereas metric checks (CPU < 80%) only verify one isolated component.
3.  **When should you choose a 'Human-in-the-loop' over an automated Rollback?**
    - *Answer*: When the rollback action itself is high-risk (e.g., reverting a database schema migration) or when the system state is so corrupted that another automated action might cause data loss.
4.  **How do you handle 'Flapping' during the verification phase?**
    - *Answer*: By using **Multi-Sample Verification**. Instead of checking once, we check 3 times over 90 seconds. If the health check "Flips" between healthy and unhealthy, we treat it as a failure and escalate.
5.  **Describe the 'Rollback Undo' pattern in Kubernetes.**
    - *Answer*: Using `kubectl rollout undo deployment/xyz`, Kubernetes keeps a history of "ReplicaSets." The command tells the cluster to stop the current (broken) version and immediately revert to the previous (working) set of pods.
6.  **Why is 'Time-to-Stabilize' (Sleep) necessary before verification?**
    - *Answer*: Many services take time to "Warm up" (initialize caches, establish DB connections). If you verify too early, you'll get a "False Negative" (the service is actually fixing itself but isn't ready yet).

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. Verification should occur:**
- A) Before the action
- B) During the action
- C) After the action, allowing time for stabilization
- D) Never

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**2. True/False: If a script returns an exit code of 0, the remediation is guaranteed to be successful.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: B** - The command ran, but the problem may still exist.

</details>

**3. Which verification method is best for ensuring a DB is actually working?**
- A) Checking the process name
- B) Performing a "Canary" write/read query
- C) Checking the server temperature
- D) looking at the icon color

<details>
<summary>Show Answer</summary>

**Answer: B**（Synthetic Transaction）

</details>

**4. A 'Rollback' is used to:**
- A) Delete all data
- B) Revert the system to a previous "Known Good" state
- C) Speed up the CPU
- D) notify the user

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. What is the Kubernetes command for a rollback?**
- A) kubectl delete
- B) kubectl rollout undo
- C) kubectl restart
- D) kubectl edit

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'Stabilization Time' (Sleep) is needed because:**
- A) SREs need a break
- B) Services take time to initialize and metrics take time to reflect changes
- C) It saves electricity
- D) it's a rule

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: Verification should have a 'Timeout' (e.g., 5 mins) to prevent it from waiting forever.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. Which is an example of a 'Config Rollback'?**
- A) Deleting the server
- B) Reverting a Git commit and re-applying the config
- C) Changing the font
- D) restarting the app

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. 'Synthetic Transactions' mimic:**
- A) The developer
- B) The actual end-user behavior (e.g., Login/Purchase)
- C) The CPU
- D) the network

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. If verification fails, the system should immediately:**
- A) Try the same fix again 100 times
- B) Escalate to a human and/or trigger a rollback
- C) Shutdown everything
- D) do nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: 'Multi-Sample' verification means checking the health multiple times before deciding.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A** - Prevents "Flapping" false positives.

</details>

**12. 'Hysteresis' in verification prevents:**
- A) High costs
- B) 'Ping-pong' states where the system toggles between remediation and normal
- C) Slow network
- D) memory leaks

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Read-Only' database state after a restart is a failure of:**
- A) The Act stage
- B) The Verification stage (if not checked)
- C) The Log stage
- D) none

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. 'Desired State' in GitOps is usually stored in:**
- A) Slack
- B) A Version Control System (like Git)
- C) RAM
- D) the browser

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. What occurs during a 'Canary Verification'?**
- A) A bird is used
- B) The fix is verified on a tiny subset of traffic before being fully accepted
- C) The whole site reboots
- D) code is deleted

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: You should rollback a change if it causes a 10% increase in error rates, even if it "Fixed" the primary issue.**
- A) True - The fix introduced a regression.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'End-to-End' (e2e) verification is:**
- A) Fast
- B) Comprehensive (checks the whole path from user to DB)
- C) For developers only
- D) cheap

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Why log the results of a FAILED verification?**
- A) To blame people
- B) To give the on-call engineer context on what the automation attempted
- C) It's required by law
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. 'kubectl rollout undo' targets which resource?**
- A) Pods
- B) Deployment / ReplicaSet
- C) ConfigMaps
- D) Nodes

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: Rollbacks should be as automated as the remediation itself.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. A 'State Transition' in a rollback means:**
- A) Moving from one version to another
- B) Moving to a different country
- C) Changing the name
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**22. 'Post-Conditions' are checked in:**
- A) The Decide stage
- B) The Verification stage
- C) The Act stage
- D) The Plan stage

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Why use 'Deduplication' in Notify?**
- A) To see more logs
- B) To ensure the on-call isn't spammed with 100 "Rollback Successful" messages for one event
- C) To save space
- D) it's a bug

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. 'Service Degradation' as a result of a fix is a trigger for:**
- A) Success
- B) Rollback
- C) Celebration
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. Verification is the bridge between _____ and _____.**
- A) Code and Data
- B) Automation and Reliability
- C) SRE and Developer
- D) Start and Stop

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
