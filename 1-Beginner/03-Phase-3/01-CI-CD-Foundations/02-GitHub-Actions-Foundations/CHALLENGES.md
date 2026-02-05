# Refined GitHub Actions Challenges ⚡

Elevate your automation skills from basic scripts to professional CI/CD orchestration.

---

## 🏆 Challenge 01: The Matrix & Cache Strategy
**Objective**: Build a high-performance, multi-version test suite.

1.  **Task**: Create `.github/workflows/optimized-ci.yml`.
2.  **Requirements**:
    *   **Matrix**: Run on `3.9`, `3.10`, and `3.11` versions of Python.
    *   **Caching**: Enable caching in your `setup-python` step to store `pip` dependencies.
3.  **Verification**: Run the workflow twice. The second run should be significantly faster as it "reclaims" the cache.

---

## 🏆 Challenge 02: Artifact Orchestration
**Objective**: Build once, deploy everywhere.

1.  **Requirement**: Two jobs: `Build` and `Deploy`.
2.  **Logic**:
    *   **Build Job**: Create a mock artifact (e.g., `echo "Build v1.0" > build.txt`) and use `actions/upload-artifact` to save it.
    *   **Deploy Job**: Must `need` the Build job. Use `actions/download-artifact` to retrieve `build.txt` and print its contents.
3.  **Goal**: Understand how to safely pass data between isolated runner machines.

---

## 🏆 Challenge 03: Environment Protection & Secrets
**Objective**: Simulate a production-grade deployment gate.

1.  **Setup**:
    *   In your GitHub Repo: Go to **Settings > Environments** and create one named `Production`. 
    *   Add a "Required Reviewer" (yourself) to this environment.
2.  **Task**: Create a workflow that uses `environment: Production`.
3.  **Logic**:
    *   Add a step that prints "Deploying to Production...".
4.  **Verification**: Trigger the workflow. It should "Pause" and wait for you to click "Approve" before finishing.

---

## 🏆 Challenge 04: The Custom Composite Action
**Objective**: Encapsulate reusable logic.

1.  **Task**: Create a local composite action in `.github/actions/hello-world/action.yml`.
2.  **Requirement**: The action should take an input `who-to-greet` and run a shell script to print "Hello [name]".
3.  **Goal**: Call this local action from your main CI workflow.

---

## 📁 Solutions
Templates and examples for these advanced patterns are available in the `Boilerplates/` directory.
