# Standard Runbook Templates

Standardization reduces cognitive load. When every runbook looks the same, your brain knows exactly where to find the answers.

## The "Emergency" Template (Markdown)

```markdown
# RB-[Category]-[ID]: [Brief Title]

## 🚨 Alert Context
- **Condition**: [Describe the problem]
- **Alert Link**: [Link to Monitoring]
- **Severity**: [P0 / P1 / P2]

## 🛠️ Prerequisites
- **Access**: [e.g. AWS Admin]
- **Tools**: [e.g. kubectl, ssh]

## 🏃 Runbook Steps
1. [Condition Check]: Run `command_here`
2. [Expected Output]: You should see `X`
3. [Decision]: If you see `Y`, skip to Step 5.

## ✅ Verification
- Run `check_status.sh` to confirm resolution.

## ⏪ Rollback
- To undo these changes, run `rollback.sh`.
```

## Consistency Checklist
- [ ] Uses clear, active verbs ("Run", "Check", "Stop").
- [ ] No long paragraphs of text. Use bullet points.
- [ ] Version and Owner are clearly marked at the top.
- [ ] All code blocks are copy-pasteable (no screenshots of code).

---

## 🏗️ Real-Life Scenario: The Format Chaos
**Problem**: An SRE team has 100 runbooks. Some are in Google Docs, some in Word, some in Markdown. Some start with the "Fix," others start with "History."
**Crisis**: During a critical outage, an engineer spends 2 minutes searching for the "Prerequisites" because they are at the bottom of the document instead of the top.
**Outcome**: The team adopts a "Single Markdown Template" enforcement via a pre-commit hook. 
**Result**: Engineers find the information 50% faster because their brains are "Retrained" on the new consistent layout.

---

## ❓ Interview Questions
1.  **Why should we avoid screenshots of code in runbooks?**
    *   *Answer*: They are not copy-pasteable (slows down the engineer), they cannot be searched via text search (Ctrl+F), and they are hard to read for people with visual impairments or on mobile devices.
2.  **What is the benefit of a naming convention like `RB-NET-01`?**
    *   *Answer*: It allows for easy categorization, fast searching in a wiki, and links the document to a specific sub-team (e.g., `NET` for Networking).

---

## 🧠 Quiz Snippet (5/50+)
1.  **Which section tells you the severity of the problem?** (Alert Context)
2.  **True/False: Runbooks should be written in conversational, poetic language.** (False - use short, active verbs)
3.  **What tool can enforce a documentation template?** (Linter or Pre-commit hook)
4.  **Should 'Expected Output' be a screenshot or text?** (Text)
5.  **Is 'RB-01' a better name than 'How to fix the network'?** (Yes - it's standardized and searchable)
