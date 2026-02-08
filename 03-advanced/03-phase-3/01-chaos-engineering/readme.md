# 🧪 Chaos Engineering: Resiliency via Destruction

> **"Chaos Engineering is the discipline of experimenting on a system in order to build confidence in the system's capability to withstand turbulent conditions in production."**

In this module, we move away from "hoping it works" and transition into **Hypothesis-Driven Resilience**. We break the network, terminate instances, and stress CPUs to ensure our "Self-Healing" systems actually heal.

---

## 🧭 The Chaos Engineering Workflow

1.  **Define "Steady State"**: Measure normal system behavior (e.g., 200ms p95 latency, 0% error rate).
2.  **Form a Hypothesis**: "If we terminate one node in the 3-node cluster, the system will remain available with no user-impact."
3.  **Run the Experiment**: Use **AWS FIS** or **Gremlin** to kill the node.
4.  **Verify & Fix**: If the hypothesis fails (e.g., sessions are lost), fix the architecture (e.g., use distributed Redis sessions).

---

## 🛠️ The Chaos Toolkit

| Tool | Focus | Difficulty |
|:---|:---|:---|
| **AWS FIS** | Native AWS service injection (Stop EC2, Latency, RDS Failover) | Intermediate |
| **Gremlin** | SaaS Chaos platform for containers and VMs. | Advanced |
| **Chaos Mesh** | Kubernetes-native chaos (Pod kill, Network loss, Kernel stress). | Advanced |
| **Pumba** | Docker-level chaos (Network delay for local dev). | Beginner |

---

## 📚 Technical Implementation Labs

### 🧪 [Lab: AWS Fault Injection Simulator (FIS)](./labs/aws-fis-resiliency-lab.md)
**Objective**: Simulate an Availability Zone outage and verify Multi-AZ failover.

### 🧪 [Lab: Kubernetes Network Chaos](./labs/k8s-network-chaos-lab.md)
**Objective**: Introduce 500ms latency between services and measure the impact on the Circuit Breaker.

---

## 🚀 Principal Architect Pro-Tips

1.  **Never Start in Production**: Run your first 100 experiments in Staging. Only move to Prod when you are "bored" by the results.
2.  **The "Stop" Button is Mandatory**: Every experiment must have a "Halt" trigger that immediately rolls back the failure if blast radius exceeds expectations.
3.  **Human Chaos is Real**: Don't just test the tech; test the **On-Call Engineer**. Do they get the alert? Does the runbook work?
4.  **Automate "Game Days"**: Don't make chaos a one-time event. Integrate it into a weekly "Scheduled Failure" to prevent regression.

---
**Module**: 01 Chaos Engineering
**Next Step**: [AWS FIS Lab](./labs/aws-fis-resiliency-lab.md)
