# AI Operations (AIOps) Challenges 🤖

Master the intersection of Large Language Models and site reliability engineering.

---

## 🏆 Challenge 01: Chain-of-Thought (CoT) Troubleshooting
**Objective**: Leverage LLMs to solve complex infrastructure puzzles.

1.  **Requirement**: Find a complex error log (e.g., a Kubernetes "CrashLoopBackOff" with cryptic OOMKill details).
2.  **Task**: Draft a "Chain-of-Thought" prompt.
    *   **Phase 1**: Provide context (System specs, environment).
    *   **Phase 2**: Ask for a step-by-step audit of potential causes.
    *   **Phase 3**: Request specific CLI commands to verify each cause.
3.  **Verification**: Compare the LLM's response against your manual research.

---

## 🏆 Challenge 02: Automated Runbook Generator
**Objective**: Convert shell history into professional documentation.

1.  **Scenario**: You just spent 2 hours fixing an Nginx/SSL issue. 
2.  **Requirement**: Provide the shell command history (redacted) to an LLM.
3.  **Task**: Prompt the LLM to generate a **Level 2 Runbook** in Markdown.
4.  **Constraint**: The output must include:
    *   Root Cause Analysis (RCA).
    *   Verification steps.
    *   A "Post-Incident Review" (PIR) summary.
5.  **Refinement**: Ask the LLM to "Rewrite for an intern who has never seen Nginx."

---

## 🏆 Challenge 03: The Agentic DevOps Server
**Objective**: Explore MCP (Model Context Protocol) for tool-use.

1.  **Concept**: Give an AI agent "Permission" to read your local system state safely.
2.  **Task**: Design an "Action Schema" for a tool that lists high-CPU pods in a namespace.
3.  **Security**: Explain the "Guardrail" needed to ensure the AI cannot *delete* resources unless explicitly confirmed by a human.

---

## 📁 Solutions
Prompt templates and MCP action schemas are in the `Boilerplates/` directory.
