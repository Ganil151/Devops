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

**1. Any unplanned interruption to a service is defined as:**
- A) A Feature
- B) An Incident
- C) A Meeting
- D) A Success

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: If a service is working but 50x slower than normal, it is an incident.**
- A) True - This is 'Service Degradation.'
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. The first phase of the Incident Lifecycle is:**
- A) Triage
- B) Detection
- C) Post-Mortem
- D) Resolution

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. What is the main priority during an active outage?**
- A) Writing code
- B) Mitigation (Restoring service)
- C) Finding who to blame
- D) Updating LinkedIn

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. Which of these is NOT an incident?**
- A) Production Database crash
- B) Planned maintenance with user notification
- C) Security breach
- D) API returning 500 errors

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'Stop the Bleeding' refers to:**
- A) Bandages
- B) Mitigating the customer impact immediately
- C) Deleting the database
- D) Closing the laptop

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: A 'Blameless' culture means people are never held accountable.**
- A) False - It means we hold the *system* and *processes* accountable to prevent human error.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. If you are on-call and stuck for 15 minutes, you should:**
- A) Keep trying for 5 more hours
- B) Escalate/Ask for help
- C) Go to sleep
- D) Restart your computer

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. The 'Scribe' role in an incident is responsible for:**
- A) Fixing the code
- B) Documenting all actions and decisions with timestamps
- C) Ordering pizza
- D) Managing the budget

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. What occurs during the 'Post-Mortem' phase?**
- A) The site is still down
- B) Analysis of the root cause and creation of preventative action items
- C) Firing the person who broke it
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: An incident is only "Resolved" when the underlying problem is permanently fixed.**
- A) False - It's resolved when the service is back to normal. The permanent fix is a 'Continuous Improvement' step.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. 'MTTR' stands for:**
- A) Maximum Time To Run
- B) Mean Time To Recovery
- C) Minimum Task To Resolve
- D) Monthly Total Revenue

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Workaround' is used to:**
- A) Permanently fix the code
- B) Mitigate the incident quickly (e.g., routing traffic away from a broken node)
- C) Confuse the user
- D) save money

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. Which of these is a 'Triage' activity?**
- A) Writing a 10-page report
- B) Determining the severity and priority of the incident
- C) Buying new servers
- D) deleting logs

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. True/False: Incident response should be a "Team Effort," never a "Solo Hero" mission.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**16. The goal of 'Blameless' is to maximize:**
- A) Fun
- B) Learning and System Resilience
- C) Speed
- D) Profits

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**17. What is the 'Blast Radius'?**
- A) The volume of the alert
- B) The extent of the impact (how many users/services are affected)
- C) The size of the code diff
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Which role is responsible for communicating with customers during an incident?**
- A) Engineer
- B) Communications Lead (External)
- C) Scribe
- D) Database Admin

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. True/False: You should log every 'Command' run during mitigation.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**20. 'Continuous Improvement' comes from:**
- A) Ignoring incidents
- B) Implementing the action items found in the Post-Mortem
- C) Buying better chairs
- D) hiring more people

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**21. An 'Escalation Policy' defines:**
- A) When a manager gets a bonus
- B) Who to contact and when if an incident isn't being resolved
- C) How to use the stairs
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Pride' in incident response usually leads to:**
- A) Faster fixes
- B) Longer outages (Delayed escalation)
- C) Better code
- D) more respect

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Which document outlines the 'Rules of Engagement' for incidents?**
- A) The CEO's Diary
- B) Incident Management SOP / Runbook
- C) The Git Log
- D) a Post-it note

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. True/False: A 'Socio-Technical' system includes both the code AND the people who run it.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**25. Success in Incident Management is measured by increasing ______ and decreasing ______.**
- A) Speed / Quality
- B) Resilience / Toil
- C) Availability / MTTR
- D) Costs / Revenue

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>
