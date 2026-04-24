---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Hero" Paradox
**Problem**: A senior engineer, Dave, was famous for "saving the day" during every major outage. He would work alone for 12 hours straight and fix the system.
**Root Cause**: Dave was the only one who understood the legacy networking code. Because he worked alone, no one else learned the system.
**Solution**: Implemented a mandatory **Incident Command System (ICS)**. Dave was banned from fixing things; instead, he was assigned as the "Subject Matter Expert" (SME) to coach two junior engineers through the fix.
**Outcome**: The first incident took 4 hours, but the second one took only 45 minutes because knowledge had been shared.
**Result**: MTTR dropped, and Dave finally got to take a vacation without his phone ringing.

### Scenario 2: The Blame-Game Outage
**Problem**: A junior developer accidentally deleted the production database's "Write Access" permission while testing a new script.
**Root Cause**: The developer was publicly shamed in a Slack channel, and the team spent 2 hours arguing over who approved the script instead of fixing it.
**Outcome**: The site was down for 5 hours.
**Solution**: Adopted a **Blameless Post-Mortem** culture. The meeting focused on why the system allowed a single script to delete permissions without a safety check.
**Result**: They implemented "Policy as Code" (Sentinel) and the developer became one of the biggest advocates for security testing.

### Scenario 3: The "Hidden" Incident
**Problem**: A global shipping company noticed that 5% of orders were failing, but only in the Germany region. It didn't trigger any global alerts.
**Discovery**: An SRE noticed a spike in "Help Desk" tickets from German customers.
**Outcome**: Because it wasn't a "Full Outage," the team initially didn't treat it as an incident.
**Solution**: Redefined **"What Qualifies as an Incident"** to include regional degradations and "Customer Sentiment" thresholds.
**Result**: Regional monitoring was added, and the next localization bug was caught in 10 minutes instead of 3 days.

---

## ❓ Interview Questions

1.  **What is the difference between an 'Incident' and a 'Problem' in the ITIL/SRE framework?**
    - *Answer*: An **Incident** is a single unplanned event causing service disruption (e.g., "The web server crashed"). A **Problem** is the underlying root cause that could potentially lead to many incidents (e.g., "A memory leak in the app code").
2.  **Why is 'Mitigation' always prioritized over 'Root Cause' during an active incident?**
    - *Answer*: Because the priority is to **"Stop the Bleeding"** for the customers. Every minute of downtime costs money and trust. Finding the root cause is a "Stable State" activity that happens during the Post-Mortem phase.
3.  **Explain the 'Blameless Culture' and why it's vital for a high-performing SRE team.**
    - *Answer*: Blamelessness assumes that everyone acts in good faith. If an error occurs, we fix the **system** that allowed the error to happen, rather than punishing the person. This encourages engineers to be honest about mistakes, which leads to faster recovery and better learning.
4.  **What criteria do you use to determine if a bug is an 'Incident'?**
    - *Answer*: If the bug causes a service outage, security breach, data loss, or a violation of our Service Level Agreements (SLAs), it is an incident. Minor UI bugs that don't stop the user's "Primary Path" are usually just backlog items.
5.  **What is 'MTTR' and how does it relate to the Incident Lifecycle?**
    - *Answer*: **Mean Time to Recovery**. It measures the average time from detection to resolution. A mature lifecycle (fast detection, efficient triage, quick mitigation) directly lowers MTTR.
6.  **When should you 'Escalate' an incident?**
    - *Answer*: You should escalate if: 1. You lack the permissions/access to fix it. 2. You have been stuck for > 15-20 minutes without progress. 3. The blast radius is expanding beyond your team's control.

---

## 🧠 Comprehensive Quiz (25 Questions)

<b>1. Any unplanned interruption to a service is defined as:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. True/False: If a service is working but 50x slower than normal, it is an incident.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>3. The first phase of the Incident Lifecycle is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>4. What is the main priority during an active outage?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which of these is NOT an incident?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>6. 'Stop the Bleeding' refers to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. True/False: A 'Blameless' culture means people are never held accountable.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>8. If you are on-call and stuck for 15 minutes, you should:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>9. The 'Scribe' role in an incident is responsible for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. What occurs during the 'Post-Mortem' phase?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>11. True/False: An incident is only "Resolved" when the underlying problem is permanently fixed.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>12. 'MTTR' stands for:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>13. A 'Workaround' is used to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. Which of these is a 'Triage' activity?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>15. True/False: Incident response should be a "Team Effort," never a "Solo Hero" mission.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>16. The goal of 'Blameless' is to maximize:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>17. What is the 'Blast Radius'?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. Which role is responsible for communicating with customers during an incident?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. True/False: You should log every 'Command' run during mitigation.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>20. 'Continuous Improvement' comes from:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>21. An 'Escalation Policy' defines:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>22. 'Pride' in incident response usually leads to:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>23. Which document outlines the 'Rules of Engagement' for incidents?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>24. True/False: A 'Socio-Technical' system includes both the code AND the people who run it.</b>
<details>
<summary>Show Answer</summary>
Answer: A
</details>


<b>25. Success in Incident Management is measured by increasing ______ and decreasing ______.</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>
