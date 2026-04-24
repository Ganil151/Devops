# Static Code Analysis Challenges (SonarQube) 🛡️

Shift-left your security and quality by analyzing code before it is compiled.

---

## 🏆 Challenge 01: The Quality Gate Architect
**Objective**: Define the "Minimum Bar" for merge-readiness.

1.  **Requirement**: Log into a SonarQube / SonarCloud instance.
2.  **Task**: Create a custom **Quality Gate**.
3.  **Conditions**:
    *   **Coverage**: Must be > 80%.
    *   **Bugs**: Must be 0.
    *   **Vulnerabilities**: Must be 0 Grade A.
4.  **Action**: Assign this Quality Gate to a Python project.

---

## 🏆 Challenge 02: Pipeline Integration (The Wait Step)
**Objective**: Block deployments if code quality is poor.

1.  **Scenario**: You have a Jenkins pipeline that runs SonarQube analysis.
2.  **Task**: Add the `waitForQualityGate` step to your `Jenkinsfile`.
3.  **Logic**: Configure the webhook in SonarQube to notify Jenkins when the scan is finished.
4.  **Verification**: Intentionally write "Bad Code" (e.g., hardcoded passwords or unused imports) and verify the pipeline fails at the "Gate" stage.

---

## 🏆 Challenge 03: The Technical Debt Audit
**Objective**: Prioritize refactoring based on data.

1.  **Task**: Scan a medium-sized project using the `sonar-scanner`.
2.  **Analysis**: 
    *   Identify the `Maintainability` rating.
    *   Identify the `Technical Debt` (expressed in days).
3.  **Goal**: Pick the top 5 "Code Smells" and document why resolving them improves the long-term reliability of the system.

---

## 📁 Solutions
Sonar-scanner shell commands and Jenkins Pipeline snippets are in the `Boilerplates/` directory.
