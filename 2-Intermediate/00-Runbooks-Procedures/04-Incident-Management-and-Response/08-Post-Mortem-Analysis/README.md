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

## 🏗️ Real-Life Scenario: The "Blame Game" Disaster
**Problem**: After an outage, the post-mortem says "Engineer X made a mistake."
**Outcome**: Engineer X feels attacked, becomes defensive, hides details.
**Long-term**: Team culture becomes toxic. People hide mistakes instead of learning from them.
**Fix**: Rewrite post-mortem with blameless language focusing on system gaps.
**Result**: Engineer X shares full details. Team learns. System is improved.

---

## ❓ Interview Questions
1.  **What is the purpose of a blameless post-mortem?**
    *   *Answer*: To create a safe environment where people can honestly share what happened without fear of punishment, enabling the team to learn from failures and improve systems rather than hiding mistakes.
2.  **What is the 'Five Whys' technique?**
    *   *Answer*: A root cause analysis method where you ask "Why?" five times to drill down from the symptom to the underlying systemic cause, moving beyond surface-level explanations.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Should post-mortems blame individuals?** (No - focus on systems)
2.  **True/False: Post-mortems should be conducted within 48 hours.** (True)
3.  **What is the 'Five Whys'?** (Root cause analysis technique)
4.  **Should action items have owners and due dates?** (Yes)
5.  **What should the executive summary include?** (What happened, impact, root cause)
