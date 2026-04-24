# GitLab CI Challenges 🦊

Master the integrated DevOps lifecycle with these hands-on GitLab CI/CD lab tasks.

---

## 🏆 Challenge 01: The .gitlab-ci.yml Architect
**Objective**: Build a multi-stage pipeline using the GitLab YAML syntax.

1.  **Requirement**: Create a file named `.gitlab-ci.yml`.
2.  **Specifications**:
    *   **Stages**: Define `build`, `test`, and `deploy`.
    *   **Build Job**: Create a job that "compiles" a dummy file (e.g., `touch output.bin`).
    *   **Test Job**: Create a job that "simulates" a test by printing "Tests passed!".
3.  **Verification**: If using GitLab.com, push the file and check the "CI/CD > Pipelines" menu.

---

## 🏆 Challenge 02: Artifact Passing
**Objective**: Share files between different stages of the pipeline.

1.  **Task**: Modify your `.gitlab-ci.yml`.
2.  **Requirement**: 
    *   The `build` job must define an **artifact** for the `output.bin` file.
    *   The `test` job must verify that `output.bin` exists (e.g., `ls output.bin`).
3.  **Research**: How long do artifacts stay on the GitLab server by default? How do you change this?

---

## 🏆 Challenge 03: Environment Protection
**Objective**: Use GitLab "Environments" to track deployments.

1.  **Task**: Add an `environment` section to your `deploy` job.
2.  **Requirement**:
    *   Name the environment `production`.
    *   Set the URL to `https://prod.example.com`.
3.  **Bonus**: Use the `only: [main]` keyword to ensure the deploy job only runs when code is pushed to the main branch.

---

## 📁 Solutions
Reference templates can be found in the `Boilerplates/` directory.
