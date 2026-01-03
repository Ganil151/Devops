# Maven & Build Tools

Maven is a build automation tool used primarily for Java projects. It handles dependency management, compilation, and packaging, ensuring that your builds are consistent regardless of the environment.

---

## 🎯 Learning Objectives

- Understand the Maven Build Lifecycle phases
- Manage dependencies and resolve conflicts
- Package applications into JARs/WARs
- Use Maven profiles for environment management
- Debug build issues with dependency trees

## 📖 The Maven Lifecycle

A build lifecycle is a well-defined sequence of phases.
1.  **Validate**: Ensure the project is correct and all information is available.
2.  **Compile**: Convert source code into bytecode.
3.  **Test**: Run unit tests using a suitable framework (e.g., JUnit).
4.  **Package**: Bundle the compiled code into a JAR or WAR.
5.  **Verify**: Run integration tests to ensure quality.
6.  **Install**: Put the package into your local repository.
7.  **Deploy**: Push the final package to a remote repository (e.g., Nexus or Artifactory).

---

## 🏗️ Essential Maven Commands

### 🚦 The Core Workflow
*When to use: The standard cycle for building and testing your Java application.*

```bash
# Clean the project and package into a JAR
mvn clean package

# Run all unit tests
mvn test

# Install the artifact to your local ~/.m2 repository
mvn install

# Skip tests for a faster build (Use with caution!)
mvn package -DskipTests
```

### 🔍 Debugging and Inspection
*When to use: Investigating dependency conflicts or viewing the project structure.*

```bash
# Show the dependency tree (Find version conflicts!)
mvn dependency:tree

# Show what the final POM looks like after inheritance
mvn help:effective-pom

# Check for newer versions of your dependencies
mvn versions:display-dependency-updates
```

---

## 💡 Maven Best Practices

- **Clean first**: Always run `mvn clean` before a major build or release to ensure no leftover files from previous builds interfere with the current one.
- **Dependency Pinning**: Never use `LATEST` or `RELEASE` versions for dependencies. This makes builds unpredictable. Always use specific version numbers.
- **Scope Your Dependencies**: Use `<scope>test</scope>` for libraries like JUnit that aren't needed in production. This keeps your final artifact small.
- **Use the Wrapper**: Use `mvnw` (Maven Wrapper) so team members can run builds without manually installing a specific Maven version.
- **Profile for Environments**: Use Maven **Profiles** to define different configurations for `dev`, `test`, and `prod`.

---

## 🧪 Practical Labs

### Lab 1: The "No Class Def Found" Nightmare
**Scenario**: Your app compiles fine, but fails at runtime with `ClassNotFoundException`.
**Task**: Find the missing or conflicting dependency.
**Solution**:
1.  **Analyze**: Run `mvn dependency:tree` to see the full list of jars.
2.  **Identify**: Look for version conflicts or `<scope>provided</scope>` libraries that should be runtime.
3.  **Fix**: Add an `<exclusion>` or update the version in `pom.xml`.

### Lab 2: Stale Build Artifacts
**Scenario**: You changed your code, but the `mvn package` seems to be using an old version of a class.
**Task**: Force a clean build.
**Solution**:
1.  **Command**: Run `mvn clean package`.
2.  **Why**: The `clean` phase deletes the `target/` directory, ensuring no old cached classes remain.

## 🧠 Knowledge Quiz

**1. Which file is the primary configuration file for a Maven project?**
- A) `package.json`
- B) `pom.xml`
- C) `build.gradle`
- D) `maven.config`

**2. What does the `mvn dependency:tree` command help you identify?**
- A) The physical location of the project on disk
- B) A visual map of all direct and transitive dependencies (useful for finding conflicts)
- C) The history of the Git repository
- D) The number of lines of code in the project

**3. In which Maven phase are unit tests typically executed?**
- A) `compile`
- B) `package`
- C) `test`
- D) `install`

---

## ✅ Knowledge Check
- [ ] Understand the Maven Build Lifecycle
- [ ] Read and modify a `pom.xml` file
- [ ] Resolve dependency conflicts using `mvn dependency:tree`
- [ ] Package an application into a JAR/WAR file
- [ ] Use the Maven Wrapper (`mvnw`) for portability

---
**Next Step**: Learn how to build these artifacts automatically in the [Basic CI/CD Module](../08-Basic-CI-CD/README.md).