# Secret Scanning Challenges (TruffleHog) 🐷

Protect your organization by preventing sensitive data from ever reaching your repository.

---

## 🏆 Challenge 01: The Repository Audit
**Objective**: Scan a project for historical secrets.

1.  **Requirement**: Choose a public or private repo (be careful with credentials!).
2.  **Task**: Run TruffleHog against the entire Git history.
3.  **Command**: `trufflehog git file:///path/to/repo --only-verified`.
4.  **Discovery**: Identify if any API keys or Private Keys (`PEM` files) exist in the commit history (even if they were deleted later).

---

## 🏆 Challenge 02: Pre-Commit Prevention
**Objective**: Stop secrets *before* they are committed.

1.  **Task**: Install the `pre-commit` framework.
2.  **Logic**: Configure a `.pre-commit-config.yaml` to run TruffleHog locally.
3.  **Experiment**: Intentionally add a dummy AWS key (e.g., `AKIA...`) to a text file and try to run `git commit`.
4.  **Verification**: Confirm that the commit is **REJECTED** until the key is removed.

---

## 🏆 Challenge 03: CI/CD Integration
**Objective**: Build a persistent secret-gate in your pipeline.

1.  **Scenario**: You want to ensure no developer ever pushes a secret to the `main` branch.
2.  **Task**: Add a "Secret Scan" stage to your Jenkinsfile or GitHub Action.
3.  **Policy**: Set the pipeline to **Fail** (Exit Code 1) if a secret is found.
4.  **Action**: Research how to "Allow List" a false positive (e.g., a test key that is not actually sensitive).

---

## 📁 Solutions
Pre-commit configurations and TruffleHog docker commands are in the `Boilerplates/` directory.
