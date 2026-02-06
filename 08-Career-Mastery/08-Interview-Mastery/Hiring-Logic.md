# Hiring and Interviews

## Getting the Job
Hiring managers don't just look for "Terraform experts." We look for engineers who can **learn**, **solve problems**, and **finish tasks**.

---

## 1. What Managers Look For
We hire for **Potential + Aptitude**.

| The Trait | How to Show It |
| :--- | :--- |
| **Curiosity** | Side projects, blogs about what you learned, trying new tools. |
| **Grit (Persistence)** | A GitHub repo with many commits showing the struggle and the fix. |
| **Communication** | clear READMEs, well-commented code, articulate interview answers. |

---
## 2. The Portfolio (GitHub Presence)
Your GitHub is your resume. It doesn't need 1,000 green squares, but it needs **Quality**.

### The "Deployable" Standard
A recruiter should be able to clone your repo and run it.
*   **Cleanliness:** Remove `.DS_Store` and temporary files (use `.gitignore`).
*   **Structure:** Logical folder names (`src`, `docs`, `tests`).
*   **The README:**
    *   Title & Description.
    *   "How to Run" section.
    *   "Architecture" diagram.
    *   "Lessons Learned" section (Gold for interviews!).

### Is my Repo ready? (The Checklist)
- [ ] Does the README explain *what* this is?
- [ ] Are secrets (API Keys/Passwords) removed? **(CRITICAL FAILURE if present)**
- [ ] Is the code readable (formatting/linting)?
- [ ] Is there a diagram?

---
## 3. The Technical Interview
It's rarely a trivia quiz. It's a logic test.
### The "Whiteboard" Challenge
**Question:** "Design a scalable web application on AWS."

**How to Answer:**
1.  **Clarify Requirements:** "How much traffic? Do we need a database?"
2.  **Draw the Flow:** Load Balancer -> Web Server -> Database.
3.  **Identify Bottlenecks:** "What if the DB fails? Let's add a replica."

### Common "Junior" Interview Questions
1.  *What happens when you type google.com into a browser?* (DNS, Networking, HTTP).
2.  *Explain CI/CD to a 5-year-old.*
3.  *How would you troubleshoot a server you can't SSH into?*
4.  *Tell me about a time you broke production.* (Honesty test!).

---
## 4. Red Flags to Avoid
*   **"It works on my machine."** (Shows lack of awareness of environments).
*   **Hiding mistakes.** (We need transparency).
*   **Defensiveness.** (Accept feedback gracefully).
*   **Empty GitHub Repos** linked in a resume.

## Final Advice
> "We can teach you syntax. We cannot teach you curiosity."
