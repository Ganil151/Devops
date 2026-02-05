# 📐 Part 1: The Blueprint (Concepts & Design)

> **"A runbook isn't a book; it's a map. It should tell you exactly where you are and how to get to safety when the alarms are going off."**

Welcome to **Part 1**. This is where we define the standard for operational excellence. We move from "Writing things down" to "Designing for 3:00 AM."

## 🛣️ The Curriculum

### [01-Philosophy-and-Goals](./01-Philosophy-and-Goals/)
**The Objective**: Moving from MTTR (Mean Time to Resolution) to TOIL reduction.
*   **Key Concepts**: The goal of a runbook is its own obsolescence (Automation).

### [02-Documentation-Hierarchy](./02-Documentation-Hierarchy/)
**The Objective**: Knowing the difference between a Policy, an SOP, and a Runbook.
*   **Key Concepts**: High-level vs. Action-level documentation.

### [03-The-SRE-Standard](./03-The-SRE-Standard/)
**The Objective**: Adopting the Google SRE model for docs.
*   **Key Concepts**: Service Level Objectives (SLOs) and how they trigger runbook execution.

### [04-Standard-Templates](./04-Standard-Templates/)
**The Objective**: Consistency as a safety feature.
*   **Key Concepts**: Lowering cognitive load through repeatable layouts.

---

## 🚀 The Difference: Junior vs. Senior

| Feature | Junior Approach | Principal approach |
|:---|:---|:---|
| **Layout** | Writes a long paragraph of text. | Uses checklists and modular sections. |
| **Logic** | Assumes the reader knows the system. | Assumes the reader is stressed and exhausted. |
| **Goal** | "Just document it." | "Document it so we can automate it faster." |

---

## 🛠️ The "3:00 AM Rule"
If a tired engineer cannot follow your runbook at 3:00 AM while production is down, the runbook has failed. Every step must be unambiguous and verifiable.

---
**Status**: ✅ Organized (2026-02-02)
