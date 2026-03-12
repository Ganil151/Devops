# 🗄️ Spring Data JPA & Persistence
*Abstracting Database Complexity with Java*

---

## 📖 Overview
Spring Data JPA makes it easy to implement JPA-based repositories. It handles the mapping between your Java Objects (Entities) and SQL tables.

---

## 🏗️ Technical Pillars

### 1. `@Entity`
Mark a Java class to be mapped to a database table.
```java
@Entity
public class AuditLog {
    @Id @GeneratedValue
    private Long id;
    private String message;
}
```

### 2. `JpaRepository` Interface
No implementation needed. Spring generates the SQL for you.
```java
public interface LogRepository extends JpaRepository<AuditLog, Long> {
    List<AuditLog> findBySeverity(String severity);
}
```

### 3. H2 / PostgreSQL / MySQL
Spring Boot uses `application.properties` to connect to the physical database.

---

## 🚀 DevOps Advantage: Data Versioning
Combined with **Flyway** or **Liquibase**, Spring Boot can automatically manage database migrations during the startup of your container.

---

## 🛡️ SRE Standard Checklist
- [ ] Is the database connection pool (HikariCP) tuned for performance?
- [ ] Are SQL queries logged in development (`show-sql=true`)?
- [ ] Are sensitive database credentials stored as environment variables or secrets?

---
**Next Step**: [04-Actuator-and-Monitoring](../04-actuator-and-monitoring/readme.md)
