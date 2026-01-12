# Maven Dependencies

Comprehensive dependency management, resolution, and best practices in Maven projects.

## Dependency Basics

### Adding Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>5.3.21</version>
    </dependency>
    
    <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.13.2</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Dependency Scopes
```xml
<!-- Compile scope (default) -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
    <version>3.12.0</version>
    <scope>compile</scope>
</dependency>

<!-- Test scope -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>4.6.1</version>
    <scope>test</scope>
</dependency>

<!-- Provided scope -->
<dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>javax.servlet-api</artifactId>
    <version>4.0.1</version>
    <scope>provided</scope>
</dependency>

<!-- Runtime scope -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.29</version>
    <scope>runtime</scope>
</dependency>
```

## Dependency Management

### Version Management
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-bom</artifactId>
            <version>5.3.21</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <!-- Version inherited from BOM -->
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
    </dependency>
</dependencies>
```

### Properties for Versions
```xml
<properties>
    <spring.version>5.3.21</spring.version>
    <junit.version>4.13.2</junit.version>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
</properties>

<dependencies>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-core</artifactId>
        <version>${spring.version}</version>
    </dependency>
</dependencies>
```

## Transitive Dependencies

### Exclusions
```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-web</artifactId>
    <version>5.3.21</version>
    <exclusions>
        <exclusion>
            <groupId>commons-logging</groupId>
            <artifactId>commons-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

### Dependency Analysis
```bash
# View dependency tree
mvn dependency:tree

# Analyze dependencies
mvn dependency:analyze

# Resolve dependencies
mvn dependency:resolve

# Copy dependencies
mvn dependency:copy-dependencies -DoutputDirectory=target/lib
```

## Conflict Resolution

### Version Conflicts
```bash
# Find dependency conflicts
mvn dependency:tree -Dverbose

# Show effective POM
mvn help:effective-pom

# Dependency mediation example
# If A depends on B 1.0 and C depends on B 2.0
# Maven chooses the nearest version in the dependency tree
```

### Force Specific Versions
```xml
<dependencies>
    <!-- Force specific version -->
    <dependency>
        <groupId>commons-collections</groupId>
        <artifactId>commons-collections</artifactId>
        <version>3.2.2</version>
    </dependency>
    
    <!-- This will use 3.2.2 even if transitive deps want different version -->
    <dependency>
        <groupId>org.apache.struts</groupId>
        <artifactId>struts2-core</artifactId>
        <version>2.5.30</version>
    </dependency>
</dependencies>
```

This guide covers comprehensive Maven dependency management and resolution strategies.