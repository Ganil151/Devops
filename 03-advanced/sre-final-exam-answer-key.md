# 🦅 The SRE Final Exam: Answer Key & Rubric

> **"A correct answer without reasoning is a guess. An SRE does not guess."**

This document provides the "Principal Architect" solutions to the final exam. Use this to grade yourself.

---

## 🏗️ Structure & Scoring

| Section | Points | Passing | Principal Level |
|:---|:---|:---|:---|
| **Architecture** | 40 | 25 | 35+ |
| **Chaos** | 30 | 20 | 28+ |
| **FinOps** | 30 | 20 | 28+ |
| **Total** | **100** | **65** | **90+** |

---

## 📐 Section 1: Architecture (The Design)

### Q1: The "Impossible" SLO
**Scenario**: Product asks for 99.999% Availability (5 minutes downtime/year) on a single-region architecture.
**Correct Answer**: 
> "I reject the request. 99.999% is mathematically impossible in a single region because the underlying AWS Service SLA (e.g., EC2) is only 99.9%. The compound availability of a single-region stack is lower than the dependency with the lowest SLA. To achieve 5 nines, we need a Multi-Region Active-Active architecture with automatic failover, which will cost 3x-4x more. Are you willing to pay for that?"

**Rubric**:
- **0 Points**: "Sure, we can do it." (Instant Failure)
- **5 Points**: "We need to optimize code."
- **10 Points**: Correctly identifies "Physics" (SLA Math) and "Economics" (Cost vs. Reliability).

### Q2: The "Thundering Herd"
**Scenario**: A region fails. You flip the DNS to the secondary region. The secondary region immediately crashes. Why?
**Correct Answer**: 
> "Cold Caches and Capacity Limits. The secondary region was likely scaled for 'Passive' load (0% traffic) or only 50% traffic. When 100% of global traffic hit it, the Autoscaler couldn't spin up pods fast enough (latency), and the Database connection pool was exhausted. **Fix**: Pre-scale the secondary region *before* flipping DNS (over-provisioning) or use 'Shed Load' strategies."

**Rubric**:
- **10 Points**: Mentions "Autoscaling Lag" or "Cache Warming."

---

## 💥 Section 2: Chaos Engineering (The Break)

### Q3: The "Split Brain"
**Scenario**: You lose connectivity between US-East and EU-West. The database is Active-Active. Both writes succeed. Connectivity returns. Data is corrupted.
**Correct Answer**:
> "This is a CAP Theorem failure (Partition Tolerance). We chose Availability (AP) over Consistency (CP). To fix this, we must implement a **Conflict Resolution Strategy** (e.g., Last Writer Wins, CRDTs) or switch to a CP database (e.g., CockroachDB) that would have rejected writes in the minority partition."

---

## 💰 Section 3: FinOps (The Bill)

### Q4: The "Zombie" Cluster
**Scenario**: Devs spin up test clusters and forget them. The bill is $10k/month.
**Correct Answer**:
> "Implement an automated **Reaper Script** (e.g., Cloud Custodian) that tags resources with `TTL=7days` upon creation. If the tag expires and no 'Extension' is requested, the resource is terminated. Also, enable 'Spot Instances' for all non-production workloads."

---
**Status**: 🔐 Classified (Eyes Only)
**Next Step**: [Deploy the Capstone](../04-capstone/readme.md)
