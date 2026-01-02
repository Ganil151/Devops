# Communication and Stakeholders

Poor communication during an incident can be as damaging as the incident itself. **Silence creates panic.**

## The Communication Layers

### 1. Internal Team (War Room)
**Channel**: Dedicated Slack channel or Zoom.
**Frequency**: Continuous updates.
**Audience**: IC, Ops Lead, Engineers, Scribe.
**Content**: Technical details, commands run, observations.

### 2. Internal Stakeholders
**Channel**: Separate Slack channel or email.
**Frequency**: Every 15-30 minutes.
**Audience**: Leadership, Product Managers, Customer Support.
**Content**: High-level status, impact, ETA.

### 3. External Customers
**Channel**: Status page (e.g., status.company.com).
**Frequency**: Initial + every major update.
**Audience**: All customers.
**Content**: What's broken, what we're doing, when it will be fixed.

---

## The Status Page Template

### Initial Update (Within 5 minutes of P0/P1)
```
🔴 Investigating - Payment Processing Issues
Posted: 2024-01-15 14:03 UTC

We are currently investigating reports of payment processing failures. 
Our team is actively working on this issue. We will provide an update 
within 30 minutes.
```

### Progress Update (Every 15-30 minutes)
```
🟡 Identified - Payment Processing Issues
Updated: 2024-01-15 14:25 UTC

We have identified the issue as a database connection pool exhaustion. 
Our team is implementing a fix. Estimated resolution: 15 minutes.
```

### Resolution Update
```
🟢 Resolved - Payment Processing Issues
Updated: 2024-01-15 14:42 UTC

The issue has been resolved. All payment processing is now operational. 
We will publish a detailed post-mortem within 48 hours.
```

---

## Communication Best Practices

### 1. Acknowledge Immediately
Even if you don't have answers, acknowledge the incident.
- **Bad**: Silence for 30 minutes.
- **Good**: "We're aware and investigating" within 5 minutes.

### 2. Set Expectations
Give realistic ETAs, not optimistic ones.
- **Bad**: "Fixed in 5 minutes" (then it takes 2 hours).
- **Good**: "Investigating. Next update in 30 minutes."

### 3. Avoid Technical Jargon (External)
Customers don't care about "pod restarts" or "circuit breakers."
- **Bad**: "The Kubernetes HPA failed to scale the deployment."
- **Good**: "We're experiencing high traffic and adding more capacity."

### 4. Own the Mistake
Don't blame vendors or external factors.
- **Bad**: "AWS had an outage" (even if true).
- **Good**: "We experienced an infrastructure issue that affected our service."

---

---

## 🏗️ Real-Life Scenarios

### Scenario 1: The "Silent" Multi-Hour Outage
**Problem**: A major SaaS provider experienced a network blackout at 9:00 AM. The engineers immediately began fixing it but didn't update the status page for 90 minutes.
**Crisis**: Tens of thousands of users flooded Twitter and Support channels. Because there was no official word, rumors spread that the company was "Hacked" or "Going out of business."
**Outcome**: The CEO had to personally issue a public apology. The company saw a 15% increase in churn that month due to "Lost Trust," not the technical failure itself.
**Solution**: Implemented a **5-Minute Status Rule**. Even if the cause is unknown, a "We are investigating" post must be live within 5 minutes of a P1 declaration.
**Result**: Transparency improved trust, and support ticket volume dropped by 60% during the next incident.

### Scenario 2: The "Over-Optimistic" ETA
**Problem**: During an API outage, the Communications Lead posted: "We have found the bug. Service will be restored in 10 minutes."
**Crisis**: The "Fix" failed and actually corrupted 5% of the data, requiring a 4-hour restore from backup.
**Outcome**: Customers were furious because they had planned their work around the "10-minute" promise. The support team was overwhelmed by users asking why the 10 minutes had passed.
**Solution**: Switched to **Time-Interval Communication**. Instead of promising a fix time, they promise a "Next Update" time (e.g., "We will update you in 20 minutes regardless of progress").
**Result**: Stakeholder stress decreased because expectations were managed realistically.

### Scenario 3: The "TMI" (Too Much Information) status Page
**Problem**: An engineer wrote the status page update: "Our Kubernetes Horizontal Pod Autoscaler failed to scale the `java-api-server` due to a YAML syntax error in the ConfigMap."
**Crisis**: Customers didn't understand the jargon and started asking support: "What is a Kubernetes? Is my data safe?" The technical detail actually caused more confusion than clarity.
**Outcome**: Customer Support spent more time explaining "Containers" than actually helping users.
**Solution**: Implemented **Tiered Communication**. Technical details go to the Internal War Room. User-friendly language (e.g., "We are adding more capacity to handle peak load") goes to the Status Page.
**Result**: Communication became more effective, bridge calls stayed focused, and customers felt informed without being confused.

---

## ❓ Interview Questions

1.  **Why is 'Silence' considered the biggest mistake in incident communication?**
    - *Answer*: Silence creates a vacuum that users fill with their own fears (e.g., "We've been hacked!"). Proactive communication, even if it's just "We are investigating," maintains control of the narrative and keeps user trust.
