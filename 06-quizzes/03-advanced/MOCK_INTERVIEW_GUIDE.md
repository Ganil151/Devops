# 📋 Interview Prep: DevOps "Screening" Questions

This guide uses the consolidated quiz questions to simulate a verbal technical screening. Use these questions to practice explaining concepts clearly and concisely.

---

## 🟢 Junior Level (Foundational)

**Question:** "Can you explain the difference between a process and a thread in Linux?"

*   **Key Concepts to Mention:**
    *   Memory sharing (Thread shares memory, Process has isolated memory).
    *   Context switching overhead (Thread is lighter).
    *   Example: A web server like Apache vs Nginx worker processes.

**Question:** "What happens when you type `ls -l` and hit enter? Walk me through the kernel's perspective."

*   **Key Concepts to Mention:**
    *   Shell parsing.
    *   Searching `$PATH`.
    *   `fork()` and `exec()`.
    *   System calls (`getdents`).

---

## 🟡 Intermediate Level (Infrastructure & Cloud)

**Question:** "We need to scale our application automatically based on CPU usage. How would you design this in AWS?"

*   **Key Concepts to Mention:**
    *   Auto Scaling Group (ASG).
    *   Launch Template (AMI, Instance Type).
    *   CloudWatch Alarm (Metric > Threshold).
    *   Scaling Policy (Step scaling vs Target tracking).

**Question:** "Explain how Terraform manages state and why it's critical for team collaboration."

*   **Key Concepts to Mention:**
    *   `terraform.tfstate`.
    *   Mapping resource IDs to code.
    *   Locking (DynamoDB) to prevent race conditions.
    *   Remote State (S3) for sharing.

---

## 🔴 Senior Level (System Design & Troubleshooting)

**Question:** "A microservice in Kubernetes is crash-looping. How do you debug it?"

*   **Key Concepts to Mention:**
    *   `kubectl get pods` (Status).
    *   `kubectl describe pod` (Events: OOMKilled, Liveness Probe fail).
    *   `kubectl logs` (Application stack trace).
    *   Checking metrics (Prometheus/Grafana).

**Question:** "Design a highly available architecture for a stateful application across two regions."

*   **Key Concepts to Mention:**
    *   Global Traffic Manager (Route53).
    *   Active-Active vs Active-Passive.
    *   Database Replication (Aurora Global Database, Cross-Region Replication).
    *   Latency considerations (CAP theorem trade-offs).

---

## 📝 Self-Assessment Rubric

| Level | Expectation |
| :--- | :--- |
| **Junior** | Can define terms and use basic commands. |
| **Intermediate** | Can explain *workflows* and connect multiple tools (e.g., Terraform -> AWS). |
| **Senior** | Can discuss *trade-offs*, edge cases, and architectural decisions. |
