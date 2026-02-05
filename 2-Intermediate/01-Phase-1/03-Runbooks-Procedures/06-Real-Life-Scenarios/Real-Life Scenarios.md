Explore how operational procedures and runbooks are applied in high-pressure real-world situations.

## 🚒 Scenario 1: The "Ghost" Outage
**Context**: A critical microservice is reporting 100% health, but customers are complaining that they cannot login.
**Challenge**: Find the issue when the metrics say everything is "Green."
**Solution**:
1. **Diagnosis**: Follow the **"Login Service Investigation" Runbook**. Step 1 directs the engineer to check the **Synthetic Probes** (Blackbox monitoring).
2. **Identification**: The probe shows that while the code is running fine, the **API Gateway** is rejecting traffic due to an expired SSL certificate.
3. **Resolution**: Follow the **"SSL Renewal SOP"** to manually update the certificate and restart the gateway.
4. **Prevention**: Update the certificate renewal process to be automated and add an alert for 30 days before expiry.

---

## 🛑 Scenario 2: Handling a "Flapping" Service
**Context**: A backend service is crashing and restarting every 30 seconds, flooding the team with alerts.
**Challenge**: Stop the noise and fix the root cause without causing a total blackout.
**Solution**:
1. **Triage**: Use the **"Alert Fatigue Protocol"** to temporarily silence the specific alert for 30 minutes.
2. **Investigation**: Check the logs (as per the **"Service Instability Runbook"**). Find a "Memory Leak" caused by a recent deployment.
3. **Action**: Perform an **Emergency Rollback** to the previous stable version using the automated CI/CD pipeline.
4. **Post-Mortem**: Identify why the memory leak wasn't caught in the staging environment.

---

## 💰 Scenario 3: The "Unlimited" AWS Bill
**Context**: An automated script designed to clean up temporary instances fails, and instead starts spinning up 50 large instances per hour.
**Challenge**: Immediate financial risk. Stop the automation safely.
**Solution**:
1. **Trigger**: Use the **"AWS Cost Anomaly" Runbook** triggered by a budget alert.
2. **Containment**: Immediately disable the IAM role used by the script (The **"Kill Switch"** procedure).
3. **Cleanup**: Run a manual **"Mass Termination" script** to delete the unauthorized instances.
4. **Fix**: Implement a **Circuit Breaker** in the automation script that prevents it from creating more than 5 resources per hour.

---

## 🔑 Scenario 4: The "Lost" Infrastructure Lead
**Context**: The only engineer who knows how the core networking works is on vacation, and a routing loop has taken down the staging environment.
**Challenge**: Resolve the issue without the "Expert" and without a documented procedure.
**Solution**:
1. **Response**: The Incident Commander declares a **"Bus Factor" Incident**.
2. **Documentation Search**: Locates the **"VPC Routing SOP"** created 6 months ago.
3. **Execution**: A junior engineer follows the numbered steps to reset the Route Tables.
4. **Outcome**: Staging is restored.
5. **Update**: The junior engineer updates the SOP with recent screenshots and notes to make it even easier for the next person.

---

## 🧪 Scenario 5: Chaos Engineering - "Testing the Runbook"
**Context**: To prepare for the annual "Black Friday" traffic spike, the SRE team decides to simulate a database failure.
**Challenge**: Ensure the team can follow the failover runbook under pressure.
**Solution**:
1. **Controlled Failure**: Explicitly take down the primary database in a staging environment.
2. **Execution**: The on-call rotation is forced to use the **"DB Failover Runbook"** to promote a replica.
3. **Observation**: The team finds that Step 4 in the runbook contains a typo in the CLI command.
4. **Correction**: The typo is fixed immediately. The team now has 100% confidence that the runbook will work during the real Black Friday event.