2.  **Describe the role of the 'Comms Lead' in a P1 incident.**
    - *Answer*: The Comms Lead translates technical updates from the Ops Lead into "Internal Stakeholder" updates (for leadership) and "External Updates" (for the status page). They shield the fixing engineers from being interrupted by questions from the CEO or Support.
3.  **What is the difference between an 'Internal' update and an 'External' update?**
    - *Answer*: **Internal** updates are technical and specific (e.g., "DB Load is at 99%"). **External** updates focus on utility and impact (e.g., "You may experience slow page loads while we perform maintenance").
4.  **How do you handle 'Negative' news on a status page?**
    - *Answer*: Be honest, be concise, and focus on the **Action** being taken. Avoid blame (e.g., "It's AWS's fault") and instead take ownership of the response (e.g., "We are working with our infrastructure provider to restore service").
5.  **What is a 'Status Page' and why is it essential for SRE?**
    - *Answer*: A public dashboard that reflects the real-time health of services. It is essential because it serves as the "Single Source of Truth" for users, reducing the load on support teams during an outage.
6.  **At what frequency should updates be sent during a P0 incident?**
    - *Answer*: Generally every 15 to 30 minutes, even if there is no significant progress. Consistency is key to keeping stakeholders calm.

---

## 🧠 Comprehensive Quiz (25 Questions)

**1. What is the most important rule of incident communication?**
- A) Use the most technical terms possible
- B) Never admit an error
- C) **Acknowledge the issue immediately**
- D) Only update after it's fixed

<details>
<summary>Show Answer</summary>

**Answer: C**

</details>

**2. True/False: Silence during an incident build customer trust.**
- A) False - Silence creates panic.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**3. Who is responsible for shielding engineers from interruptions during a crisis?**
- A) The Scribe
- B) The Incident Commander (IC) or Comms Lead
- C) The CEO
- D) The customer

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**4. External status updates should avoid:**
- A) Time stamps
- B) Technical Jargon (e.g., Kubernetes, Pods, Endpoints)
- C) Apologies
- D) help links

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**5. How often should you provide a status page update during a major outage?**
- A) Every 5 seconds
- B) Every 15-30 minutes
- C) Once a day
- D) Never

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**6. 'ETA' stands for Estimated Time of Arrival. In SRE, you should:**
- A) Always promise a 10-minute fix
- B) Be realistic and conservative with ETAs
- C) Guess
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**7. True/False: Internal stakeholders (CEOs, PMs) should be in the technical War Room channel.**
- A) False - Keep them in a separate #incident-updates channel to avoid distracting engineers.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**8. An initial status page post should be live within:**
- A) 1 hour
- B) **5 minutes** of verification
- C) 2 days
- D) never

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**9. When an incident is resolved, you should:**
- A) Delete the status page logs
- B) Update the status page to 'Resolved' and mention a Post-Mortem is coming
- C) Say nothing
- D) party

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**10. 'Stakeholders' include:**
- A) Only the engineers
- B) Anyone affected by the incident (Customers, Support, Executives, Partners)
- C) The janitor
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**11. True/False: It is okay to blame a 3rd party vendor on your public status page.**
- A) False - Take ownership of your service reliability.
- B) True

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**12. 'Internal War Room' communication is for:**
- A) Marketing
- B) Technical coordination between responders
- C) Chatting about food
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**13. A 'Scribe' helps communication by:**
- A) Fixing bugs
- B) Documenting the timeline and decisions in real-time
- C) Making coffee
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**14. What is the risk of an 'Over-Optimistic' ETA?**
- A) None
- B) Losing trust when the deadline is missed
- C) Making the site faster
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**15. 'Triage' updates are usually sent to:**
- A) Everyone on Earth
- B) The Incident Response team and internal leadership
- C) My mom
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**16. True/False: You should use a 'Template' for status page updates to save time.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**17. The Comms Lead 'translates' technical data into:**
- A) French
- B) Business/User-friendly language
- C) Code
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**18. Why is a 'Next Update' time better than a 'Fix' time?**
- A) It's lazier
- B) It manages expectations and reduces follow-up questions
- C) It's more colorful
- D) no reason

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**19. Which role confirms the content of an external update?**
- A) The Scribe
- B) The Incident Commander (IC)
- C) The customer
- D) HR

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**20. True/False: Proactive communication reduces the load on the customer support team.**
- A) True
- B) False

<details>
<summary>Show Answer</summary>

**Answer: A**

</details>

**21. 'Information Silos' are dangerous because:**
- A) They are made of grain
- B) They prevent different teams from knowing the current status/plan
- C) They use too much data
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**22. 'Post-Outage' communication is:**
- A) Not needed
- B) The Post-Mortem/RCA document shared with stakeholders
- C) A joke
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**23. If you have NO ETA, you should say:**
- A) "It will be 10 minutes"
- B) "We are still investigating the root cause and will provide an update in 20 minutes."
- C) Nothing
- D) "I don't know"

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**24. The 'Official' channel for an incident should be:**
- A) A secret
- B) Clearly defined at the start (e.g., #incident-123)
- C) Email only
- D) nothing

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>

**25. Communication is the _____ of a successful incident response.**
- A) Accessory
- B) Backbone/Lifeline
- C) End
- D) Enemy

<details>
<summary>Show Answer</summary>

**Answer: B**

</details>
