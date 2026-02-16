# Pipelines-as-Code Challenges 🧩

Master the Declarative Pipeline syntax by completing these real-world lab tasks.

---

## 🏆 Challenge 01: The Multi-Stage Architect
**Objective**: Create a `Jenkinsfile` that incorporates specialized stages and error handling.

1.  **Task**: Create a new file named `Lab.Jenkinsfile`.
2.  **Requirements**:
    *   Initialize an environment variable `VERSION = '1.0.0'`.
    *   Include three stages: `Build`, `Static Analysis`, and `Archive`.
    *   In the `Archive stage`, use a simple `echo` to simulate uploading an artifact.
    *   Add a `post` block that prints "Lab Complete" only on success.

---

## 🏆 Challenge 02: Parallel Execution
**Objective**: Optimize pipeline speed using parallel stages.

1.  **Task**: Modify your `Lab.Jenkinsfile`.
2.  **Requirements**:
    *   Put `Unit Tests` and `Linting` into a `parallel` block within a single `Test` stage.
    *   Ensure that if the `Linting` stage fails, the entire pipeline stops.

---

## 🏆 Challenge 03: Plugin Power (The Dashboard)
**Objective**: Enhance Jenkins visibility with modern plugins.

1.  **Task**: (Simulated) Install and configure a plugin.
2.  **Requirements**:
    *   If you have a local Jenkins instance, install the **Blue Ocean** plugin.
    *   Switch to the Blue Ocean UI and run your `Lab.Jenkinsfile`.
    *   **Question**: What is the primary visual difference between the classic UI and Blue Ocean for parallel stages?

---

## 📁 Solutions
You can find example solutions in the `challenges/` directory (e.g., `solutions_lab.Jenkinsfile`).
