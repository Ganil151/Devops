# 👔 Part 03: Interview Mastery (Technical & Behavioral)

Mastering the interview is about storytelling. You need to prove you have both the "Hard Skills" to build and the "Soft Skills" to collaborate.

---

## 🏛️ The STAR Method (Behavioral)

For every "Tell me about a time..." question, use:

-   **S**ituation: Set the scene.
-   **T**ask: What was the goal?
-   **A**ction: What **did you do**? (Be specific).
-   **R**esult: What was the impact? (Use numbers).

---

## 👔 Interview Preparation (Mastery)

1.  **Q: Tell me about a major production outage you handled.**
    -   *A: Use STAR. Focus on your investigation process (logs/metrics), how you restored service (rollback/fix), and the blameless post-mortem you led.*
2.  **Q: How do you handle a difference of opinion with a senior developer?**
    -   *A: Focus on data and technical consensus. Present the trade-offs of both approaches and align on the decision that best serves system stability.*
3.  **Q: What is your process for learning a new technology?**
    -   *A: Discuss building "Proof of Concepts" (PoCs), reading documentation, and contributing to open-source or internal wikis.*
4.  **Q: Explain a complex technical concept (like mTLS) to a manager.**
    -   *A: Use analogies. "mTLS is like having a secret handshake where both parties must prove who they are before they start talking."*
5.  **Q: How do you prioritize your tasks when everything is "Urgent"?**
    -   *A: Use the Eisenhower Matrix or follow "Customer Impact" first. Focus on tasks that stabilize the environment or unblock the most people.*

---

# 🏗️ Part 04: Portfolio Projects & The "Golden Project"

Your GitHub is your physical proof. One high-quality repo is worth more than 50 "Hello World" tutorials.

---

## 🏆 The "Golden Project" Checklist

To impress a Senior Engineer, your project should include:

-   [ ] **Infrastructure as Code**: Terraform or Ansible.
-   [ ] **CI/CD Pipeline**: GitHub Actions or Jenkins.
-   [ ] **Containerization**: Docker & Kubernetes.
-   [ ] **Observability**: A Grafana dashboard or Prometheus alerting rule.
-   [ ] **Documentation**: A professional README with architecture diagram.

---

## 👔 Interview Preparation (Portfolio)

1.  **Q: Why is a "Clean README" important for a portfolio?**
    -   *A: It is the first thing a recruiter sees. It should explain the "Why" (problem solved), the "What" (tech stack), and the "How" (architectural flow).*
2.  **Q: How do you handle secrets (API keys) in a public GitHub repo?**
    -   *A: Use `.gitignore` for local secrets and GitHub Secrets / Vault for production. Never commit credentials.*
3.  **Q: What is "Documentation as Code"?**
    -   *A: Treating documentation like software—storing it in Git, versioning it, and using tools to auto-generate parts of it.*
4.  **Q: How would you show "Continuous Improvement" in your portfolio?**
    -   *A: By having a commit history that shows you refracting code, adding security scans, or improving the efficiency of a pipeline over time.*
5.  **Q: Why should you include an "Architecture Diagram"?**
    -   *A: It proves you understand the "System" as a whole, not just individual components. Visuals communicate complexity faster than text.*

---

**Challenges**: [technical_scenarios.md](./challenges/technical_scenarios.md)
**Showcase**: [00-Resources/05-Projects-Showcase](../../00-Resources/05-Projects-Showcase/README.md)
