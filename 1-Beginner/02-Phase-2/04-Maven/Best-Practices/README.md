# Maven Best Practices

Production-ready guidelines, patterns, and optimization strategies for Maven projects.

## Project Structure

### Standard Directory Layout
```bash
my-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   ├── resources/
│   │   └── webapp/
│   └── test/
│       ├── java/
│       │   └── com/example/
│       └── resources/
├── target/
└── README.md
```

### Multi-Module Structure
```bash
parent-project/
├── pom.xml (parent)
├── module-a/
│   ├── pom.xml
│   └── src/
├── module-b/
│   ├── pom.xml
│   └── src/
└── integration-tests/
    ├── pom.xml
    └── src/
```

## POM Best Practices

### Parent POM Configuration
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>parent-project</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        
        <!-- Dependency versions -->
        <spring.version>5.3.21</spring.version>
        <junit.version>5.8.2</junit.version>
        <mockito.version>4.6.1</mockito.version>
    </properties>
    
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-bom</artifactId>
                <version>${spring.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    
    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.10.1</version>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
```

## Dependency Management

### Version Management Strategy
```xml
<properties>
    <!-- Use properties for version management -->
    <spring.version>5.3.21</spring.version>
    <jackson.version>2.13.3</jackson.version>
</properties>

<dependencyManagement>
    <dependencies>
        <!-- Import BOMs for consistent versions -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-bom</artifactId>
            <version>${spring.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Scope Best Practices
```xml
<dependencies>
    <!-- Runtime dependencies -->
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Test dependencies -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Provided dependencies -->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

## Build Configuration

### Plugin Management
```xml
<build>
    <pluginManagement>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
                <configuration>
                    <source>${maven.compiler.source}</source>
                    <target>${maven.compiler.target}</target>
                    <encoding>${project.build.sourceEncoding}</encoding>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</groupId>
                <version>3.0.0-M7</version>
                <configuration>
                    <argLine>-Xmx1024m</argLine>
                    <parallel>methods</parallel>
                    <threadCount>4</threadCount>
                </configuration>
            </plugin>
        </plugins>
    </pluginManagement>
</build>
```

## Security Best Practices

### Dependency Vulnerability Scanning
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>7.1.1</version>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

### Secure Repository Configuration
```xml
<repositories>
    <repository>
        <id>central</id>
        <url>https://repo1.maven.org/maven2</url>
        <releases>
            <enabled>true</enabled>
            <checksumPolicy>fail</checksumPolicy>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repository>
</repositories>
```

This guide provides enterprise-grade Maven best practices for production projects.