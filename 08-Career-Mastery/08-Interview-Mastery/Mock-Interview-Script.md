# 👔 The Mock Interview Script (Staff Level Benchmarking)

This script is designed for peer-to-peer practice or self-reflection. It covers the three distinct phases of a high-tier DevOps/SRE interview.

---

## 🏗️ Phase 1: The Behavioral Deep-Dive (STAR Method)
**The Goal**: Assess ownership and "Soft Skills for Engineers."

**1. Question**: "Tell me about a time you broke a production environment. What did you do?"
*   **Junior Trap**: Blaming someone else or saying "I've never broken anything."
*   **SRE Standard**: Own the mistake. Explain the **Detection** (how you found out), the **Mitigation** (how you fixed it fast), and the **Prevention** (the PR you wrote to ensure it never happens again).

**2. Question**: "How do you handle a conflict with a developer who insists their broken code is an infrastructure issue?"
*   **Goal**: Assess empathy and data-driven communication.
*   **Key Phrase**: "I use logs and metrics as the 'Shared Source of Truth' to guide the conversation toward a solution rather than an argument."

---

## 🏛️ Phase 2: The Architectural "Logic Test"
**The Goal**: Assess system-wide thinking.

**The Scenario**: "We have a monolithic application experiencing 504 Gateway Timeouts during sales peaks. How do you troubleshoot and scale this?"

**The Checklist for your Answer**:
- [ ] **Layer 1**: Check the Load Balancer (Are targets healthy?).
- [ ] **Layer 2**: Check application resources (CPU/Memory exhaustion).
- [ ] **Layer 3**: Check the Database (Slow queries or connection limits).
- [ ] **The "Architect" Move**: Propose a horizontal scaling strategy or a caching layer (Redis) to offload the DB.

---

## 🛠️ Phase 3: The Technical "Toolbelt" (Rapid Fire)

| Category | The Question | Expectation |
| :--- | :--- | :--- |
| **CI/CD** | "What is the difference between Continuous Delivery and Continuous Deployment?" | Delivery = Manual gate to Prod; Deployment = Fully automated to Prod. |
| **Terraform** | "Why should you never manually delete a resource created by Terraform in the AWS console?" | It creates **State Drift**, causing future `terraform apply` runs to fail or behave unexpectedly. |
| **Linux** | "How do you find which process is using Port 80?" | Using `lsof -i :80` or `netstat -tulpn | grep :80`. |
| **Containers** | "Explain the difference between a Docker Image and a Container." | Image = Blueprint (Read-only); Container = Running Instance (Writeable layer). |

---

## 🎭 Simulation Challenge: The "Senior" Follow-up
In every interview, after you give a good answer, a Senior will ask: **"And what if [Scenario X] happens?"**

**Practice this**:
- Pick an answer you feel confident in.
- Now, remove one piece of that solution (e.g., "What if we can't use a Load Balancer?").
- **Goal**: Don't panic. Explain the alternatives and the trade-offs.

---

### 🏛️ Mentorship Advice: Pro-Tip
Closing the interview is just as important as starting it. Always have 3 questions ready for them:
1. "What does a successful first 90 days look like for a Junior in this team?"
2. "How does the team handle blameless post-mortems after an outage?"
3. "What is the biggest technical debt the team is currently working to pay down?"
