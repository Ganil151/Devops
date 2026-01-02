---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Severity Inflation" Crisis
**Problem**: An engineering team at a fintech startup marked every bug, including minor UI glitches and internal tool slowness, as "P1 - High Priority."
**Outcome**: The on-call engineer was paged 30 times over a weekend. By Sunday night, they were so exhausted that they silenced their phone. A real P0 outage occurred at 3 AM Monday, and it went unnoticed for 4 hours.
**Solution**: Implemented a strict **Severity Matrix**. "P1" was redefined only for issues affecting > 10% of transaction volume. Only the Incident Commander (IC) could upgrade a P2 to a P1.
**Result**: Weekly pages dropped from 150 to 5. The team's morale improved, and real outages were detected and fixed within 10 minutes.

### Scenario 2: The Silent Revenue Leak
**Problem**: A subscription service's "Cancel" button stopped working in the mobile app. It was categorized as "P2 - Medium" because it didn't crash the app and only affected a "minority" of the path.
**Discovery**: A data analyst noticed that revenue churn was 20% lower than usual, but customer support tickets were screaming with legal threats from people who couldn't cancel.
**Outcome**: The company faced potential regulatory fines for blocking user cancellations.
**Solution**: Updated the **Impact Assessment**. Anything affecting "Contractual or Legal Compliance" or "Direct User Exit/Entry" was automatically promoted to P1.
**Result**: The team realized that "Mechanical Health" (CPU/RAM) isn't the only metric for severity; "Legal and Customer Trust" is equally important.

### Scenario 3: The Internal Tool Outage
**Problem**: The custom-built deployment tool (used by 200 developers) crashed during a "P3 - Low" window. It was left until the next business day.
**Outcome**: A critical security patch needed for the main site couldn't be deployed for 12 hours. The company was stuck in a "Vulnerable" state.
**Solution**: Redefined **Internal Severity**. While the "Public" site was up, a total blocker for "Deployment or Security" was re-categorized as P1-Internal.
**Result**: The deployment tool now has its own SLA, ensuring engineers can always fix the site when needed.

---

## ❓ Interview Questions

1.  **Define the difference between 'P0' and 'P1' in your current or past organization.**
    - *Answer*: P0 is usually a "Site Down" or "Critical Data Loss" event affecting almost all users (e.g., Total Database crash). P1 is a "Major Feature Broken" but the site is still partially functional (e.g., Users can browse but cannot Checkout).
2.  **What is 'Alert Fatigue' and how do strict severity levels mitigate it?**
    - *Answer*: Alert Fatigue is when engineers become desensitized to pages because they are triggered too often for non-urgent tasks. Strict severity ensures only "Actionable and Impactful" events trigger a page, preserving the engineer's focus for real emergencies.
3.  **How do you handle 'Severity Disagreements' between Product and Engineering?**
    - *Answer*: We use a **Pre-defined Matrix** that focuses on data. Instead of "I think this is important," we ask "What % of users are affected?" or "Is revenue being lost?". If a disagreement persists, the Incident Commander makes the final call based on the matrix.
4.  **Explain 'Automatic Escalation' based on time.**
    - *Answer*: If a P1 incident isn't mitigated within a set timeframe (e.g., 2 hours), the system automatically notifies the next level of management (e.g., Director/VP). This ensures that if a team is "stuck," extra resources are brought in automatically.
5.  **Should a security bug be a P1 or a P3?**
    - *Answer*: It depends on the exploitability. A "Remote Code Execution" (RCE) in a public endpoint is a P1 (or P0). A minor CSRF on an internal dashboard might be a P3. Level of risk defines the severity.
6.  **Why is it important to have a 'P4/Backlog' category?**
    - *Answer*: It provides a place for non-urgent feature requests and cosmetic bugs. Without it, these items often clutter the incident queue, distracting the team from real operational work.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. Which severity level is reserved for a "Total Site Outage"?**
- A) P1
- B) P0
- C) P2
- D) P3

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: Standardizing severity levels helps prevent emotional arguments during a crisis.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. If 20% of users cannot log in, this is likely a:**
- A) P3
- B) P1 (High Impact)
- C) P4
- D) Success

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. 'Response Time SLA' for a P0 should ideally be:**
- A) 1 Hour
- B) Immediate (< 5-15 mins)
- C) Next Day
- D) 1 Week

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. What is 'Alert Fatigue'?**
- A) Being tired of the color blue
- B) Desensitization caused by too many low-priority pages
- C) A broken speaker
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. A 'P3' (Low) incident is typically resolved:**
- A) Immediately
- B) During the next business day/week
- C) Never
- D) in 5 minutes

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: 'Revenue Impact' is a valid metric to judge severity.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. 'SLA' stands for:**
- A) System Level Action
- B) Service Level Agreement
- C) Standard Logic Area
- D) Security Log Access

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. Who has the final authority to declare or change an incident's severity?**
- A) The Customer
- B) The Incident Commander (IC)
- C) The Marketing Intern
- D) HR

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. What occurs during 'Automatic Escalation'?**
- A) The site is deleted
- B) Additional management/engineers are notified after a time limit is exceeded
- C) The price increases
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: A typo on the homepage is a P1 incident.**
- A) False - It's usually a P3 or P4.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. 'Blast Radius' helps determine:**
- A) The color of the site
- B) The number of affected users/services (and thus the severity)
- C) Network speed
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'P2' incident might be:**
- A) Site Down
- B) Slow performance for a subset of users
- C) Feature request for a new button
- D) Coffee is cold

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What is the main danger of 'Severity Inflation'?**
- A) Too many meetings
- B) Real emergencies being ignored due to alert fatigue
- C) High cloud bills
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. 'Urgency' in the Matrix refers to:**
- A) How much we like the feature
- B) The speed with which the business requires a resolution
- C) The age of the code
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: Legal and Compliance violations should be high priority (P1).**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'Trivial' (P4) items are stored in:**
- A) The main alert channel
- B) The Product Backlog
- C) The trash
- D) a secret file

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Why use a 'Pre-defined' table for severity?**
- A) To look professional
- B) To remove subjectivity and bias during an emotional incident
- C) To save disk space
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. An 'Internal-Only' P1 means:**
- A) No one cares
- B) A critical tool used by the company is broken (e.g., cannot deploy code)
- C) The lights are off
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: Every P0 incident must have a Post-Mortem.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Response' SLA vs 'Resolution' SLA:**
- A) They are the same
- B) Response is how fast we start; Resolution is how fast we fix
- C) Resolution is the price
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. Which severity would you assign to a 'Broken Login' for 100% of users?**
- A) P0/P1
- B) P3
- C) P4
- D) P2

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**23. 'Shadowing' an IC during a P1 outage is for:**
- A) Spying
- B) Educational purposes (Learning how to handle severity calls)
- C) Deleting code
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Impact' axis on a matrix covers:**
- A) How hard the crash was
- B) The extent of the damage (Users, Revenue, Data)
- C) The length of the name
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. A disciplined SRE team treats severity as a ____ for their ____.**
- A) Map / Code
- B) Guardrail / Attention
- C) Law / Salary
- D) Game / Play

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
