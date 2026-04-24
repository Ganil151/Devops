# ⏱️ Mock Interview Scripts: 30-Minute Timed Simulations

Practice these scenarios to build the muscle memory needed for real-time technical screenings.

---

## 🟢 Simulation 1: The Junior/Foundational Round (30 min)
**Focus:** Linux, Networking, and Basic Automation

### Q1: The Kernel & Filesystem (10 min)
- **Question:** "Walk me through what happens when you run `ls -l`. How does the shell find the command and what system calls are involved?"
- **Success Criteria:** Mentioning `$PATH` search, `fork()`, `exec()`, and `stat`/`getdents` calls.

### Q2: Networking & Troubleshooting (10 min)
- **Question:** "A developer says their app can't talk to the database. Walk me through the troubleshooting steps from the application server."
- **Success Criteria:** Checking `ping`, `telnet`/`nc` for port connectivity, DNS resolution with `nslookup`/`dig`, and checking security groups.

### Q3: Version Control (10 min)
- **Question:** "Explain a merge conflict. How do you resolve it, and how do you prevent it in a team environment?"
- **Success Criteria:** Explaining rebase vs merge, feature branches, and small, frequent commits.

---

## 🟡 Simulation 2: The Intermediate/Infrastructure Round (30 min)
**Focus:** Terraform, AWS, and Cloud Architecture

### Q1: Infrastructure as Code (15 min)
- **Question:** "We have a project where Terraform state was accidentally deleted. How do you recover? How do you prevent this?"
- **Success Criteria:** Importing resources with `terraform import`, mention of state locking (DynamoDB) and state versioning (S3).

### Q2: Scalability & High Availability (15 min)
- **Question:** "Design a highly available architecture for a web app that needs to survive an AWS region outage (or at least an AZ outage)."
- **Success Criteria:** Use of Multi-AZ ASG, Application Load Balancer, Multi-AZ RDS, and Route53 health checks.

---

## 🔴 Simulation 3: The Senior/Architectural Round (30 min)
**Focus:** Kubernetes, SRE, and Trade-Off Analysis

### Q1: Kubernetes Troubleshooting (15 min)
- **Question:** "A pod is in `CrashLoopBackOff`. Walk me through the internal K8s events happening and your priority list for debugging."
- **Success Criteria:** Checking `kubectl describe events`, `kubectl logs`, probes failure investigation, and resource constraints (OOM).

### Q2: Trade-Off Analysis (15 min)
- **Question:** "We are deciding between EKS (Managed K8s) and ECS (Managed Containers). Which one do you recommend for a team of 3 engineers with 20 microservices, and why?"
- **Success Criteria:** Analyzing operational overhead, cost (control plane), flexibility, and team expertise.

---
👉 **[Back to Interview Mastery Hub](../09-interview-mastery/readme.md)**
