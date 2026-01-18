# ♾️ CI/CD Hands-On Challenges

Master Continuous Integration and Deployment by completing these 10 progressive challenges.

## 🟢 Level: Beginner (Workflow Foundations)

### Challenge 01: The First Heartbeat

- **Task**: Create a GitHub repository and initialize it with a `.github/workflows/hello.yml` file.
- **Goal**: Write a workflow that triggers on `push` and prints "The pipeline is alive!" to the logs.
- **Success Criteria**: A green checkmark in the "Actions" tab of your repo.

### Challenge 02: The Automated Tester

- **Task**: Initialize a simple Python or JavaScript project in your repo.
- **Goal**: Add a workflow that installs dependencies and runs `npm test` or `pytest`.
- **Success Criteria**: The pipeline fails if you intentionally break a test, and passes when you fix it.

### Challenge 03: The Linting Gate

- **Task**: Integrate a Linter (like `ESLint` or `ShellCheck`) into your workflow.
- **Goal**: Force the pipeline to fail if there are any formatting errors in your scripts.
- **Success Criteria**: Clean scripts pass; messy scripts are blocked.

---

## 🟡 Level: Intermediate (Management)

### Challenge 04: The Secret Agent

- **Task**: Create a GitHub Secret named `MY_MOCK_API_KEY`.
- **Goal**: Write a step that accesses this secret and prints a masked version of it (e.g., `***`).
- **Success Criteria**: Verify that the actual key value is NEVER visible in the logs.

### Challenge 05: The Matrix Reloaded

- **Task**: Configure a **Matrix Build** for your project.
- **Goal**: Run your tests concurrently on `ubuntu-latest` and `windows-latest`.
- **Success Criteria**: See two parallel jobs running in the GitHub Actions UI.

### Challenge 06: The Artifact Forge

- **Task**: Use the `actions/upload-artifact` action.
- **Goal**: Package your project (e.g., a `.zip` or `.jar`) and save it as a build artifact.
- **Success Criteria**: You can download the artifact directly from the GitHub Actions run page.

---

## 🔴 Level: Advanced (Orchestration)

### Challenge 07: The Dependency Optimizer

- **Task**: Implement **Caching** for your project's dependencies (`node_modules` or `.m2`).
- **Goal**: Compare build times before and after caching.
- **Success Criteria**: The second run of the pipeline should be at least 30% faster.

### Challenge 08: The Security Fortress

- **Task**: Enable **GitHub CodeQL** or integrate **Snyk** into your pipeline.
- **Goal**: Scan your code for vulnerabilities and dependency flaws.
- **Success Criteria**: A security report appears in the "Security" tab of your repository.

### Challenge 09: The CD Switch

- **Task**: Create two environments in GitHub: `Staging` and `Production`.
- **Goal**: Build a workflow that deploys to Staging on every push to `develop` and to Production on every push to `main`.
- **Success Criteria**: Verification of different deployments based on the branch.

### Challenge 10: The Final Boss - The Automated Quality Gate

- **Task**: Design a full "Lights-Out" pipeline that:
    1. Triggers on a Pull Request.
    2. Runs Linting, Unit Tests, and Security Scans.
    3. Blocks the PR from being merged if ANY step fails.
    4. Automatically deploys to a "Preview" environment (e.g., GitHub Pages or a Surge link) for review.
- **Goal**: Create a zero-human-error merge process.
- **Success Criteria**: A fully automated PR process where the human only reviews the logic, not the quality or security.

---

## 💡 Stuck?

- Check the [Foundations Guide](./01-CI-CD-Foundations/README.md).
- Search the [GitHub Marketplace](https://github.com/marketplace?type=actions) for pre-built actions.
- Use the `workflow_dispatch` event to test your pipeline manually without pushing.

**Good luck, Automation Engineer!**
