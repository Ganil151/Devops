# 🦅 Staff-Level AI Slash Commands & High-Context Codes

## 🚀 Overview
At the Advanced stage, shorthands move from simple "formatting" to **Architectural Guidance** and **Agentic Priming**. These commands are designed to get high-fidelity, production-grade logic from LLMs like Claude 3.5 Sonnet or GPT-4o.

---

## 🛠️ The Architectural SOP Library

| Command | Action | AI Reasoning Strategy (Internal Logic) |
|:--- |:--- |:--- |
| **`/architect`** | Design Review | "Analyze this requirement for (Scalability, Security, Cost). Provide a technical design doc with Mermaid diagrams and 3 trade-off scenarios." |
| **`/red-team`** | Security Audit | "Act as a malicious actor. Find 5 non-obvious vulnerabilities in this architecture/script. Score them by CVSS and suggest mitigations." |
| **`/rca-expert`** | Root Cause | "Ingest these logs/traces. Correlate them with the provided Git diff. Identify the exact line or config change that caused the outage." |
| **`/refactor-staff`**| Clean Code | "Apply Clean Code and SOLID principles. Remove redundancy. Ensure proper error boxing, logging, and observability instrumentation."|
| **`/prompt-chain`** | Decomposition | "Break this complex goal into 5 smaller, verifiable sub-tasks for an agentic planner. Include success criteria for each step." |
| **`/finops-audit`** | Cost Review | "Analyze this cloud bill/manifest. Identify 'Orphaned' resources and provide the exact CLI commands to safely delete them." |

---

## 🏗️ Reasoning Shorthands (Agent Hooks)

| Code | Action | Focus |
|:--- |:--- |:--- |
| **`CO-THOUGHT`** | Deep Logic | Force the AI to output its hidden internal "Thinking" block before providing the final answer. |
| **`VERIFY`** | Fact-Check | "For every technical claim/command made, prove its existence in the latest official provider documentation." |
| **`GUARDRAILS`** | Safety | "List all potential side effects and 'Blast Radius' concerns for the generated solution." |
| **`SANDBOX`** | Isolation | "Structure this code to run inside an ephemeral container. Include the Dockerfile and health-check logic." |
| **`SCHEMIFY`** | Protocol | "Output ONLY valid JSON according to this schema. No natural language. No preamble." |

---

## 🧠 Example: Staff-Level Chaining

**Scenario: Emergency Cloud Restoration**
> *[Pasted Error Log]*  
> **`/rca-expert`** then **`CO-THOUGHT`** the fix then **`/red-team`** the fix then **`CODEONLY`** the final restoration script.

---

## 🎯 Pro-Tips for Advanced Workflows

1. **Strategic Constraints**: Instead of saying "Don't do X," say "Adhere to ISO 27001 compliance standards." This forces the AI to use professional-grade logic.
2. **Context Injection (RAG-Lite)**: Use the command: *"Context: Review this based on our internal 'Incindent-084-Postmortem' findings below..."* to prevent repeat failures.
3. **The 'Why' Requirement**: Always end your prompt with: *"Explain the 'Pros' and 'Cons' for this approach compared to a Serverless alternative."*

---
*This guide is part of Part 1: Agentic Architecture in the Advanced Prompt Engineering Curriculum.*
