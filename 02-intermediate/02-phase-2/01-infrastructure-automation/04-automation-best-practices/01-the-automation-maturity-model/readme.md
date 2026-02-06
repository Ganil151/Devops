# The Automation Maturity Model

Not all automation is created equal. The Maturity Model helps teams evaluate where they are and identifies the technical gaps they need to close to reach "Elite" status (SRE Standard).

## 📚 Module Structure
- **[Boilerplates](readme.md)**: `maturity_scorecard.txt` (Self-assessment tool).
- **[CHALLENGES](./challenges.md)**: Auditing a legacy script into Level 3.

---

## 📈 The 5 Levels of Automation

| Level | Name | Characteristics | Goal |
| :--- | :--- | :--- | :--- |
| **1** | **Manual** | Wiki pages, "Copy-Paste" commands, human error. | Kill the Wiki. |
| **2** | **Scripted** | Individual scripts (Bash/Python). No uniform error handling. | Kill the manual trigger. |
| **3** | **Integrated** | Orchestrated by CI/CD (GitHub Actions/Jenkins). Parameters used. | Kill fixed environment dependency. |
| **4** | **Observed** | Structured logging, metrics, alerting on script failure. | Kill silent failures. |
| **5** | **Autonomous** | Event-driven self-healing. Loop between monitoring and automation. | Kill the 3 AM wake-up call. |

---

## 🏗️ Technical Pillars of Level 4+
To move beyond basic scripting (Level 2), your automation must include:
1.  **Observability**: External logs that show *why* it failed.
2.  **Safety Guards**: Pre-flight checks and Dry-run flags.
3.  **Idempotency**: The ability to run the script against a half-finished state and fix it.

---

## 📖 Real-World Story: The "Black Box" script

**Scenario**: A company had a Level 2 script that cleared cache. It ran every night via Cron.
**Problem**: One night the script failed due to a permissions change. Because it had no logging (Level 2), no one knew.
**Crisis**: The site became slow over 3 days as the cache ballooned. The SRE team spent 6 hours debugging "Slow DB" when it was actually the cache script.
**Resolution**: Upgraded the script to Level 4 by adding structured JSON logging and a heartbeat alert.
**Result**: The next failure was detected and fixed in 2 minutes.

---

## ❓ Interview Questions

1. **What is the main difference between Level 2 (Scripted) and Level 3 (Integrated)?**
   - *Answer*: Level 3 is moved into a centralized pipeline (CI/CD) and accepts dynamic parameters, whereas Level 2 is often run manually from a developer's laptop.
2. **Why is 'Level 5' (Autonomous) dangerous without 'Level 4' (Observability)?**
   - *Answer*: If an autonomous script starts making changes (Self-healing) but you can't see what it's doing, it can create a "Feedback Loop" and destroy your infrastructure faster than any human.
3. **How do you move a team from Level 1 to Level 2?**
   - *Answer*: By standardizing manual processes into a single Git-tracked script and removing the "Human-in-the-loop" for the actual execution.

---

[Next: Idempotency Patterns](../02-idempotency-patterns-check-act-verify/readme.md)