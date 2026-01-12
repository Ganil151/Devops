# Maven Build Lifecycle

Build phases, goals, and plugin execution in Maven project lifecycle management.

## Build Lifecycles

### Default Lifecycle
```bash
# Core phases in order
mvn validate        # Validate project structure
mvn initialize      # Initialize build state
mvn generate-sources # Generate source code
mvn process-sources # Process source code
mvn generate-resources # Generate resources
mvn process-resources # Copy resources to target
mvn compile         # Compile source code
mvn process-classes # Post-process compiled classes
mvn generate-test-sources # Generate test sources
mvn process-test-sources # Process test sources
mvn generate-test-resources # Generate test resources
mvn process-test-resources # Copy test resources
mvn test-compile    # Compile test sources
mvn process-test-classes # Post-process test classes
mvn test           # Run unit tests
mvn prepare-package # Pre-package operations
mvn package        # Create JAR/WAR/EAR
mvn pre-integration-test # Pre-integration test setup
mvn integration-test # Run integration tests
mvn post-integration-test # Post-integration test cleanup
mvn verify         # Verify package validity
mvn install        # Install to local repository
mvn deploy         # Deploy to remote repository
```

### Clean Lifecycle
```bash
mvn pre-clean      # Pre-clean operations
mvn clean          # Remove target directory
mvn post-clean     # Post-clean operations
```

### Site Lifecycle
```bash
mvn pre-site       # Pre-site generation
mvn site           # Generate project documentation
mvn post-site      # Post-site generation
mvn site-deploy    # Deploy site documentation
```

## Plugin Goals

### Compiler Plugin
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.10.1</version>
    <configuration>
        <source>11</source>
        <target>11</target>
        <encoding>UTF-8</encoding>
        <compilerArgs>
            <arg>-Xlint:all</arg>
            <arg>-Werror</arg>
        </compilerArgs>
    </configuration>
</plugin>
```

### Surefire Plugin (Testing)
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M7</version>
    <configuration>
        <includes>
            <include>**/*Test.java</include>
            <include>**/*Tests.java</include>
        </includes>
        <excludes>
            <exclude>**/*IntegrationTest.java</exclude>
        </excludes>
        <parallel>methods</parallel>
        <threadCount>4</threadCount>
    </configuration>
</plugin>
```

### Failsafe Plugin (Integration Tests)
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <version>3.0.0-M7</version>
    <configuration>
        <includes>
            <include>**/*IT.java</include>
            <include>**/*IntegrationTest.java</include>
        </includes>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## Custom Plugin Execution

### Binding Goals to Phases
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
        <execution>
            <id>pre-compile-task</id>
            <phase>generate-sources</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <target>
                    <echo message="Generating sources..."/>
                    <mkdir dir="${project.build.directory}/generated-sources"/>
                </target>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### Multiple Executions
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
        <execution>
            <id>pre-test-script</id>
            <phase>pre-integration-test</phase>
            <goals>
                <goal>exec</goal>
            </goals>
            <configuration>
                <executable>./scripts/setup-test-db.sh</executable>
            </configuration>
        </execution>
        <execution>
            <id>post-test-script</id>
            <phase>post-integration-test</phase>
            <goals>
                <goal>exec</goal>
            </goals>
            <configuration>
                <executable>./scripts/cleanup-test-db.sh</executable>
            </configuration>
        </execution>
    </executions>
</plugin>
```

This guide covers Maven build lifecycle management and plugin configuration strategies.