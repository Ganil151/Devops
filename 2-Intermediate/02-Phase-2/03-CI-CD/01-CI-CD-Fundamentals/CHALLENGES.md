# 🛠️ CI/CD Fundamentals Challenges

## Challenge 1: The Pipeline Designer
**Objective**: Diagram a complex workflow.
1.  Draw a Mermaid diagram for a mobile app deployment.
2.  Include stages for: Linting, Unit Tests, UI Tests (BrowserStack), Play Store Upload, and a Manual Approval for Production.
3.  Ensure the "UI Tests" and "Security Scan" happen in parallel to save time.

## Challenge 2: Exit Code Awareness
**Objective**: Understand how CI servers detect failure.
1.  Modify the `ci_cd_skeleton.sh` boilerplate.
2.  Introduce a command that purposefully fails (e.g., `grep "error" non_existent_file.txt`).
3.  Observe how the script stops immediately because of the `set -e` flag. 
4.  Why is this crucial for CI/CD?

## Challenge 3: Deployment Strategies
**Objective**: Compare strategies.
1. Define the difference between a **Blue-Green** deployment and a **Canary** deployment.
2. In which scenario would you prefer Blue-Green over Canary?
3. What is "Drift" in the context of infrastructure deployment?
