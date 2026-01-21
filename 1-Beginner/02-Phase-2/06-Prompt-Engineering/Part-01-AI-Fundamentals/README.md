# 🟢 Part 1: The AI Mindset

> **"Prompt Engineering is programming in plain English. The compiler is the LLM, and your words are the syntax."**

## 📖 Overview

In this part, we explore the fundamental mechanics of Large Language Models (LLMs). We move beyond simple questions and learn how to construct **Structured Prompts** using proven frameworks. We also build your professional **Prompt Toolkit**—a collection of reusable personas and instructions for daily DevOps tasks.

---

## 🧠 The Context Window

```mermaid
graph LR
    Input[User Input] --> Context[Context Window]
    Context --> System[System Prompt]
    Context --> History[Chat History]
    Context --> RAG[External Data]
    
    Context --> LLM[Model Processing]
    LLM --> Output[Token Generation]
    
    style Context fill:#f9f9f9,stroke:#333
    style LLM fill:#00d2ff,stroke:#333
```

---

## 🎯 Learning Objectives

By the end of this part, you will:

- ✅ Understand **Tokenization** and Context Windows.
- ✅ Master the **Role-Task-Format** prompting strategy.
- ✅ Differentiate between **Zero-Shot** and **Few-Shot** prompting.
- ✅ Build a library of **System Prompts** for Linux, Python, and Cloud tasks.

---

## 🗺️ Included Modules

1. **[01-Foundations-and-Mental-Models](./01-Foundations-and-Mental-Models/README.md)**: How LLMs "think" (probabilities) and how to guide them.
2. **[02-Prompt-Toolkit](./02-Prompt-Toolkit/README.md)**: Your personal library of high-fidelity prompts.

---

## 🎓 Career Readiness

**Interview Question:** "What is the difference between a System Prompt and a User Prompt?"

**Strong Answer:** "The **System Prompt** sets the behavior, tone, and constraints of the AI (e.g., 'You represent a Senior Systems Engineer. Be concise and prefer Bash one-liners.'). The **User Prompt** is the specific request or task (e.g., 'Write a script to backup MySQL'). The System Prompt persists and guides *how* the User Prompt is answered."

---

**Next Step**: Start with **[01-Foundations-and-Mental-Models](./01-Foundations-and-Mental-Models/README.md)** 🚀
