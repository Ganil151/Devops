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

### 3. Root Cause Analysis (The "5 Whys")
To find the systemic failure, we don't stop at the first answer.

1. **The Problem**: [What happened?]
2. **Why?**: [Immediate technical cause]
3. **Why?**: [Underlying technical cause]
4. **Why?**: [Process or human error factor]
5. **Why?**: [Organization or fundamental system failure]

---

### 📝 Real-World Example: The "Migration of Death"
**Incident**: Production Database Lockout during v2.4 Release.

1. **Problem**: The users saw 502 Bad Gateway errors for 20 minutes.
2. **Why?**: The Auth-service could not connect to the RDS PostgreSQL instance.
3. **Why?**: The database was in a `LOCKED` state due to a long-running ALTER TABLE command.
4. **Why?**: The migration script added a column with a default value to a table with 50 million rows, requiring a full rewrite of the data.
5. **Why (The Root Cause)**: We lacked a "Migration Review" gate that flags schema changes on large tables as high-risk, and our CI/CD didn't test the migration against a production-sized dataset.

---

### 4. Action Items (Prevention)
*What MUST we do to ensure this never happens again?*
- [ ] Implement a `pg_repack` or zero-downtime migration tool (e.g., gh-ost).
- [ ] Add a "Migration Review" checklist for all PRs involving schema changes.
- [ ] Provision a "Load Test" environment that mirrors production data volume for staging migrations.

---
### 🏛️ The Blameless Mindset
> "We assume everyone acted with the best intentions and the best information they had at the time. We are investigating the **System**, not the **Person**."
