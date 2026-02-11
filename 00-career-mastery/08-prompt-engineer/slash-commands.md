# ⌨️ Slash Commands & Prompt Shorthands

## Overview
Speed up your AI interactions using these "Standard Operating Procedures." Instead of writing long explanations, use these shorthands to get the exact output format you need.

---

## 🚀 The Rapid Interaction Library

| Command | Action | AI Interpretation |
|:--- |:--- |:--- |
| **`/human`** | De-robotize | "Write this like a real person. Remove 'tapestry', 'delve', 'crucial', and AI-isms. Keep it punchy and authentic." |
| **`TLDR` (DLTR)** | Summarize | "Give me a 3-bullet executive summary of the following content. Focus on high-level impact." |
| **`ELI5`** | Simplify (Junior) | "Explain this technical concept to a 5-year-old using a playground analogy." |
| **`ELI10`** | Simplify (Mid) | "Explain this architectural concept to a 10-year-old using a LEGO or City-building analogy." |
| **`LISTIFY`** | Structure | "Convert this block of text into a clean, bulleted list with bold headers for each point." |
| **`TABULIFY`** | Comparison | "Convert this text into a Markdown table with columns for: Component, Purpose, and Trade-off." |
| **`STEPIFY`** | Workflow | "Convert this objective into a numbered, step-by-step technical SOP/Runbook." |
| **`AUDIT`** | Review | "Scan this for 'Senior Red Flags'. Highlight anything that sounds defensive, vague, or junior." |
| **`CODEONLY`** | Clean Code | "Provide ONLY the code/manifest. No intro text, no 'Here is your code', no closing remarks." |
| **`REFACTOR`** | Clean Logic | "Improve the readability and efficiency of this code without changing its core behavior." |

---

## 💡 How to Use These

### Option A: The "Direct Command"
Simply paste your text followed by the code.
> *[Pasted Job Description]*  
> **TLDR**

### Option B: The "Instructional Prefix"
Start your prompt with the command to set the tone early.
> **`/human`** write a cold outreach email to a hiring manager at AWS based on my resume below...

### Option C: The "Refinement"
After getting a response that is too "AI-heavy," simply reply with:
> **`/human`** make it punchier and remove the fluff.

---

## 🎯 Pro Tip: The "SRE Touch"
In DevOps, we value **Signal over Noise**. Use `CODEONLY` + `TABULIFY` when reviewing infrastructure changes to get clean, data-driven comparisons without the conversational filler.

---
*This guide is part of the 08-prompt-engineer arsenal.*
