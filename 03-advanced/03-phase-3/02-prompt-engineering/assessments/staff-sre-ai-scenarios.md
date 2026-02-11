# 🦅 Staff SRE: AI Architecture & Orchestration Scenarios

> **"A Senior Engineer writes code. A Staff Engineer architects systems of agents that write, audit, and deploy code."**

---

## 🧠 Principal Interview Scenarios (Agentic Focus)

### Scenario 1: The Autonomous Security Firewall
**The Goal**: Build an autonomous system that responds to DDoS attacks without human intervention.
**The Prompting Strategy**:
- **Role**: Principal Security Engineer specializing in BGP and WAF.
- **Context**: Real-time traffic metrics from CloudWatch and VPC Flow Logs.
- **Agentic Loop**: 
    1. **Agent A (Analyst)**: Identifies malicious IP clusters using historical RAG data.
    2. **Agent B (Strategist)**: Generates a temporary WAF Rule to block the cluster.
    3. **Agent C (Safety Guard)**: Verifies that the rule doesn't block major customer IPs (using a whitelist).
**Success Metric**: Move from 15-minute response (human) to 30-second response (autonomous).

### Scenario 2: Legacy Migration (Terraform → OpenTofu/Pulumi)
**The Goal**: Migrate 5,000 resources from legacy Terraform 0.12 to OpenTofu 1.6 using AI.
**The Prompting Strategy**:
- Use **Few-Shot Prompting**: Provide 3 examples of complex resource transformations.
- **Constraint**: "Maintain state-file integrity. Do not recreate resources; generate `import` blocks for every resource migrated."
- **Recursive Decomposition**: Have the AI break the migration into 50 sub-task prompts to avoid context-window saturation.

---

## 🆔 Advanced AI Governance Quiz

<b>1. What is the 'Self-Correction' pattern in Agentic workflows?</b>
<details>
<summary>Show Answer</summary>
Answer: A loop where an agent's output is fed back into itself with the context of a 'failed' tool run, allowing it to fix its own syntax or logic before exiting.
</details>

<b>2. How does 'Semantic Caching' reduce LLM costs for SREs?</b>
<details>
<summary>Show Answer</summary>
Answer: It stores the vector embeddings of previous prompts. If a new prompt is semantically similar (e.g., "How to restart Nginx" vs "Restart Nginx script"), it returns the cached answer without hitting the expensive LLM API.
</details>

<b>3. What is 'LLM Jailbreaking' in a DevOps context?</b>
<details>
<summary>Show Answer</summary>
Answer: An injection attack where a developer (or external actor) tricks a deployment agent into revealing production API keys by bypassing the 'Safety System Prompt'.
</details>

<b>4. Differentiate between Zero-Shot and Dynamic-Few-Shot.</b>
<details>
<summary>Show Answer</summary>
Answer: Zero-shot gives no examples. Dynamic-few-shot uses RAG to find the 3 most relevant examples from your *own* codebase and injects them into the prompt to guide the AI's logic.
</details>

<b>5. Why is 'Temperature 0' critical for IaC generation?</b>
<details>
<summary>Show Answer</summary>
Answer: To ensure determinism. In DevOps, we need the exact same infrastructure blueprint every time a prompt is run; "creativity" in a networking manifest leads to outages.
</details>

---

## 🛠️ Staff-Level Lab: The "Red-Team" Reviewer
**Objective**: Build a multi-agent workflow in your IDE/CLI.

1.  **Actor**: Prompt an AI to generate an "Insecure" S3 bucket with public access.
2.  **Critic**: Prompt a second AI (The Security Guard) to audit the first AI's output.
3.  **Synthesizer**: A third prompt merges the two: "Based on the Critic's feedback, rewrite the Actor's code to be CIS-Compliant but preserve the original functionality."

---

## 📊 AI Success Metrics for Staff Engineers
- **Time to RCA**: Reduce from hours to minutes.
- **Prompt Fidelity**: Percentage of AI-generated code that passes CI/CD on the first run (Target: 85%+).
- **Autonomous Remediation**: Percentage of Tier-1 alerts resolved by AI agents without human-in-the-loop (Target: 40% in Year 1).

---
*Part of the Phase 3: Advanced Prompt Engineering track.*