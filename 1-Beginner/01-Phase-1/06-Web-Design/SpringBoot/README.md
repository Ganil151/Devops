# Spring Boot for DevOps Engineers

Spring Boot is the standard for enterprise Java development. It simplifies building production-grade Spring applications by favoring "convention over configuration".

## 1. Core Concepts

### The Jar File
Spring Boot embeds a web server (Tomcat, Jetty) directly *inside* the JAR file. You don't deploy the WAR file to a standalone Tomcat server anymore; you just run the JAR.

### Annotations
Java uses decorators called annotations to define behavior.
- `@SpringBootApplication`: Entry point.
- `@RestController`: Defines a web API.
- `@Autowired`: Dependency Injection.

### Dependency Injection (DI)
Spring manages the lifecycle of objects (Beans). You don't say `new DatabaseConnection()`; you ask Spring to give you the configured instance.

---

## 2. DevOps Context: The Ecosystem

### Build Tools: Maven vs Gradle
- **Maven (`pom.xml`):** XML-based, strict structure, very common in enterprise.
- **Gradle (`build.gradle`):** Groovy/Kotlin DSL, flexible, faster builds.

### Application Properties
Config lives in `src/main/resources/application.properties` (or `.yaml`).
**Key for DevOps:** These can be overridden by Environment Variables or Command Line args.
`server.port=8080` -> `SERVER_PORT=9090` (Env Var override).

### Packaging
```bash
# Maven
./mvnw package
# Output: target/myapp-0.0.1-SNAPSHOT.jar

# Gradle
./gradlew build
# Output: build/libs/myapp-0.0.1-SNAPSHOT.jar
```

---

## 3. Dockerizing Spring Boot

### Optimized Dockerfile (Layered Jar)
Spring Boot 2.3+ supports "layered" JARs to optimize Docker caching (separating dependencies from app code).

**Simple Version:**
```dockerfile
FROM openjdk:17-alpine
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Memory Management:**
Java inside containers needs attention.
`ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]`
This tells the JVM to use a percentage of the container's memory limit, rather than guessing based on host memory.

---

## Real World Scenarios

### Scenario 1: "OOM Kill" (Out of Memory)
**Context:** Spring Boot container constantly restarts with "Exit Code 137". (128 + 9 aka SIGKILL).
**Root Cause:** JVM Heap size exceeded Docker container memory limit. Kernel kills the process.
**Solution:**
1. Increase Container Memory.
2. Limit JVM Heap: `-Xmx512m` or `-XX:MaxRAMPercentage`.

### Scenario 2: Slow Startup / "Cold Start"
**Context:** Auto-scaling takes too long because Java takes 30s to start.
**Solution:**
- **GraalVM Native Image:** Compile Java to native binary (starts in milliseconds).
- **Optimization:** Lazy initialization, or use lightweight frameworks (Quarkus/Micronaut) if Spring is too heavy.

---

## Interview Questions

### Basic Level
1. **What is an "Embedded Server" in Spring Boot?**
   - Tomcat/Jetty runs inside the app process. Just `java -jar app.jar`.
2. **Where do you define dependencies in a Maven project?**
   - `pom.xml`.
3. **What is Actuator?**
   - A Spring Boot library that exposes operational endpoints (health checks, metrics, env info) at `/actuator/health`, etc.

### Intermediate Level
4. **How do you override `application.properties` in production?**
   - Environment Variables (`SPRING_DATASOURCE_URL` overrides `spring.datasource.url`).
   - Config Maps (K8s) mounted as files.
   - `--command.line.args`.
5. **Difference between JAR and WAR?**
   - **JAR:** Executable, embedded server (Standard for Microservices).
   - **WAR:** Web Archive, requires external Tomcat server (Legacy/Specific use cases).
6. **What is the significance of the Maven Wrapper (`mvnw`)?**
   - Allows running Maven builds without having Maven installed on the machine/agent. It downloads the correct version automatically.

<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: A) Embedded Server (Run as JAR)</b>
</details>


<b>2. Standard config file name?</b>
<details>
<summary>Show Answer</summary>
Answer: A) application.properties</b>
</details>


<b>3. Which command runs the packaged application?</b>
<details>
<summary>Show Answer</summary>
Answer: A) java -jar app.jar</b>
</details>


<b>4. Spring Actuator is used for?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Health checks and Metrics</b>
</details>


<b>5. Maven build file is called:</b>
<details>
<summary>Show Answer</summary>
Answer: A) pom.xml (Project Object Model)</b>
</details>


<b>6. Environment Variables have [High/Low] priority over properties file?</b>
<details>
<summary>Show Answer</summary>
Answer: A) High (Override file)</b>
</details>


<b>7. Why use `mvnw` (Wrapper)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) Ensures consistent Maven version between developers/CI</b>
</details>


<b>8. Java Heap Memory error in Docker is usually code:</b>
<details>
<summary>Show Answer</summary>
Answer: A) 137 (OOM Kill)</b>
</details>


<b>9. Which creates a native binary (no JVM needed)?</b>
<details>
<summary>Show Answer</summary>
Answer: A) GraalVM Native Image</b>
</details>


<b>10. Default port for Spring Boot?</b>
<details>
<summary>Show Answer</summary>
Answer: A) 8080</b>
</details>
