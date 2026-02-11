# 👔 The DevOps Mock Interview Master Script

> **Goal:** High-tier benchmarking for Junior, Intermediate, and Staff-level roles.

---

## ⏱️ Part 1: 30-Minute Targeted Simulations

Use these scripts for peer-review or self-recorded practice. Set a timer!

### ☁️ Script A: The Cloud Engineer (Generalist)
**Focus:** AWS, Linux, and Basic Automation.

- **00:00 - 05:00**: **Intro & Resume Walkthrough**. (Focus on the 04-projects you built).
- **05:00 - 15:00**: **The Networking gauntlet**.
  - "What is the difference between an Internet Gateway and a NAT Gateway?"
  - "Walk me through how a packet reaches a private EC2 instance."
- **15:00 - 25:00**: **Terraform & Scaling**.
  - "How do you manage cross-account resource sharing in Terraform?"
  - "How do you handle a sudden traffic spike to an RDS database?"
- **25:00 - 30:00**: **Behavioral**.
  - "Tell me about a time you had to learn a new tool under a tight deadline."

### ☸️ Script B: The Kubernetes/SRE Specialist (Platform)
**Focus:** K8s, Observability, and High Availability.

- **00:00 - 05:00**: **Intro & "The Why"**. Why Kubernetes? Why not just ECS?
- **05:00 - 15:00**: **K8s Internals**.
  - "What happens behind the scenes when you run `kubectl apply -f deployment.yaml`?"
  - "Explain the difference between a Liveness, Readiness, and Startup probe."
- **15:00 - 25:00**: **The Pipeline & Observability**.
  - "How do you implement GitOps for a multi-cluster environment?"
  - "A pod is stuck in `CrashLoopBackOff`. Walk me through your debugging steps."
- **25:00 - 30:00**: **Incident Response**.
  - "Tell me about a time you handled a real-time production outage. What was your communication style?"

### 🐍 Script C: The Automation/DevSecOps Engineer
**Focus:** Python/Bash, Security, and CI/CD.

- **00:00 - 10:00**: **Coding Live-Screen**.
  - "Write a script to find all files in a directory larger than 100MB and move them to S3."
- **10:00 - 20:00**: **The Security Layer**.
  - "What is a 'Shift Left' strategy in a Jenkins pipeline?"
  - "How do you rotate secrets for 100+ services without downtime?"
- **20:00 - 30:00**: **Architectural Whiteboarding**.
  - "Design a secure, serverless API for a fintech application."

---

## 🏛️ Part 2: Staff-Level Benchmarking (Phase-by-Phase)

This section covers the distinct phases of a high-tier Staff/Principal interview.

### Phase 1: The Behavioral Deep-Dive (STAR Method)
**1. Question**: "Tell me about a time you broke a production environment. What did you do?"
*   **SRE Standard**: Own the mistake. Explain the **Detection**, the **Mitigation**, and the **Prevention** (the PR you wrote to ensure it never happens again).
**2. Question**: "How do you handle a conflict with a developer who insists their broken code is an infrastructure issue?"
*   **Key Phrase**: "I use logs and metrics as the 'Shared Source of Truth' to guide the conversation toward a solution rather than an argument."

### Phase 2: The Architectural "Logic Test"
**Scenario**: "We have a monolithic application experiencing 504 Gateway Timeouts during sales peaks. How do you troubleshoot and scale this?"

**Checklist**:
- [ ] **Layer 1**: Check the Load Balancer (Are targets healthy?).
- [ ] **Layer 2**: Check application resources (CPU/Memory exhaustion).
- [ ] **Layer 3**: Check the Database (Slow queries or connection limits).
- [ ] **The "Architect" Move**: Propose a horizontal scaling strategy or a caching layer (Redis).

---

## 🏆 Scoring & Success Metrics

### The 5-Point Rule
- **1-2 Points**: Gave the definition but no context.
- **3-4 Points**: Explained the concept and mentioned a tool.
- **5-6 Points**: Explained the concept, mentioned a tool, and **referenced a specific lab or real-world problem you solved**.

### Mentorship Advice
Always have 3 questions ready for the interviewer:
1. "What does a successful first 90 days look like for a new joiner in this team?"
2. "How does the team handle blameless post-mortems after an outage?"
3. "What is the biggest technical debt the team is currently working to pay down?"

---
*Back to [Career Mastery](./readme.md)*
