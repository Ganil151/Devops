# On-Call Best Practices

Being on-call is stressful. These practices make it sustainable and effective.

## The On-Call Rotation

### Rotation Frequency
- **Weekly**: Most common, balances burden.
- **Daily**: Too frequent, causes fatigue.
- **Monthly**: Too long, knowledge gaps form.

### Rotation Structure
- **Primary**: First responder.
- **Secondary**: Backup if primary doesn't respond in 5 minutes.
- **Escalation**: Manager or senior engineer for complex issues.

---

## On-Call Readiness

### Before Your Shift
- [ ] Test pager/phone notifications.
- [ ] Review recent incidents and runbooks.
- [ ] Ensure laptop is charged and accessible.
- [ ] Know who your backup is.
- [ ] Review the escalation path.

### During Your Shift
- [ ] Stay within 15 minutes of a computer.
- [ ] Limit alcohol consumption.
- [ ] Keep phone charged and volume on.
- [ ] Acknowledge alerts within 5 minutes.

### Handoff Protocol
Document any ongoing issues or concerns for the next on-call.

---

## The 15-Minute Rule

**If you're stuck for 15 minutes, escalate.**

Pride has no place in incident response. Escalating early:
- Reduces MTTR.
- Prevents burnout.
- Builds team capability.

---

## On-Call Compensation

### Time-Based
- **Stipend**: Fixed payment per on-call shift (e.g., $200/week).
- **Hourly**: Payment for actual hours worked during incidents.

### Time-Off
- **Comp Time**: 1 day off for every week on-call.
- **Flex Time**: Come in late after a late-night page.

### Industry Standards
- **Minimum**: Stipend + comp time.
- **Best**: Stipend + hourly + comp time.

---

## Preventing Burnout

### 1. Limit Frequency
No one should be on-call more than 1 week per month.

### 2. Reduce Toil
Automate routine issues (auto-remediation).

### 3. Improve Alerts
Reduce false positives and noise.

### 4. Provide Support
Never leave on-call alone. Always have a backup.

### 5. Recognize Effort
Thank on-call engineers publicly. Celebrate successful incident responses.

---

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Lone Hero" Burnout
**Problem**: An SRE team of 4 had a primary-only rotation. One engineer, eager to prove themselves, never escalated and handled 5 P1 incidents in a single week, including many at 3:00 AM.
**Outcome**: By Friday, the engineer was physically exhausted and made a major configuration error during a routine change, causing a DNS blackout. Two weeks later, they resigned due to burnout.
**Solution**: Implemented a **Primary + Secondary** rotation. If the Primary is overwhelmed or has been awake for more than 2 hours at night, the Secondary MUST take over.
**Result**: Team retention improved, and the "Hero Culture" was replaced by a sustainable "Support Culture."

### Scenario 2: The "Ghost" Pager
**Problem**: During a P0 database failure, the on-call engineer didn't respond for 45 minutes because their phone's "Do Not Disturb" mode accidentally blocked the paging app.
**Crisis**: MTTR was delayed by nearly an hour simply because of a notification setting.
**Outcome**: The company lost thousands of users who couldn't log in.
**Solution**: Implemented a **Pager Readiness Checklist**. Every on-call engineer must perform a "Test Page" at the start of their shift. They also configured "Emergency Bypass" for the paging app on their mobile devices.
**Result**: Response time reliability reached 100% for the next year.

### Scenario 3: The "Toil" Trap
**Problem**: An on-call engineer was paged every night at 2:00 AM for "Disk Space > 80%" on a log-heavy server. Each time, they manually ran `rm -rf /tmp/logs/*.log`.
**Outcome**: The engineer was sleep-deprived and miserable.
**Solution**: The team implemented **Auto-Remediation**. A simple script now detects the 80% threshold and clears the logs automatically. The alert now only fires if the disk hits 95% (indicating auto-remediation failed).
**Result**: On-call pages dropped from 7/week to 1/month. Sleep quality for the whole team improved.

---

## ❓ Interview Questions

1.  **What is the '15-Minute Rule' and why is it important for SRE?**
    - *Answer*: If an on-call engineer is stuck on an incident for 15 minutes without progress, they MUST escalate to a backup or senior engineer. It prevents MTTR from ballooning due to "Pride" or "Tunnel Vision" and ensures the service is restored as fast as possible.
2.  **How do you handle a 'Secondary' on-call role?**
    - *Answer*: The Secondary is the safety net. They must be as ready as the Primary. Their job is to step in if the Primary doesn't acknowledge an alert within 5 minutes, or if the Primary needs more hands to manage a complex P0 incident.
3.  **Explain the concept of 'Comp Time' (Compensatory Time).**
    - *Answer*: If an engineer stays up all night fixing a production outage, they should be given the next morning (or day) off to rest. Expecting someone to work a full office day after a 3:00 AM outage leads to burnout and dangerous human errors.
4.  **What is a 'Handoff' and what information should it include?**
    - *Answer*: A handoff is when the current on-call engineer briefs the incoming one. It should include: 1. Ongoing incidents. 2. "Hot" areas of the system to watch. 3. Recent deployments. 4. Any flaky alerts that might fire.
5.  **How do you measure the 'Health' of an on-call rotation?**
    - *Answer*: By tracking metrics like: 1. Number of pages per shift. 2. Percentage of "Actionable" vs. "Non-Actionable" alerts. 3. Resolution time. 4. Qualitative feedback from engineers during post-shift debriefs.
6.  **Why is a 'Blameless' culture essential for on-call?**
    - *Answer*: Because on-call is high-pressure. If engineers fear they will be fired for a mistake made at 4:00 AM, they will be too hesitant to act. A blameless culture encourages fast action and honest reporting of what went wrong.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. What is the main goal of a 'Primary' on-call engineer?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: You should handle a P0 incident alone to show you are a 'Senior' engineer.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>3. The '15-Minute Rule' states you should escalate if:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. A 'Secondary' on-call role is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. 'Comp Time' refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. What is the first thing you should do at the start of an on-call shift?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: High alert volume (noise) is a primary cause of burnout.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. 'Emergency Bypass' on a phone allows:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. A 'Handoff' document should include:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. What is 'Toil' in the context of on-call?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. True/False: On-call rotations should include at least 6-8 people to be sustainable.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>12. 'MTTR' stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. A 'Warm Handoff' is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. Why is 'Sustainability' important for on-call?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. If your pager doesn't fire during a test, you should:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. True/False: Auto-remediation can reduce the number of midnight pages.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>17. 'Alert Fatigue' happens when:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. What is 'Follow-the-Sun' rotation?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. A 'Shadow Shift' is when:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. True/False: You should have access to production credentials *before* your shift starts.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>21. 'Escalation Policies' define:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. 'Post-Shift Debrief' is for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. Under-reporting on-call effort leads to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. Which tool is commonly used to manage on-call rotations?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>25. Sustainability is the _____ of SRE operations.</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>
