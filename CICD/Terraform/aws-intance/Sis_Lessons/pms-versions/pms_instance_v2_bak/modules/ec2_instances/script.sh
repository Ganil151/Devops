#!/bin/bash
set -e

sudo yum update -y
sudo yum upgrade -y

echo "Installing required packages..."
sudo yum install -y git java-17-amazon-corretto-devel wget unzip docker

MAVEN_VERSION="3.9.11"
MAVEN_URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"

echo "Installing Maven ${MAVEN_VERSION}..."
wget "$MAVEN_URL"
tar -xzf "$MAVEN_ARCHIVE"
sudo mv "apache-maven-${MAVEN_VERSION}" /opt/maven
sudo ln -sf /opt/maven/bin/mvn /usr/bin/mvn
rm -f "$MAVEN_ARCHIVE"

export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
echo "Maven installation completed."

clone_repository() {
  mkdir -p /home/ec2-user/petMS-app
  cd /home/ec2-user/petMS-app
  if [ ! -d "spring-petclinic-microservices" ]; then
    echo "Cloning Spring Petclinic Microservices..."
    git clone https://github.com/spring-petclinic/spring-petclinic-microservices.git
  fi
  cd spring-petclinic-microservices
  chmod +x mvnw
}

build_application() {
  echo "Building Spring Petclinic Microservices..."
  cd /home/ec2-user/petMS-app/spring-petclinic-microservices
  ./mvnw clean package -DskipTests
}

start_services() {
  # Config Server
  cd spring-petclinic-config-server
  nohup java -jar target/*.jar > /dev/null 2>&1 &
  echo "Waiting for Config Server to start..."
  until curl -s -f http://localhost:8888/actuator/health | grep -q '"status":"UP"'; do
    sleep 5
  done

  cd ../spring-petclinic-discovery-server
  nohup java -jar target/*.jar > /dev/null 2>&1 &
  echo "Waiting for Discovery Server to start..."
  until curl -s -f http://localhost:8761/actuator/health | grep -q '"status":"UP"'; do
    sleep 5
  done

  for service in spring-petclinic-api-gateway \
                 spring-petclinic-customers-service \
                 spring-petclinic-vets-service \
                 spring-petclinic-visits-service \
                 spring-petclinic-admin-server; do
    cd ../$service
    nohup java -jar target/*.jar > /dev/null 2>&1 &
  done

  echo "All PetClinic microservices are now running."
}

clone_repository
build_application
start_services
