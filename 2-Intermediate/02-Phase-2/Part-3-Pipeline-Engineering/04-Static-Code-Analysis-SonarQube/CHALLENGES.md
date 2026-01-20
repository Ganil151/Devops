# 🛠️ SonarQube Challenges

## Challenge 1: The Quality Gatekeeper
**Objective**: Enforce standards.
1.  Configure a Quality Gate in the SonarQube UI.
2.  Set the code coverage requirement to **90%**.
3.  Set the "New Code" Vulnerability limit to **0**.
4.  Run a scan on a project with 70% coverage.
5.  Observe how the CI pipeline fails because of the gate violation.

## Challenge 2: Debt Reduction
**Objective**: Clean up technical debt.
1.  Find the "Technical Debt" metric in the SonarQube dashboard (usually in 'Days').
2.  Identify a "Code Smell" (e.g., duplicated code blocks).
3.  Refactor the code into a shared function.
4.  Re-scan and observe the reduction in technical debt.

## Challenge 3: False Positive Whitelist
**Objective**: Dealing with "Hotspots".
1.  SonarQube flags an insecure use of `eval()` in your JavaScript.
2.  Prove that in this specific, isolated case, it is safe.
3.  Use the "Mark as Resolved" (Won't Fix) feature in the UI.
4.  Explain the danger of doing this too often.
