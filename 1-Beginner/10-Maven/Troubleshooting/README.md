# Maven Troubleshooting

Common issues, debugging techniques, and resolution strategies for Maven projects.

## Common Build Issues

### Dependency Resolution Problems
```bash
# Clear local repository
rm -rf ~/.m2/repository

# Force update dependencies
mvn clean install -U

# Offline mode (use only local repository)
mvn clean install -o

# Debug dependency resolution
mvn dependency:tree -Dverbose
mvn dependency:analyze
```

### Compilation Errors
```bash
# Check effective POM
mvn help:effective-pom

# Verify Java version
java -version
mvn -version

# Check compiler plugin configuration
mvn help:describe -Dplugin=compiler -Ddetail
```

### Memory Issues
```bash
# Increase Maven memory
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"

# For Windows
set MAVEN_OPTS=-Xmx2048m -XX:MaxPermSize=512m

# Project-specific memory settings
mvn clean install -Dmaven.compiler.fork=true -Dmaven.compiler.maxmem=1024m
```

## Debugging Techniques

### Verbose Output
```bash
# Debug mode
mvn clean install -X

# Show version information
mvn clean install -V

# Quiet mode (errors only)
mvn clean install -q

# Show stack traces
mvn clean install -e
```

### Plugin Debugging
```bash
# Debug specific plugin
mvn help:describe -Dplugin=surefire -Ddetail

# List all plugins
mvn help:describe -Dplugin=help -Ddetail

# Execute specific goal
mvn surefire:test -Dtest=MyTest
```

## Network and Repository Issues

### Repository Problems
```bash
# Check repository connectivity
curl -I https://repo1.maven.org/maven2/

# Use different repository
mvn clean install -Dmaven.repo.remote=https://repo1.maven.org/maven2

# Check settings.xml
mvn help:effective-settings
```

### Proxy Configuration
```xml
<!-- ~/.m2/settings.xml -->
<settings>
    <proxies>
        <proxy>
            <id>corporate-proxy</id>
            <active>true</active>
            <protocol>http</protocol>
            <host>proxy.company.com</host>
            <port>8080</port>
            <username>proxyuser</username>
            <password>proxypass</password>
            <nonProxyHosts>localhost|127.0.0.1|*.company.com</nonProxyHosts>
        </proxy>
    </proxies>
</settings>
```

## Test Failures

### Surefire Plugin Issues
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M7</version>
    <configuration>
        <!-- Skip tests -->
        <skipTests>true</skipTests>
        
        <!-- Run specific test -->
        <test>MyTest</test>
        
        <!-- Increase memory -->
        <argLine>-Xmx1024m</argLine>
        
        <!-- Fork JVM -->
        <forkCount>1</forkCount>
        <reuseForks>false</reuseForks>
    </configuration>
</plugin>
```

### Test Debugging
```bash
# Run single test
mvn test -Dtest=MyTest

# Run tests with pattern
mvn test -Dtest=*IntegrationTest

# Skip tests
mvn clean install -DskipTests

# Skip test compilation
mvn clean install -Dmaven.test.skip=true
```

## Performance Issues

### Build Performance
```bash
# Parallel builds
mvn clean install -T 4

# Skip unnecessary phases
mvn compile -Dmaven.test.skip=true

# Use build cache
mvn clean install -Dmaven.build.cache.enabled=true
```

### Dependency Download Optimization
```bash
# Download sources and javadocs
mvn dependency:sources dependency:resolve -Dclassifier=javadoc

# Prefetch dependencies
mvn dependency:go-offline
```

## Version Conflicts

### Dependency Conflicts
```bash
# Find version conflicts
mvn dependency:tree -Dverbose | grep "conflict"

# Analyze dependency usage
mvn dependency:analyze-duplicate

# Show dependency updates
mvn versions:display-dependency-updates
```

### Resolution Strategies
```xml
<!-- Force specific version -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>commons-collections</groupId>
            <artifactId>commons-collections</artifactId>
            <version>3.2.2</version>
        </dependency>
    </dependencies>
</dependencyManagement>

<!-- Exclude transitive dependency -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>commons-logging</groupId>
            <artifactId>commons-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

## Recovery Procedures

### Clean Build Environment
```bash
# Complete clean
mvn clean
rm -rf target/
rm -rf ~/.m2/repository/

# Reset to clean state
git clean -fdx
mvn clean install
```

### Corrupted Repository Fix
```bash
# Find corrupted files
find ~/.m2/repository -name "*.lastUpdated" -delete

# Rebuild repository
rm -rf ~/.m2/repository
mvn dependency:resolve
```

This comprehensive Maven troubleshooting guide helps resolve common build and configuration issues.