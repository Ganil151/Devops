# 🏆 Maven Hands-On Challenges

Master Apache Maven by completing these 10 progressive challenges. 

## 🟢 Level: Beginner (Foundations)

### Challenge 01: The First Forge
- **Task**: Install Maven and verify it is using the correct JDK (version 17+ recommended).
- **Goal**: Run `mvn -version` and capture the output.
- **Success Criteria**: Successful output showing Maven version and Java version.

### Challenge 02: Architecture 101
- **Task**: Create the standard Maven directory structure manually for a project named `hello-maven`.
- **Goal**: Create `src/main/java`, `src/main/resources`, `src/test/java`, and a basic `pom.xml`.
- **Success Criteria**: `mvn compile` runs successfully on your empty project.

### Challenge 03: The First Component
- **Task**: Add a simple Java class that prints "Hello DevOps" and a corresponding JUnit test.
- **Goal**: Run the tests using Maven.
- **Success Criteria**: `mvn test` shows "BUILD SUCCESS" and 1 test passed.

---

## 🟡 Level: Intermediate (Management)

### Challenge 04: The Dependency Shield
- **Task**: Add the `Apache Commons Lang` library to your project.
- **Goal**: Use a property for the version number in the `pom.xml`.
- **Success Criteria**: `mvn dependency:tree` shows the library being included.

### Challenge 05: Cleaning the Cache
- **Task**: Intentionally "corrupt" a library in your `~/.m2/repository` by deleting its `.jar` file but leaving the folder.
- **Goal**: Use a Maven command to force a fresh download of that specific library.
- **Success Criteria**: The `.jar` file reappears after running `mvn clean install -U`.

### Challenge 06: Environment Shifting
- **Task**: Create two build profiles: `dev` and `prod`.
- **Goal**: In `dev`, set a property `app.env` to "Development". In `prod`, set it to "Production".
- **Success Criteria**: Run `mvn help:effective-pom -P prod` and verify the property value.

---

## 🔴 Level: Advanced (Orchestration)

### Challenge 07: The Multi-Module Engine
- **Task**: Convert your project into a multi-module project with a `core` module and a `web` module.
- **Goal**: Use a Parent POM to manage versions for both sub-modules.
- **Success Criteria**: Running `mvn clean install` in the parent directory builds all 3 components.

### Challenge 08: Security Gatekeeper
- **Task**: Add the `owasp-dependency-check` plugin to your build.
- **Goal**: Run a security scan on your project.
- **Success Criteria**: A report is generated in `target/dependency-check-report.html`.

### Challenge 09: Dockerized Artifact
- **Task**: Create a multi-stage Dockerfile that builds your Maven project and packages it into a slim JRE image.
- **Goal**: The final image should be under 200MB.
- **Success Criteria**: `docker run` successfully prints your "Hello DevOps" message.

### Challenge 10: The Final Boss - The Zero-Config Pipeline
- **Task**: Create a GitHub Actions workflow (or Jenkinsfile) that:
    1. Triggers on every push.
    2. Runs `mvn clean verify`.
    3. Blocks the merge if tests fail or if security vulnerabilities are found.
- **Goal**: Automate the entire quality gate.
- **Success Criteria**: A "Green Check" on your latest commit indicating a successful automated build.

---

## 💡 Stuck?
- Refer to the [Troubleshooting Guide](./Troubleshooting/README.md).
- Use `mvn -X` to see exactly what is happening under the hood.
- Check the official [Maven Documentation](https://maven.apache.org/guides/index.html).

**Good luck, Architect!**
