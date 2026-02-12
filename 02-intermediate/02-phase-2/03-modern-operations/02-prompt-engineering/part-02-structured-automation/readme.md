# 🟡 Part 2: Structured Automation & Operational Context

> **"Intelligence is useless without structure. Few-shot examples and role-based personas turn a generic assistant into a specialized SRE."**

## 📖 Overview

In this section, we master the tools that ensure **Consistency** and **Context**. You will learn how to use **Few-Shot prompting** to teach the AI your company's standards without fine-tuning, and how to use **Role-based personas** to shift the AI's logic into specific domains like Security, FinOps, or Senior Site Reliability Engineering.

---

## 🏗️ Core Concept: Few-Shot Prompting

Few-shot is the practice of providing 2-3 examples of a correct "Input -> Output" pair in the prompt. This solves 90% of formatting and style issues.

**Use cases in DevOps:**
- **Standardizing IaC**: Providing 2 examples of how your team tags AWS resources.
- **Log Summarization**: Providing 1 example of a perfect SRE incident report.
- **Runbook Generation**: Teaching the AI how to format a "Troubleshooting Guide" based on a raw log.

---

## 🎯 Learning Objectives

- ✅ Master **Few-Shot Prompting** for complex data extraction.
- ✅ Implement **Role-Based Personas** (Security Auditor, Cost Architect, Senior SRE).
- ✅ Automate the conversion of **Logs to Runbooks**.
- ✅ Leverage **Slash Commands** for rapid infrastructure response.

---

## 🗺️ Included Modules

1. **[Few-Shot & Role Prompting](./few-shot-and-role-prompting.md)**: Learning by example and persona-shifting.
2. **[Runbook Automation](./runbook-automation.md)**: Turning chaotic logs into structured SOPs.
3. **[Intermediate Slash Commands](./slash-commands-intermediate.md)**: Your operational shorthand library.

---

## 🚀 The "SRE Persona" Pattern

**Structure of a Professional Persona:**
- **Role**: "You are a Senior SRE at a Fortune 500 company."
- **Standard**: "You adhere strictly to Google's SRE Workbook principles."
- **Constraint**: "Prefer simplicity over complex scripts. Always prioritize availability over cost."
- **Outcome**: "Provide a remediation plan that includes rollback steps."

---

## 🎓 Career Readiness

**Interview Question:** "How do you ensure AI-generated Terraform follows your team's specific naming conventions?"

**Strong Answer:** "I use **Few-Shot Prompting**. I include a 'Context' block in my system prompt that contains 2-3 examples of our existing Terraform modules. This teaches the AI our specific variable naming schemes, tagging requirements, and module structures, ensuring every generated file is a 'drop-in' replacement for our existing code."

---

**Next Step**: Learn Few-Shot logic in **[Few-Shot & Role Prompting](./few-shot-and-role-prompting.md)** 🚀
