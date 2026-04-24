# Soft Skills for Engineers

## The "Hidden" Technical Skills
In DevOps, **communication is a technical skill**.  A brilliant engineer who cannot explain *why* the server crashed is a liability. This module covers the soft skills that seniors look for.

---

## 1. Communicating During Outages
When production is down, panic is the enemy. Clear communication builds trust.

### The 3 Ws of Incident Reporting:
1.  **What** is happening? (Symptoms, not guesses).
2.  **Who** is affected? (Internal users, all customers, payment systems?).
3.  **When** do we expect the next update? (Set a cadence).

> **Pro Tip:** never go silent. Even "We are still investigating, next update in 15 mins" is better than silence.

---

## 2. Documentation: "If it isn't written down, it doesn't exist."
Code explains *how* software works. Documentation explains *why* and *how to run it*.

### The Hierarchy of Docs:
*   **README:** The first impression. How to install and run.
*   **Runbooks:** Step-by-step guides for when things break (e.g., "How to restart the database cluster").
*   **Architecture Diagrams:** Visual maps of the system.

### The "Junior Challenge"
Take a complex script you wrote. Hand the README to a non-technical friend. Can they run it without asking you questions? If not, rewrite it.

---

## 3. The Blameless Post-Mortem
We do not fire people for making mistakes. We fix the *process* that allowed the mistake to happen.

### The Rule
> "You cannot fire your way to reliability."

### The Post-Mortem Template
After a major incident, run a "Retrospective" covering:
1.  **Timeline:** What happened and when?
2.  **Root Cause:** The technical reason (e.g., "Memory leak in v2.4").
3.  **Contributing Factors:** The process reason (e.g., "We lacked a monitoring alert for memory usage").
4.  **Action Items:** What are we building to ensure this **never happens again**?

---

## 4. Empathy in Engineering
DevOps sits between Devs and Ops.
*   **For Developers:** We build tools to make their lives easier, not to block them with bureaucracy.
*   **For Users:** We treat uptime as a feature because downtime hurts their business/life.

## 5. Managing Up: Tech Debt vs. Features
As you grow, you will often find yourself in a tug-of-war with Product Managers (PMs) who want new features, while you know the system needs stability (Tech Debt).

### 💬 The "Staff Level" Script
Don't say: "We can't do that; the codebase is a mess."
Say: "If we implement [Feature X] without addressing the [Tech Debt Y], we increase the data-loss risk by **20%** and will likely see **3 hours** of additional downtime per month. I recommend a '70/30' sprint where we spend 30% of our capacity on stabilizing the database so the feature can scale securely."

**Key Logic:**
- **Translate** technical pain into **Business Risk**.
- **Quantify** the cost of ignoring the problem (Downtime = Lost Revenue).
- **Propose a Compromise**, don't just say "No."

---

## 🏁 Summary Checklist for Soft Skills
- [ ] Do I communicate clearly in tickets/chats?
- [ ] Do I assume positive intent (Collaborative Spirit)?
- [ ] Is my documentation helpful to strangers?
- [ ] Do I focus on fixing systems, not blaming people?
- [ ] Can I translate technical risk into business impact?

---

*This guide is part of the 00-career-mastery module.*
