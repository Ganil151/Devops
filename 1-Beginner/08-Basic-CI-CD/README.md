# Basic CI/CD: The Foundation of Fast Delivery

CI/CD stands for Continuous Integration and Continuous Delivery (or Deployment). For a beginner, this is the process of automating the testing and shipping of your code so you don't have to do it manually every time.

---

## � Learning Objectives
- Understand the difference between CI and CD
- Design a basic CI/CD pipeline
- Implement automated linting and testing
- Troubleshoot failed builds using logs
- Secure pipelines with secrets management



## 📖 Essential CI/CD Pipeline Stages
Every modern pipeline follows a structured set of steps to ensure code quality and safety.

1.  **Checkout**: The runner pulls the latest code from Git.
2.  **Linting**: Tools like `ESLint`, `Pylint`, or `ShellCheck` look for syntax errors and style violations.
3.  **Unit Testing**: Automated tests (e.g., `Jest`, `PyTest`) verify that individual pieces of code work correctly.
4.  **Security Scanning**: Tools like `Snyk` or `Trivy` check for vulnerable dependencies or hardcoded secrets.
5.  **Build**: The code is compiled or packaged into an artifact (e.g., a Docker image).
6.  **Deploy**: The artifact is sent to a server or cloud provider (e.g., AWS, Heroku).

---

## 🏗️ Essential CI/CD Context

### 🚀 GitHub Actions Basics
*When to use: The default choice for projects hosted on GitHub. It's free for public repos and easy to set up.*

```yaml
# A simple workflow example (.github/workflows/main.yml)
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run a one-line script
        run: echo Hello, CI/CD world!
```

---

## 💡 CI/CD Best Practices
- **Automate Early**: Don't wait for your project to be "finished." Start with a simple pipeline that just runs one test or linter.
- **Fail Fast**: Put the fastest tests (Linting/Unit Tests) at the beginning of the pipeline. If they fail, you shouldn't waste time building images.
- **Keep it Fast**: Your CI pipeline should provide feedback in minutes. If it takes hours, developers will start ignoring it.
- **Immutable Artifacts**: Once a package is built (e.g., `my-app-v1.0.0.zip`), never change it. Deploy that *exact* same version from Staging to Production.
- **Fail Clearly**: Ensure your pipeline logs are easy to read. If a build fails, it should be obvious whether it was a code error, a test failure, or a network issue.

---

## 🧠 Training & Assessment

## 🧪 Practical Labs

### Lab 1: The "It Works on My Machine" Build Failure
**Scenario**: Your tests pass locally, but the CI pipeline fails.
**Task**: align environments.
**Solution**:
1.  **Check Version**: Validate Node/Python versions match.
2.  **Dependencies**: Check `package.json` lockfiles.
3.  **Secrets**: Ensure keys exist in CI environment variables.

### Lab 2: Flaky Tests
**Scenario**: The pipeline sometimes passes and sometimes fails without any code changes.
**Task**: Isolate the test environment.
**Solution**:
1.  **Mocking**: Don't call real external APIs in unit tests.
2.  **Concurrency**: Ensure unique IDs for database records.

## 🧠 Knowledge Quiz

**1. What is the primary purpose of Continuous Integration (CI)?**
- A) To automatically deploy code to production
- B) To frequently integrate code changes and verify them with automated tests
- C) To write documentation for the code
- D) To manage project budgets

**2. What is a "Build Artifact"?**
- A) An ancient piece of code no one understands
- B) The final packaged version of your app (e.g., .jar, .zip, .exe) ready for deployment
- C) A bug that has been in the system for years
- D) A temporary log file

**3. If a pipeline's "Lint" stage fails, what should happen?**
- A) The pipeline should continue to the "Deploy" stage
- B) The developer should be fired
- C) The pipeline should stop immediately and notify the developer
- D) The linting errors should be automatically ignored

---

## ✅ Knowledge Check
- [ ] Define the difference between CI and CD
- [ ] Understand the concept of a Pipeline and its stages
- [ ] Create a "Hello World" GitHub Actions workflow
- [ ] Identify common artifacts (Docker images, Zip files)
- [ ] Troubleshoot a failed build using logs

---

**Next Step**: Learn how to scale these pipelines for enterprise applications in the [Intermediate CI/CD Module](../../2-Intermediate/05-CI-CD/README.md).
