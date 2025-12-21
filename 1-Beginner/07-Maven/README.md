# Maven & Build Tools

Maven is a build automation tool used primarily for Java projects. It handles dependency management, compilation, and packaging, ensuring that your builds are consistent regardless of the environment.

---

## 1. The Maven Lifecycle

A build lifecycle is a well-defined sequence of phases.
1.  **Validate**: Ensure the project is correct and all information is available.
2.  **Compile**: Convert source code into bytecode.
3.  **Test**: Run unit tests using a suitable framework (e.g., JUnit).
4.  **Package**: Bundle the compiled code into a JAR or WAR.
5.  **Verify**: Run integration tests to ensure quality.
6.  **Install**: Put the package into your local repository.
7.  **Deploy**: Push the final package to a remote repository (e.g., Nexus or Artifactory).

---

## 2. Core Concepts

- **POM (Project Object Model)**: The `pom.xml` file is the heart of a Maven project. It contains configuration, dependencies, and plugins.
- **Dependency Management**: Maven automatically downloads all required libraries and their dependencies.
- **Repositories**:
    - **Local**: On your machine (`~/.m2`).
    - **Central**: Provided by the community.
    - **Remote**: Private company repositories.

---

## 3. Essential Commands
- `mvn clean`: Deletes the `target` directory.
- `mvn compile`: Compiles the source code.
- `mvn package`: Creates the JAR/WAR file.
- `mvn test`: Runs the tests.
- `mvn install`: Installs to your local machine.

---

## 4. Best Practices
1. **Clean first**: Always run `mvn clean` before a major build to avoid stale artifacts.
2. **Version Everything**: Never use `LATEST` or `RELEASE` versions; always pin specific versions for reproducibility.
3. **Keep POMs Clean**: Use `<dependencyManagement>` to control versions in multi-module projects.

---
**Next Step**: Learn how to build these artifacts automatically in the [Basic CI/CD Module](../04-Basic-CI-CD/README.md).