# Technical Writing Standards for Operations

How you say it matters as much as what you say. Operational writing is a unique skill focused on speed, clarity, and precision.

## The Imperative Mood
Always use direct, active commands. 
- **BAD (Passive)**: "It is often suggested that the logs should be reviewed by the engineer."
- **GOOD (Active)**: "**Review logs** for 'Memory Leak' errors."

## One Thought, One Number
Never combine two unrelated actions in a single step.
- **BAD**: "Step 1: Restart the app and then check the database logs and if the database is down restart it too."
- **GOOD**:
  1. **Restart Application**.
  2. **Verify Application Health**.
  3. **Check Database Connectivity**.

## The Check-and-Response Loop
Every command should be followed by the expected result.
- **Command**: `kubectl get pods`
- **Response**: "All units should show `Running`. If any show `CrashLoopBackOff`, skip to Step 5."

## Visual discoverability
- Use **Bold** for commands or key UI buttons.
- Use `Code Blocks` for all CLI commands.
- Use > [!WARNING] for dangerous steps.

---

## 🏗️ Real-Life Scenario: The Paragraph of Death
**Problem**: An engineer is in the middle of a P0 outage. The SOP is a wall of text: "First you go to the console and find the EC2 dashboard and look for the instance ID then you might want to stop it but make sure you have a backup first but if you don't then call Bob..."
**Outcome**: The engineer misses the "make sure you have a backup" part in the middle of the paragraph. They stop the server, and data is lost forever.
**Fix**: Rewrite the doc using **Atomic Numbered Steps**. 
**Result**: The warning is now impossible to miss at Step 1.

---

## ❓ Interview Questions
1.  **What is the 'Imperative Mood' and why is it preferred for SRE documentation?**
    *   *Answer*: It is an authoritative, direct way of writing (e.g., "Run this command"). It removes ambiguity and doubt, which is critical during the high-stress environment of an incident.
2.  **Explain the concept of 'Visual Discoverability' in technical docs.**
    *   *Answer*: It's the ability for a reader to "scan" a document and find the most important information (commands, warnings, conclusions) without reading every word. This is achieved through formatting like bolding, code blocks, and alerts.

---

## 🧠 Quiz Snippet (5/50+)
1.  **Is 'Check the status' an example of the active or passive mood?** (Active/Imperative)
2.  **True/False: You should use long paragraphs to provide full context.** (False - use atomic steps)
3.  **Which format should be used for CLI commands?** (Code Blocks)
4.  **What is an 'Atomic Step'?** (A single, discrete action that cannot be broken down further)
5.  **Why is formatting like bolding important?** (It increases 'Visual Discoverability')
