# Detection and Alerting

The faster you detect an incident, the faster you can respond. **Mean Time To Detect (MTTD)** is as important as MTTR.

## Detection Sources

### 1. Automated Monitoring
**Best**: Proactive, catches issues before users notice.
- **Metrics**: CPU, memory, disk, error rates, latency.
- **Logs**: Error patterns, exceptions, security events.
- **Synthetic Monitoring**: Automated tests simulating user behavior.
- **Tools**: Prometheus, Datadog, New Relic, CloudWatch.

### 2. User Reports
**Reality**: Sometimes users notice before monitoring does.
- **Channels**: Support tickets, social media, direct emails.
- **Problem**: High MTTD (users may wait before reporting).

### 3. Internal Discovery
**Worst**: Engineer stumbles upon issue while working.
- **Problem**: Indicates monitoring gaps.

---

## Alert Quality Metrics

### 1. Signal-to-Noise Ratio
What percentage of alerts are actionable?
- **Target**: > 95% of alerts should require action.
- **Problem**: Too many false positives cause alert fatigue.

### 2. Alert Actionability
Does the alert tell you what to do?
- **Bad**: "High CPU on server-123"
- **Good**: "High CPU on server-123. Runbook: https://wiki/cpu-spike"

### 3. Alert Grouping
Are related alerts aggregated?
- **Bad**: 100 alerts for "Pod Crash" (one per pod).
- **Good**: 1 alert "Multiple pods crashing in api-deployment"

---

## The Perfect Alert

```yaml
Alert: DatabaseConnectionPoolExhausted
Severity: P1
Description: |
  The connection pool for the primary database has reached 95% capacity.
  This will cause new requests to fail within 2-3 minutes.
Impact: Payment processing will fail
Runbook: https://wiki.company.com/runbooks/db-connections
Dashboard: https://grafana.company.com/d/database
Escalation: If not resolved in 15 min, page DBA team
```

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Crying Wolf" Alert
**Problem**: A server monitoring tool fired an alert 50 times a day for "Disk Usage > 80%." Most of the time, it was just temporary log files that a cron job eventually cleaned up.
**Crisis**: One Tuesday, the database disk actually filled to 100% due to a massive surge in data. The alert fired, but the on-call engineer, subconsciously ignoring the "normal" noise, assumed it was a false positive and didn't check the server for 2 hours.
**Outcome**: The database crashed, causing a 2-hour total site outage during peak traffic.
**Solution**: Adjusted the threshold to 90% and implemented **Auto-Remediation**. The system now automatically clears temp files at 85%. The alert only fires if auto-remediation fails and the disk hits 92%.
**Result**: Alert frequency dropped from 50/day to 1/month. The engineers regained trust in the system.

### Scenario 2: The "Silent" Multi-Region Outage
**Problem**: An e-commerce company used "Regional Status" monitoring. The "Global" dashboard showed "Green" because 90% of traffic was healthy.
**Crisis**: A DNS change accidentally blocked all traffic from the "EU-West" region. Since EU-West only accounted for 8% of global traffic, the "Global Error Rate" alert didn't cross its 10% threshold.
**Outcome**: EU customers were unable to buy anything for 6 hours.
**Solution**: Implemented **Regional Granularity** and **Synthetic Monitoring**. They now run "Bot" tests from 10 different global cities. If any single city fails 3 times in a row, a P1 alert is triggered.
**Result**: Detection time for regional issues dropped from "Hours" to "Minutes."

### Scenario 3: The "Log Storm" Discovery
**Problem**: A microservice started behaving slowly, but CPU and RAM metrics looked normal.
**Discovery**: An engineer happened to be tailing logs for a different task and noticed a massive "Storm" of `NullPointerException` errors that were being suppressed by a catch-all block.
**Outcome**: The "Internal Discovery" method meant the service had been degraded for 3 days without anyone knowing.
**Solution**: Implemented **Log Pattern Alerting**. They now use a tool (like ELK or CloudWatch Logs Insights) that alerts if the frequency of the word "Error" or "Exception" increases by more than 2x the normal baseline.
**Result**: Code bugs are now caught as soon as they are deployed, before users even report them.

---

## ❓ Interview Questions

1.  **What is 'MTTD' and why is it a critical KPI for an SRE team?**
    - *Answer*: **Mean Time To Detect**. It is the average time from when a failure actually occurs to when the team becomes aware of it. It is critical because you cannot start the "Fix" until you know there is a "Break." Lowering MTTD directly lowers the total downtime.
2.  **Explain the difference between 'Metric-Based' and 'Synthetic' monitoring.**
    - *Answer*: **Metric-Based** monitors internal health like CPU/RAM/Error Counts. **Synthetic Monitoring** acts like a robot user; it actually tries to "Login" or "Add to Cart" and alerts if the *behavior* fails, even if the server metrics look healthy.
3.  **How do you prevent 'Alert Fatigue' in a large organization?**
    - *Answer*: 1. Ensure alerts are **Actionable**. 2. Use **Threshold Tuning** (don't alert on 80% if it's not a real problem until 95%). 3. Use **Alert Grouping** to prevent 100 pages for 1 root cause. 4. Implement **Auto-Remediation** for routine tasks.
4.  **What information should a 'Perfect Alert' contain for an on-call engineer?**
    - *Answer*: 1. **Context** (What is broken?). 2. **Severity** (P0-P3). 3. **Impact** (How many users?). 4. **Runbook Link** (How do I fix it?). 5. **Dashboard Link** (Where can I see the data?).
5.  **Why are 'User Reports' considered a poor detection method?**
    - *Answer*: Because they are reactive and slow. By the time a user reports an issue, the system has already been broken for several minutes. SREs aim for **Proactive Monitoring** that catches the issue before the user ever sees an error message.
6.  **What is 'Signal-to-Noise' ratio in the context of alerting?**
    - *Answer*: It is the ratio of **Real/Actionable Alerts** (Signal) to **False/Non-Actionable Alerts** (Noise). A low ratio leads to alert fatigue, while a high ratio (Target > 95%) ensures the team stays alert and trust the monitoring system.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. What does MTTD stand for?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: Synthetic monitoring simulates real user behavior.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>3. Which detection source is the MOST proactive?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. 'Alert Fatigue' is dangerous because:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. A 'Signal-to-Noise' ratio of 50% means:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. Which tool is commonly used for 'Log Correlation' and alerting?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: You should alert every time CPU hits 10% usage.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. A 'Runbook Link' in an alert helps:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. 'Alert Grouping' prevents:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. What is 'MTTR's relationship to MTTD?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. True/False: User tickets are the best way to find a database deadlock.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>12. 'Latency' monitoring measures:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. A 'False Positive' is an alert that:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. What occurs during 'External Discovery'?</b>
<details>
<summary>Show Answer</summary>
Answer: A** - This indicates a monitoring gap.
</details>


<b>15. 'Dashboard Links' in alerts provide:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. True/False: Alerts should be sent to the company's 'Main' Slack channel.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. 'Heartbeat Monitoring' checks if:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Why use 'Multi-Region' monitoring?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. An 'Actionable' alert is one where:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. True/False: Paging a sleeping engineer for a 'Low' disk alert (80%) is encouraged.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>21. 'Sliding Windows' in alerting help:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. 'User Sentiment' monitoring looks at:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. 'Log Ingestion' is the process of:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. The 'Golden Signals' of monitoring are:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>25. Detection is the _____ of the Incident Management lifecycle.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>
