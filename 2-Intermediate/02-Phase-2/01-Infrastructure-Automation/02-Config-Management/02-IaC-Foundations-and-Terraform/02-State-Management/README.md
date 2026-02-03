# 💾 Terraform State Management

> **"The State File is the single source of truth. If you lose it, you don't have Infrastructure as Code anymore; you just have Infrastructure."**

Welcome to the **State Management** module. This is often the scariest part of Terraform for beginners, but it's the most critical for production success.

## 🛣️ Your Learning Path

This module is re-architected into **4 Logical Parts**, following the lifecycle of state management.

### [📐 Part 1: The Blueprint (Concepts)](./01-Part-1-The-Blueprint/)
*   **Focus**: Understanding the "Why".
*   **Topics**: Why we need state, The danger of Local State, Official Best Practices.
*   **Goal**: Never commit `.tfstate` to Git.

### [⚙️ Part 2: The Engine (Architecture)](./02-Part-2-The-Engine/)
*   **Focus**: Building the Remote Backend.
*   **Topics**: Configuring S3 + DynamoDB, Enabling Locking, Encryption at Rest.
*   **Goal**: Build a "Collaborative Vault" for your team.

### [🧩 Part 3: The Building Blocks (Operations)](./03-Part-3-The-Building-Blocks/)
*   **Focus**: Day-to-Day Manipulations.
*   **Topics**: `state mv` (Refactoring), `state rm` (Forgetting), Migrating Backends.
*   **Goal**: Refactor infrastructure without destroying it.

### [🛡️ Part 4: The Safety Net (Resilience)](./04-Part-4-The-Safety-Net/)
*   **Focus**: Fixing Disasters.
*   **Topics**: Unlocking stuck locks, Recovering from corruption, `terraform_remote_state` data sources.
*   **Goal**: Recover gracefully when things go wrong.

---

## 🚀 How to Use This Module
1.  **Part 1**: Learn the rules.
2.  **Part 2**: Build the secure backend template.
3.  **Part 3**: Practice moving resources in state (safely).
4.  **Part 4**: Learn how to fix "Error: State Locked".

---
**Status**: ✅ Reorganization Complete (2026-02-02)