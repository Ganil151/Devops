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

## 🏗️ Real-Life Scenario: The "Silent" Outage
**Problem**: Site is down for 2 hours. No status page update.
**Customer Reaction**: Thousands of angry tweets, support tickets, and cancellations.
**CEO Reaction**: "Why didn't we communicate?"
**Fix**: Implement mandatory status page updates within 5 minutes of any P0/P1.
**Result**: Next outage, customers appreciate the transparency. Churn rate stays normal.

---

## ❓ Interview Questions
1.  **Why is it important to update the status page even if you don't have a solution yet?**
    *   *Answer*: Because silence creates uncertainty and panic. Acknowledging the issue and committing to updates shows customers you're aware and working on it, which builds trust even during failures.
2.  **What is the role of the Communications Lead during an incident?**
    *   *Answer*: To manage all external and internal stakeholder communication, update the status page, shield engineers from interruptions, and ensure consistent messaging across all channels.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Who updates the status page?** (Communications Lead)
2.  **True/False: You should wait until you have a fix before updating the status page.** (False - acknowledge immediately)
3.  **How often should you update stakeholders during a P1?** (Every 15-30 minutes)
4.  **Should external communications use technical jargon?** (No - keep it simple)
5.  **What is the first status page update?** (Acknowledgment that you're investigating)
