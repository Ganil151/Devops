# Jenkins Intermediate Challenges 🏗️

Master the advanced orchestration techniques that power enterprise Jenkins instances.

---

## 🏆 Challenge 01: The Shared Library Architect
**Objective**: Eliminate code duplication with Jenkins Shared Libraries.

1.  **Scenario**: Your company has 50 repos that all use the same "Slack Notification" logic.
2.  **Task**: Create a Groovy library structure:
    ```text
    vars/
      sendSlackNotification.groovy
    ```
3.  **Logic**: The script should take `status` (Success/Fail) and `channel` as parameters.
4.  **Goal**: Import this library into a `Jenkinsfile` using `@Library('my-global-library') _` and call the command.

---

## 🏆 Challenge 02: Dynamic Agent Orchestration
**Objective**: Reduce infrastructure costs by using "Ephemeral" agents.

1.  **Requirement**: Configure the **Docker Pipeline Plugin**.
2.  **Task**: Modify your `Jenkinsfile` to run different stages in different containers.
    *   **Build Stage**: Run in a `maven:3.8-openjdk-11` container.
    *   **Security Stage**: Run in a `aquasec/trivy` container.
3.  **Observation**: Verify that Jenkins spins up the container, runs the script, and deletes the container automatically.

---

## 🏆 Challenge 03: Multibranch Pipelines & Scans
**Objective**: Automate the automation for every Git branch.

1.  **Task**: Set up a **Multibranch Pipeline** item in Jenkins.
2.  **Logic**: Point it to a GitHub Repo with multiple branches (`main`, `dev`, `feature/xxx`).
3.  **Requirement**: Ensure that a build is triggered for every branch *automatically* when code is pushed.
4.  **Security**: Configure "Branch Protection" so that only successful Jenkins builds allow a merge to `main`.

---

## 📁 Solutions
Shared Library templates and ephemeral container snippets are in the `Boilerplates/` directory.
