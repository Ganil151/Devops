# 📦 Terraform Modules & Composition

> **"Don't Repeat Yourself (DRY). If you copy-paste the same S3 bucket config 10 times, you have 10 places to make a mistake. Use Modules."**

Welcome to the **Modules** module. This is where you graduate from "Code Writer" to "Library Maintainer."

## 🛣️ Your Learning Path

This module is re-architected into **4 Logical Parts**, mirroring the lifecycle of module development.

### [📐 Part 1: The Blueprint (Concepts)](./01-part-1-the-blueprint/)
*   **Focus**: Understanding the Architecture.
*   **Topics**: What is a Module? The Standard File Layout, Interface Design (Inputs/Outputs).
*   **Goal**: Design modules that are easy to use.

### [⚙️ Part 2: The Engine (Creation)](./02-part-2-the-engine/)
*   **Focus**: Writing the Code.
*   **Topics**: Creating your first module, calling child modules, "Composition" (combining small blocks).
*   **Goal**: Refactor a monolith `main.tf` into clean modules.

### [🧩 Part 3: The Building Blocks (Distribution)](./03-part-3-the-building-blocks/)
*   **Focus**: Sharing with the Team.
*   **Topics**: The Terraform Registry, Private Registries, Semantic Versioning (v1.0.0).
*   **Goal**: Release stable versions of your modules.

### [🛡️ Part 4: The Safety Net (Testing)](./04-part-4-the-safety-net/)
*   **Focus**: Quality Assurance.
*   **Topics**: Terratest, Examples as Tests, Refactoring Strategies.
*   **Goal**: Verify your module works before anyone else uses it.

---

## 🚀 How to Use This Module
1.  **Part 1**: Learn the structure.
2.  **Part 2**: Build a generic "S3 Bucket" module.
3.  **Part 3**: Learn how to tag it `v1.0` and consume it in another project.
4.  **Part 4**: Write a test to ensure the bucket is actually private.

---
**Status**: ✅ Reorganization Complete (2026-02-02)