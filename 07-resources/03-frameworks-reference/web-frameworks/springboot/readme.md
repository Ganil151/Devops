# ☕ Spring Boot: Enterprise Distributed Systems
*High-Availability Architecture for Java Professionals*

---

## 🗺️ Learning Roadmap

### [01-Inversion-of-Control](./01-inversion-of-control/)
- **Concepts**: Dependency Injection, Beans, Context.
- **Goal**: Understand how Spring manages your application lifecycle.

### [02-Rest-Controllers](./02-rest-controllers/)
- **Concepts**: `@RestController`, `@GetMapping`, `@RequestBody`.
- **Goal**: Build standardized REST endpoints.

### [03-Data-JPA](./03-data-jpa/)
- **Concepts**: Repositories, Entities, H2 Database.
- **Goal**: Persistent storage for enterprise data.

### [04-Actuator-and-Monitoring](./04-actuator-and-monitoring/)
- **Concepts**: `/health`, `/metrics`, Custom Indicators.
- **Goal**: Expose telemetry for Prometheus and Kubernetes.

---

## 🛠️ Quick Start
Use [start.spring.io](https://start.spring.io) to generate your project metadata:
- **Language**: Java / Kotlin
- **Dependencies**: Spring Web, Spring Boot Actuator, DevTools.

---

## 🛡️ SRE Standards
- **JVM Tuning**: Monitor Heap limits (`-Xmx`) to prevent container OOM issues.
- **Actuator Security**: Ensure `/actuator` endpoints are protected by Spring Security in production.
- **Circuit Breakers**: Use Resilience4j for resilient distributed communication.
