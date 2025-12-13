# Apache Maven

Comprehensive guide to Maven build automation, dependency management, and project lifecycle for Java applications.

## Maven Overview

### What is Maven?
Apache Maven is a build automation and project management tool primarily used for Java projects. It uses a Project Object Model (POM) and follows convention-over-configuration principles to simplify build processes.

### Key Features
- **Dependency Management**: Automatic library resolution and download
- **Build Lifecycle**: Standardized build phases and goals
- **Project Structure**: Convention-based directory layout
- **Plugin Architecture**: Extensible functionality through plugins
- **Repository System**: Local, central, and remote artifact storage
- **Multi-Module Support**: Complex project organization

## Directory Structure

```bash
Maven/
├── Installation/           # Setup and configuration
├── Project-Structure/      # Standard Maven layouts
├── POM-Configuration/      # Project Object Model setup
├── Dependencies/           # Dependency management
├── Build-Lifecycle/        # Phases, goals, and plugins
├── Repositories/           # Local, central, and remote repos
├── Plugins/               # Plugin configuration and usage
├── Multi-Module/          # Multi-module project patterns
├── Profiles/              # Build profiles and environments
├── CI-CD-Integration/     # Jenkins, GitHub Actions integration
├── Best-Practices/        # Production guidelines
└── Troubleshooting/       # Common issues and solutions
```

## Quick Start

### Installation
```bash
# Download Maven
wget https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz

# Extract
tar -xzf apache-maven-3.9.4-bin.tar.gz
sudo mv apache-maven-3.9.4 /opt/maven

# Set environment variables
export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH

# Verify installation
mvn -version
```

### Create Project
```bash
# Generate project from archetype
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=my-app \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false

# Build project
cd my-app
mvn clean compile
mvn test
mvn package
```

## Core Concepts

### Project Object Model (POM)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.13.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

### Build Lifecycle
```bash
# Default lifecycle phases
mvn validate    # Validate project structure
mvn compile     # Compile source code
mvn test        # Run unit tests
mvn package     # Create JAR/WAR
mvn verify      # Run integration tests
mvn install     # Install to local repository
mvn deploy      # Deploy to remote repository

# Clean lifecycle
mvn clean       # Remove target directory

# Site lifecycle
mvn site        # Generate project documentation
```

This comprehensive Maven guide provides enterprise-ready build automation and project management capabilities.