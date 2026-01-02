# Post-Mortem Analysis

The post-mortem is where **learning happens**. Skip it, and you're doomed to repeat the same incidents.

## The Blameless Philosophy

### Core Principle
**We fix systems, not people.**

If an engineer made a mistake, the system allowed it. The goal is to prevent the system from allowing that mistake again.

### Blameless Language
- **Bad**: "John deleted the production database."
- **Good**: "The deletion script lacked a confirmation prompt and production/staging databases had similar names."

---

## The Post-Mortem Structure

### 1. Executive Summary (2-3 sentences)
What happened and what was the impact?
```
On January 15, 2024, payment processing was unavailable for 2 hours 
affecting 10,000 customers and resulting in $200k lost revenue. 
The root cause was database connection pool exhaustion due to a 
connection leak in the new checkout feature.
```

### 2. Timeline (Detailed)
Every significant event with timestamps.
```
14:03 UTC - First alert: High error rate in payment service
14:05 UTC - On-call engineer acknowledged
14:08 UTC - IC declared P1, assembled team
14:15 UTC - Identified connection pool at 100%
14:20 UTC - Disabled new checkout feature via feature flag
14:25 UTC - Connection pool recovered to 30%
14:30 UTC - Verified payments working
14:42 UTC - Declared incident resolved
```

### 3. Root Cause Analysis (The "Five Whys")
Drill down to the systemic cause.

**Why did payments fail?**
→ Database connection pool was exhausted.

**Why was the pool exhausted?**
→ The new checkout feature had a connection leak.

**Why did it have a leak?**
→ The code didn't close connections in error cases.

**Why didn't we catch this in testing?**
→ Our load tests don't simulate error scenarios.

**Why don't we test error scenarios?**
→ We don't have a standard load testing framework that includes error injection.

**Root Cause**: Lack of comprehensive load testing framework.

### 4. What Went Well
Celebrate successes, even during failures.
- Feature flags allowed quick mitigation.
- ICS roles were clearly defined.
- Status page was updated within 5 minutes.

### 5. What Went Wrong
Be honest about failures.
- Detection took 3 minutes (should be < 1 min).
- Initial diagnosis was incorrect (wasted 10 minutes).
- No automated rollback triggered.

### 6. Action Items
Concrete, assigned, time-bound tasks.
```
[ ] Add connection pool monitoring (Owner: Alice, Due: Jan 20)
[ ] Implement error scenario load tests (Owner: Bob, Due: Jan 25)
[ ] Add auto-rollback for error rate > 10% (Owner: Charlie, Due: Feb 1)
[ ] Update runbook with connection leak debugging (Owner: Diana, Due: Jan 18)
```

---

## Post-Mortem Best Practices

### 1. Conduct Within 48 Hours
While memories are fresh.

### 2. Include Everyone
Not just engineers - Product, Support, Leadership.

### 3. Focus on Systems
Not individuals.

### 4. Make It Public (Internal)
Share with the entire company for transparency.

### 5. Track Action Items
Assign owners and due dates. Follow up in sprint planning.

---

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Blame Game" Disaster
**Problem**: After a 4-hour database outage, the post-mortem report stated: "The database crashed because Senior Engineer Mark ran an unoptimized DELETE command on the production table without a WHERE clause."
**Crisis**: Mark felt publicly shamed and stopped volunteering for on-call shifts. Other engineers became terrified of making changes and began hiding their mistakes to avoid similar public shaming.
**Outcome**: Innovation slowed down, and MTTR increased because engineers were too afraid to take quick mitigation actions.
**Solution**: The SRE Director threw away the old report and held a new **Blameless Post-Mortem**. They realized the system didn't require a "Peer Review" for DELETE commands and the terminal didn't have a color-coded prompt (Red for Production).
**Result**: They implemented "Protected Tables" and colored prompts. Mark stayed with the company, and the culture moved to fixing systems, not shaming people.

### Scenario 2: The "Forgot-to-Learn" Loop
**Problem**: A company had the "Same" DNS outage 3 times in 6 months. Each time, they "Fixed" it in 10 minutes and moved on.
**Discovery**: During the 3rd post-mortem, an SRE realized that the "Action Items" from the first two post-mortems had never been completed; they were just lost in the Jira backlog.
**Outcome**: The company wasted 30 hours of engineering time on a recurring problem that should have been solved once.
**Solution**: Implemented a **Post-Mortem Policy**. An incident isn't considered "Closed" until all P0 action items are verified as complete in production.
**Result**: The DNS issue was fixed permanently with a 2-line Terraform change, and it never happened again.

### Scenario 3: The "Five Whys" Success
**Problem**: A service crashed due to an "Out of Memory" (OOM) error.
**The Investigation**:
1. **Why?** The service used too much RAM.
2. **Why?** It was caching 1,000,000 user profiles.
3. **Why?** The cache-clearing cron job failed.
4. **Why?** The cron job used a hardcoded password that expired.
5. **Why?** We don't use a centralized Secret Manager for cron jobs.
**Root Cause**: Lack of automated secret rotation for internal automation scripts.
**Result**: Instead of just "Increasing RAM," the team implemented AWS Secrets Manager for all internal scripts, preventing a hundred other potential failures.

---

## ❓ Interview Questions

