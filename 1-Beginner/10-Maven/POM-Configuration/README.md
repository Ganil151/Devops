# Maven POM Configuration

Project Object Model configuration, inheritance, and advanced POM patterns.

## Basic POM Structure

### Minimal POM
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
</project>
```

### Complete POM Example
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <!-- Project Information -->
    <groupId>com.example</groupId>
    <artifactId>my-application</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    
    <name>My Application</name>
    <description>A sample Maven project</description>
    <url>https://github.com/user/my-application</url>
    
    <!-- Organization Information -->
    <organization>
        <name>Example Corp</name>
        <url>https://example.com</url>
    </organization>
    
    <!-- Developers -->
    <developers>
        <developer>
            <id>john.doe</id>
            <name>John Doe</name>
            <email>john.doe@example.com</email>
            <roles>
                <role>Lead Developer</role>
            </roles>
        </developer>
    </developers>
    
    <!-- License -->
    <licenses>
        <license>
            <name>Apache License 2.0</name>
            <url>https://www.apache.org/licenses/LICENSE-2.0</url>
            <distribution>repo</distribution>
        </license>
    </licenses>
    
    <!-- SCM Information -->
    <scm>
        <connection>scm:git:git://github.com/user/my-application.git</connection>
        <developerConnection>scm:git:ssh://github.com/user/my-application.git</developerConnection>
        <url>https://github.com/user/my-application</url>
        <tag>HEAD</tag>
    </scm>
    
    <!-- Issue Management -->
    <issueManagement>
        <system>GitHub Issues</system>
        <url>https://github.com/user/my-application/issues</url>
    </issueManagement>
    
    <!-- Properties -->
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        
        <!-- Dependency versions -->
        <spring.version>5.3.21</spring.version>
        <junit.version>5.8.2</junit.version>
    </properties>
</project>
```

## POM Inheritance

### Parent POM
```xml
<project>
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>parent-pom</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
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
                    <configuration>
                        <source>${maven.compiler.source}</source>
                        <target>${maven.compiler.target}</target>
                    </configuration>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
```

### Child POM
```xml
<project>
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>com.example</groupId>
        <artifactId>parent-pom</artifactId>
        <version>1.0.0</version>
        <relativePath>../parent-pom/pom.xml</relativePath>
    </parent>
    
    <artifactId>child-module</artifactId>
    <!-- version inherited from parent -->
    
    <dependencies>
        <!-- Version managed by parent -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
        </dependency>
    </dependencies>
</project>
```

## Advanced Configuration

### Profiles
```xml
<profiles>
    <profile>
        <id>development</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <database.url>jdbc:h2:mem:testdb</database.url>
            <log.level>DEBUG</log.level>
        </properties>
    </profile>
    
    <profile>
        <id>production</id>
        <properties>
            <database.url>jdbc:mysql://prod-db:3306/myapp</database.url>
            <log.level>INFO</log.level>
        </properties>
        <build>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-war-plugin</artifactId>
                    <configuration>
                        <webResources>
                            <resource>
                                <directory>src/main/webapp-prod</directory>
                            </resource>
                        </webResources>
                    </configuration>
                </plugin>
            </plugins>
        </build>
    </profile>
</profiles>
```

### Resource Filtering
```xml
<build>
    <resources>
        <resource>
            <directory>src/main/resources</directory>
            <filtering>true</filtering>
            <includes>
                <include>**/*.properties</include>
                <include>**/*.xml</include>
            </includes>
        </resource>
        <resource>
            <directory>src/main/resources</directory>
            <filtering>false</filtering>
            <excludes>
                <exclude>**/*.properties</exclude>
                <exclude>**/*.xml</exclude>
            </excludes>
        </resource>
    </resources>
</build>
```

This guide covers comprehensive Maven POM configuration and inheritance patterns.