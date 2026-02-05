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
  sudo chown -R ec2-user:ec2-user /home/ec2-user/petMS-app
  cd spring-petclinic-microservices
  chmod +x mvnw
}

build_application() {
  echo "Building Spring Petclinic Microservices..."
  cd /home/ec2-user/petMS-app/spring-petclinic-microservices
  ./mvnw package -DskipTests
}

start_services() {
  local dir=$1
  local port=$2
  local health_url=$3

  echo "Starting $dir..."
  cd "/home/ec2-user/petMS-app/spring-petclinic-microservices/$dir" && nohup java -jar target/*.jar > /dev/null 2>&1 &

  echo "Waiting for $dir to start..."
  local start_time=$(date +%s)
  until curl -s -f "$health_url" | grep -q '"status":"UP"'; do
    sleep 5
    local current_time=$(date +%s)
    if (( now - start_time > 60)); then
      echo "ERROR: $dir did not start within 60 seconds."
      exit 1
    fi
  done
  echo "$dir started successfully."  
}

start_services() {
  start_service spring-petclinic-discovery-server 8761 http://localhost:8888/actuator/health
  start_service spring-petclinic-config-server 8888 http://localhost:8888/actuator/health

  for service in spring-petclinic-api-gateway \
                 spring-petclinic-visits-service \
                 spring-petclinic-vets-service \
                 spring-petclinic-customers-service; do
    nohup java -jar "/home/ec2-user/petMS-app/spring-petclinic-microservices/${service}/target/"*.jar > "${service}.log" 2>&1 &
    sleep 60
  done

  echo "All services started successfully."
  
}

clone_repository
build_application
start_services

