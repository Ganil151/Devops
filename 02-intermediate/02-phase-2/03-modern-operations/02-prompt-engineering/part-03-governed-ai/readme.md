# 🔴 Part 3: Governed AI, Parameters & Privacy

> **"AI is a powerful engine. Parameters are the brakes, and Sanitization is the windshield. Without them, you're driving blind."**

## 📖 Overview

In this final intermediate section, we focus on the **Guardrails**. You will learn how to "tune" the AI's internal settings (Temperature, Top-P) to ensure deterministic code generation. We also cover the critical responsibility of **Privacy & Data Redaction**—ensuring that your company's PII and secrets never reach a public model.

---

## 🏗️ Core Concept: Deterministic Generation

Infrastructure-as-Code (IaC) is binary: it either works or it fails. To ensure the AI doesn't "hallucinate" resource names or IP blocks, you must manage its **Temperature**.
- **Temperature 0.0**: Force the model to choose the single most likely token every time.
- **Top-P**: Restrict the model's vocabulary to high-probability options.

---

## 🎯 Learning Objectives

- ✅ Configure **LLM Settings** for specific DevOps tasks (Coding vs. Summarization).
- ✅ Master **PII Redaction** techniques for logs and architecture diagrams.
- ✅ Understand the risks of **Shadow AI** in the workplace.
- ✅ Implement **Prompt Versioning** (PromptOps) in Git.
- ✅ Define a **Sanitization SOP** for the engineering team.

---

## 🗺️ Included Modules

1. **[LLM Settings for Code](./llm-settings-for-code.md)**: Tuning the knobs (Temperature, Top-P, Max Tokens).
2. **[Privacy & Sanitization Guardrails](./privacy-sanitization.md)**: Protecting the company's data.

---

## 🚀 The "Sanitization Sandwich" Pattern

Before prompting for a log analysis:
1.  **Strip**: Replace all real IPs with `10.x.x.x` and all usernames with `USER_ID`.
2.  **Prompt**: Ask the AI to troubleshoot the sanitized log.
3.  **Re-Inject**: After the AI provides the fix, manually re-insert your real IPs/Credentials locally.

---

## 🎓 Career Readiness

**Interview Question:** "Why shouldn't you use 'Temperature 1.0' when asking an AI to write a Kubernetes manifest?"

**Strong Answer:** "Temperature 1.0 encourages randomness and 'creativity.' In Kubernetes manifests, creativity lead to hallucinations—like non-existent API versions or made-up pod labels. For IaC, we need 100% determinism, which is achieved by setting Temperature to 0.0, ensuring the AI consistently provides the most standard and valid configuration."

---

**Next Step**: Learn parameter tuning in **[LLM Settings for Code](./llm-settings-for-code.md)** 🚀
