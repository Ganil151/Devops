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

### Advanced Level
7. **Explain Spring Boot "Profiles".**
   - Ways to segregate parts of app config. `-Dspring.profiles.active=prod` loads `application-prod.properties`.
8. **How does "Dependency Injection" aid testing?**
   - You can inject "Mock" objects instead of real databases/services during unit tests without changing the code.
9. **Explain JVM Container Awareness.**
   - Older Java versions saw **Host** memory/CPU, not **Container** limits, causing OOMs. New versions (`-XX:+UseContainerSupport`) respect cgroups.

---

## Quiz: Spring Boot for DevOps

<details>
<summary><b>1. Major feature of Spring Boot over legacy Spring?</b></summary>
A) Embedded Server (Run as JAR)<br>
B) Requires XML config<br>
C) Slower<br>
D) Only supports WAR<br>
<br>
<b>Answer: A) Embedded Server (Run as JAR)</b>
</details>

<details>
<summary><b>2. Standard config file name?</b></summary>
A) application.properties<br>
B) config.xml<br>
C) settings.json<br>
D) spring.conf<br>
<br>
<b>Answer: A) application.properties</b>
</details>

<details>
<summary><b>3. Which command runs the packaged application?</b></summary>
A) java -jar app.jar<br>
B) node app.jar<br>
C) python app.jar<br>
D) run app.jar<br>
<br>
<b>Answer: A) java -jar app.jar</b>
</details>

<details>
<summary><b>4. Spring Actuator is used for?</b></summary>
A) Health checks and Metrics<br>
B) Database connection<br>
C) UI Design<br>
D) Animation<br>
<br>
<b>Answer: A) Health checks and Metrics</b>
</details>

<details>
<summary><b>5. Maven build file is called:</b></summary>
A) pom.xml<br>
B) package.json<br>
C) build.gradle<br>
D) Makefile<br>
<br>
<b>Answer: A) pom.xml (Project Object Model)</b>
</details>

<details>
<summary><b>6. Environment Variables have [High/Low] priority over properties file?</b></summary>
A) High (Override file)<br>
B) Low (Files win)<br>
<br>
<b>Answer: A) High (Override file)</b>
</details>

<details>
<summary><b>7. Why use `mvnw` (Wrapper)?</b></summary>
A) Ensures consistent Maven version between developers/CI<br>
B) It is faster<br>
C) It is smaller<br>
D) It converts to Gradle<br>
<br>
<b>Answer: A) Ensures consistent Maven version between developers/CI</b>
</details>

<details>
<summary><b>8. Java Heap Memory error in Docker is usually code:</b></summary>
A) 137 (OOM Kill)<br>
B) 0<br>
C) 404<br>
D) 500<br>
<br>
<b>Answer: A) 137 (OOM Kill)</b>
</details>

<details>
<summary><b>9. Which creates a native binary (no JVM needed)?</b></summary>
A) GraalVM Native Image<br>
B) Maven<br>
C) Tomcat<br>
D) Jenkins<br>
<br>
<b>Answer: A) GraalVM Native Image</b>
</details>

<details>
<summary><b>10. Default port for Spring Boot?</b></summary>
A) 8080<br>
B) 80<br>
C) 3000<br>
D) 5000<br>
<br>
<b>Answer: A) 8080</b>
</details>
