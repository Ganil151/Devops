#!/bin/bash
set -e

# Update and install required packages
sudo yum update -y
sudo yum install -y git java-17-amazon-corretto-devel docker

# Install Maven
MAVEN_VERSION="3.9.11"
MAVEN_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

wget "$MAVEN_URL"
tar -xzf "$MAVEN_ARCHIVE"
sudo mv "apache-maven-${MAVEN_VERSION}" /opt/maven
sudo ln -sf /opt/maven/bin/mvn /usr/bin/mvn
rm -f "$MAVEN_ARCHIVE"

export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH

