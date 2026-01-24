# 🧪 Quiz: Modern Operations (AI-Ops, FinOps, & Reliability)

Test your knowledge of the "Day 2" operational excellence strategies added in the Intermediate track.

---

## 💰 Section 1: FinOps & Cost Governance

1. **What is the primary goal of "FinOps" in a cloud-native environment?**
   - A) To cut costs at any cost.
   - B) To bring financial accountability to the variable spend of cloud.
   - C) To replace engineers with accountants.
   - D) To move all workloads to on-premises servers.

2. **In the context of Kubernetes, what does "Namespace Allocation" refer to?**
   - A) Assigning a specific IP range to a namespace.
   - B) Breaking down the cloud bill based on which team/namespace used which resources.
   - C) Limiting the number of users who can access a namespace.
   - D) Deleting namespaces that cost too much money.

3. **What is "Infracost"?**
   - A) A cloud provider billing console.
   - B) A tool that provides "Cost-as-Code" by showing price changes in a Pull Request.
   - C) A type of cheap virtual machine.
   - D) A monitoring dashboard for CPU usage.

---

## 🤖 Section 2: AI-Ops & Automation

1. **Which "Signal" is handled by an AI-Ops engine to reduce alert fatigue?**
   - A) Log rotation.
   - B) Event correlation (grouping identical logs into one incident).
   - C) Manual SSH restarts.
   - D) Database schema updates.

2. **What is a "Self-Healing" system?**
   - A) A system that never breaks.
   - B) A system that requires a Senior SRE to fix every issue.
   - C) A system that automatically executes a runbook when a specific health check fails.
   - D) An AI that writes code for you.

---

## 📜 Section 3: Runbooks & Incident Response

1. **What is the difference between a "Standard Operating Procedure" (SOP) and a "Runbook"?**
   - A) SOPs are for humans; Runbooks are for automated execution (or precise manual steps).
   - B) Runbooks are only for databases.
   - C) SOPs are for legal teams only.
   - D) There is no difference.

2. **The "Bus Factor" in documentation refers to:**
   - A) How many buses are needed for an office move.
   - B) The number of people who can be "hit by a bus" (leave/be unavailable) before the knowledge is lost.
   - C) The speed of the network backbone.
   - D) The cost of server transportation.

---

## 🏗️ Real-World Scenario: The Bill Shock incident

Your startup launched a new feature. Within 48 hours, the AWS bill has spiked by $5,000 because an engineer accidentally provisioned `iops-heavy` storage for a development database.

**Question**: Which tool/practice would have caught this *before* the resources were created?

- A) Prometheus Alerting.
- B) Infracost in the CI/CD pipeline.
- C) CloudWatch Logs.
- D) Kubernetes HPA.

---

## 🗝️ Answer Key

1. B
2. B
3. B
4. B
5. C
6. A
7. B

**Scenario Answer**: B (Infracost would have flagged the $5,000 increase in the Pull Request before it was merged).