1.  **What does 'Blameless' really mean in the context of an SRE Post-Mortem?**
    - *Answer*: It means we assume that everyone involved acted with the best intentions given the information they had. Instead of asking "Who did this?", we ask "How did the system allowed this to happen?" and "How can we make the system robust enough to prevent it in the future?"
2.  **How do you ensure that Post-Mortem 'Action Items' actually get done?**
    - *Answer*: 1. Assign a specific **Owner** to every item. 2. Set a **Due Date**. 3. Review the progress in the very next Sprint Planning or SRE Sync. 4. Treat post-mortem action items as "High Priority" engineering work, not just "optional" tasks.
3.  **Explain the 'Five Whys' technique and give a brief example.**
    - *Answer*: It's a method of root cause analysis where you ask "Why?" repeatedly until you move past the technical symptom (e.g., "The disk is full") to the systemic human/process cause (e.g., "The logging policy was never documented or enforced").
4.  **When should a Post-Mortem be conducted?**
    - *Answer*: Ideally within 24-48 hours of the incident resolution, while the details and context are still fresh in the minds of the responders.
5.  **Who should attend a Post-Mortem meeting?**
    - *Answer*: Not just the engineers who fixed it. You should include: Responders, Product Managers (to understand user impact), Customer Support (to share user feedback), and any leadership interested in systemic improvements.
6.  **What is the difference between a 'Root Cause' and a 'Contributing Factor'?**
    - *Answer*: A **Root Cause** is the fundamental issue that, if solved, would prevent the entire class of incident (e.g., "Lack of automated testing"). A **Contributing Factor** made the situation worse but didn't cause it (e.g., "The documentation was slightly out of date").

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. The primary goal of a post-mortem is:**
- A) To find someone to fire
- B) To learn from the failure and prevent it from happening again
- C) To celebrate a successful fix
- D) To update the marketing budget

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**2. True/False: In a blameless culture, any mistake is the system's fault.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. Which technique is used to find the 'Root Cause'?**
- A) The Three Stooges
- B) The Five Whys
- C) The Seven Dwarfs
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. A post-mortem should ideally be written within:**
- A) 1 month
- B) 24 to 48 hours
- C) 5 minutes
- D) never

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. 'Action Items' in a post-mortem MUST have:**
- A) A cool name
- B) An Owner and a Due Date
- C) A lot of words
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. Blameless language focuses on:**
- A) "Who"
- B) "What" and "How" (The facts and the system)
- C) Feelings
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: Only engineers should read the post-mortem.**
- A) False - Share internally with the whole company (Leadership, Product, Sales) for transparency.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. The 'Timeline' in a post-mortem should include:**
- A) What people ate for lunch
- B) Every significant event with a timestamp
- C) Only the fix
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. What is an 'Executive Summary' in a post-mortem?**
- A) A list of managers
- B) A 2-3 sentence overview of what happened, the impact, and the root cause
- C) A bill
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. 'Root Cause' is usually found at which 'Why' in the Five Whys?**
- A) The first why
- B) Usually around the 4th or 5th why
- C) Never
- D) the 100th why

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: Post-mortems are only for massive outages (P0).**
- A) False - You can perform them for any significant lesson-learned (even P2/P3).
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. 'Systemic Change' means:**
- A) Changing the font
- B) Fixing the underlying processes or tools to prevent whole classes of bugs
- C) Changing your name
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Post-Mortem Meeting' is where:**
- A) People sleep
- B) Stakeholders discuss the incident timeline and action items blamelessly
- C) Decisions are hidden
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. If action items aren't tracked, the result is:**
- A) Better code
- B) The same incident happening again (The 'loop')
- C) More money
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. 'Blameless' language: Instead of "The dev forgot the config," use:**
- A) "The dev is lazy"
- B) "The configuration management process lacked a validation step"
- C) Nothing
- D) "It was magic"

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: You should include 'What Went Well' in the report.**
- A) True - It's important to recognize good response behavior.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. 'Dark Debt' refers to:**
- A) Money owed to criminals
- B) Hidden systemic complexities that lead to unexpected failures
- C) A broken monitor
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Who should lead the Post-Mortem meeting?**
- A) The person who caused the bug
- B) Usually the Incident Commander or an SRE Lead
- C) The janitor
- D) the customer

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. A 'Corrective Action' is:**
- A) A post on Twitter
- B) An action item that fixes the root cause
- C) A bonus
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: You can use ChatGPT to help draft a post-mortem from Slack logs.**
- A) True - It's a great tool for summarizing timelines.
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Information Decay' is why we do post-mortems:**
- A) Slowly over a year
- B) Quickly (within 48 hrs) because people forget details
- C) Never
- D) monthly

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Gamedays' are often result from:**
- A) Boredom
- B) Post-mortem action items to "Practice" certain failure scenarios
- C) Hobbies
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. Under-reporting an incident leads to:**
- A) Faster fixes
- B) Skewed reliability data and missed learning opportunities
- C) More trust
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Blameless' SRE culture was famously pioneered by:**
- A) Microsoft
- B) Google
- C) Yahoo
- D) Apple

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. A post-mortem is the _____ of the learning loop.**
- A) Start
- B) Closure/Completion
- C) Middle
- D) Enemy

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
