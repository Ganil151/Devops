# Dependency Resolution & Governance Reference

**Doc Version:** 1.0.0
**Role:** Senior Build Engineer
**Scope:** Transitive Dependencies, Mediation, and Scopes

---

## 1. The Dependency Graph

Maven dependencies are not a flat list; they are a tree.
- **Direct Dependencies:** Libraries you explicitly list in `pom.xml`.
- **Transitive Dependencies:** Libraries your dependencies need.

### The Problem: Dependency Hell
If Project A depends on `Log4j 1.x` and Project B depends on `Log4j 2.x`, your application now sees conflicting classes.

---

## 2. Mediation Strategy: Nearest Definition Wins

When conflict arises, Maven uses "Nearest Definition" logic (Depth First).

**Scenario:**
- A -> B -> C -> D (v1.0)
- A -> E -> D (v2.0)

**Result:** Maven chooses **D (v2.0)** because the path `A->E->D` (depth 2) is shorter than `A->B->C->D` (depth 3). This is mathematically deterministic but dangerous if v2.0 breaks v1.0 compatibility.

### Best Practice: The `<dependencyManagement>` BOM
To govern this in an enterprise, use a **Bill of Materials (BOM)** or a parent POM with `dependencyManagement`.
This forces a specific version across the entire graph, ignoring depth.

---

## 3. Dependency Scopes

Understanding scopes is vital for keeping build artifacts (WAR/JAR) lightweight and secure.

| Scope | Description | Transitive? | Packaged? | Example |
| :--- | :--- | :--- | :--- | :--- |
| **compile** | Default. Available everywhere. | Yes | Yes | Spring Core |
| **provided** | JDK or Container provides it. | No | No | Servlet API, Lombok |
| **runtime** | Not needed for compilation, only running. | Yes | Yes | JDBC Driver |
| **test** | Only for testing. | No | No | JUnit, Mockito |
| **import** | Used only in `dependencyManagement` to pull in a BOM. | - | - | Spring Cloud BOM |

> **Security Note:** Never ship `test` scoped dependencies (like Mock libraries) to production. They increase the attack surface.

---

## 4. Conflict Resolution Tools

### `mvn dependency:tree`
The ultimate debugging tool. It visualizes the graph.
`mvn dependency:tree -Dverbose -Dincludes=commons-logging`

### Exclusions
If a library brings in unwanted garbage, surgically remove it:
```xml
<dependency>
    <groupId>com.bad.lib</groupId>
    <artifactId>legacy</artifactId>
    <exclusions>
        <exclusion>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

---

## 5. Enterprise Governance Standards

1.  **Ban Snapshots in Release:** The Enforcer Plugin should block any `-SNAPSHOT` dependencies when running a release build to ensure reproducibility.
2.  **Converge Dependencies:** Use the `dependency-convergence` rule to ensure that if a library appears 5 times in the graph, all 5 point to the same version.
3.  **Vulnerability Scanning:** Integrate `OWASP Dependency Check` in the `verify` phase to fail builds if CVEs are detected in the graph.
