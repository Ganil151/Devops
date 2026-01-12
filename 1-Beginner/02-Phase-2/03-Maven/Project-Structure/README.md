# Maven Project Structure

Standard directory layouts, conventions, and project organization patterns in Maven.

## Standard Directory Layout

### Basic Java Project
```bash
my-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── App.java
│   │   ├── resources/
│   │   │   ├── application.properties
│   │   │   └── logback.xml
│   │   └── filters/
│   │       └── filter.properties
│   ├── test/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── AppTest.java
│   │   └── resources/
│   │       └── test.properties
│   └── it/
│       └── java/
│           └── com/
│               └── example/
│                   └── AppIT.java
├── target/
├── .gitignore
└── README.md
```

### Web Application Structure
```bash
webapp-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           ├── controller/
│   │   │           ├── service/
│   │   │           ├── repository/
│   │   │           └── model/
│   │   ├── resources/
│   │   │   ├── static/
│   │   │   │   ├── css/
│   │   │   │   ├── js/
│   │   │   │   └── images/
│   │   │   └── templates/
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── web.xml
│   │       │   └── views/
│   │       └── index.jsp
│   └── test/
│       ├── java/
│       └── resources/
└── target/
```

## Multi-Module Projects

### Parent-Child Structure
```bash
parent-project/
├── pom.xml (packaging: pom)
├── common/
│   ├── pom.xml
│   └── src/
├── web/
│   ├── pom.xml
│   └── src/
├── service/
│   ├── pom.xml
│   └── src/
└── integration-tests/
    ├── pom.xml
    └── src/
```

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
    
    <modules>
        <module>common</module>
        <module>service</module>
        <module>web</module>
        <module>integration-tests</module>
    </modules>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
</project>
```

### Child Module POM
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>com.example</groupId>
        <artifactId>parent-project</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>
    
    <artifactId>service</artifactId>
    <packaging>jar</packaging>
    
    <dependencies>
        <dependency>
            <groupId>com.example</groupId>
            <artifactId>common</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
</project>
```

## Custom Directory Layouts

### Non-Standard Source Directories
```xml
<build>
    <sourceDirectory>src/java</sourceDirectory>
    <testSourceDirectory>src/test</testSourceDirectory>
    
    <resources>
        <resource>
            <directory>src/conf</directory>
        </resource>
    </resources>
    
    <testResources>
        <testResource>
            <directory>src/test-conf</directory>
        </testResource>
    </testResources>
</build>
```

### Multiple Source Directories
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>build-helper-maven-plugin</artifactId>
    <version>3.3.0</version>
    <executions>
        <execution>
            <id>add-source</id>
            <phase>generate-sources</phase>
            <goals>
                <goal>add-source</goal>
            </goals>
            <configuration>
                <sources>
                    <source>src/generated/java</source>
                    <source>src/legacy/java</source>
                </sources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

This guide covers Maven project structure conventions and organization patterns.