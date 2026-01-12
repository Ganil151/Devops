# Maven Installation

Complete installation and configuration guide for Apache Maven across different platforms.

## Prerequisites

### Java Installation
```bash
# Check Java version
java -version

# Install OpenJDK 11 (Ubuntu/Debian)
sudo apt update
sudo apt install openjdk-11-jdk

# Install OpenJDK 11 (RHEL/CentOS)
sudo yum install java-11-openjdk-devel

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> ~/.bashrc
```

## Installation Methods

### Manual Installation
```bash
# Download Maven
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz

# Verify checksum
wget https://archive.apache.org/dist/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz.sha512
sha512sum -c apache-maven-3.9.4-bin.tar.gz.sha512

# Extract and install
tar -xzf apache-maven-3.9.4-bin.tar.gz
sudo mv apache-maven-3.9.4 /opt/maven

# Set permissions
sudo chown -R root:root /opt/maven
```

### Package Manager Installation
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install maven

# RHEL/CentOS/Fedora
sudo yum install maven
# or
sudo dnf install maven

# macOS (Homebrew)
brew install maven

# Verify installation
mvn -version
```

## Environment Configuration

### System Environment Variables
```bash
# Add to ~/.bashrc or ~/.profile
export MAVEN_HOME=/opt/maven
export M2_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH

# Reload environment
source ~/.bashrc

# Verify configuration
echo $MAVEN_HOME
mvn -version
```

### Maven Configuration
```bash
# Global settings location
/opt/maven/conf/settings.xml

# User settings location
~/.m2/settings.xml

# Create user settings
mkdir -p ~/.m2
cp /opt/maven/conf/settings.xml ~/.m2/settings.xml
```

### Basic Settings Configuration
```xml
<!-- ~/.m2/settings.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <localRepository>${user.home}/.m2/repository</localRepository>
  
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
  </servers>
  
  <mirrors>
    <mirror>
      <id>central</id>
      <name>Central Repository</name>
      <url>https://repo1.maven.org/maven2</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  
  <profiles>
    <profile>
      <id>default</id>
      <properties>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
      </properties>
    </profile>
  </profiles>
  
  <activeProfiles>
    <activeProfile>default</activeProfile>
  </activeProfiles>
</settings>
```

This guide covers Maven installation and configuration for development environments.