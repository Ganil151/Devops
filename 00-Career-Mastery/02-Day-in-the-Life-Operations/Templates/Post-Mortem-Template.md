# 📄 Blameless Post-Mortem Template

**Incident Title**: [Short, descriptive name]
**Date**: YYYY-MM-DD
**Duration**: [Total time from detection to mitigation]
**Impact**: [The "User" cost: Who was affected? How many? What features were broken?]

---

### 1. The TL;DR (Executive Summary)
*Briefly explain what happened in 3 sentences.*

### 2. The Timeline
*Chronological list of events in UTC.*
- **14:00**: Issue detected by [Monitoring Alert/Customer Report].
- **14:05**: Incident declared; War Room opened.
- **14:20**: Initial rollback attempted.
- **14:35**: Service restored.

### 3. The Root Cause (The "Why")
*Use the "5 Whys" method.*
- **Problem**: Auth-API was down.
- **Why?** Redis connection failed.
- **Why?** Redis Security Group was changed.
- **Why?** Manual change made in AWS Console.
- **Why?** IaC wasn't used for this specific rule.

### 4. Action Items (Prevention)
*What MUST we do to ensure this never happens again?*
- [ ] Move Redis SG rules into Terraform.
- [ ] Implement an automated health check for Redis connectivity.
- [ ] Review Console Access permissions for Juniors.

---

### 🏛️ The Blameless Mindset
> "We assume everyone acted with the best intentions and the best information they had at the time. We are investigating the **System**, not the **Person**."
