#!/bin/bash
  set -e

  /home/ec2-user/load-env || echo "Skipping load-env step (not found)."

  # Validate AWS credentials
  if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "AWS credentials not found. Skipping AWS CLI installation."
    exit 1
  fi

  echo "Removing curl-minimal (if installed) to avoid conflict..."
  sudo dnf remove -y curl-minimal || true

  echo "Installing required packages..."
  sudo dnf install -y git java-17-amazon-corretto-devel wget unzip curl docker

  # --- Install Maven ---
  MAVEN_VERSION="3.9.11"
  MAVEN_URL="https://downloads.apache.org/maven/maven-3/$$MAVEN_VERSION/binaries/apache-maven-$$MAVEN_VERSION-bin.tar.gz"
  MAVEN_ARCHIVE="apache-maven-$$MAVEN_VERSION-bin.tar.gz"
  echo "Installing Maven version $$MAVEN_VERSION..."

  if ! wget "$$MAVEN_URL"; then 
    echo "Failed to download Maven from $$MAVEN_URL. Exiting..."
    exit 1
  fi

  if ! tar -xzf "$$MAVEN_ARCHIVE"; then 
    echo "Failed to extract Maven archive. Exiting..."
    exit 1
  fi

  if [ -d /opt/maven ]; then
    sudo rm -rf /opt/maven
  fi

  if ! sudo mv "apache-maven-$$MAVEN_VERSION" /opt/maven; then 
    echo "Failed to move Maven to /opt/maven. Exiting..."
    exit 1
  fi 

  if [ -e /usr/bin/mvn ]; then
    sudo rm -f /usr/bin/mvn
  fi

  if ! sudo ln -s /opt/maven/bin/mvn /usr/bin/mvn; then
    echo "Failed to create symlink for mvn. Exiting..."
    exit 1
  fi

  export M2_HOME=/opt/maven
  export PATH=$$M2_HOME/bin:$$PATH

  echo "Maven installation completed successfully."

  # --- Clone repository ---
  clone_repository(){
    mkdir -p /home/ec2-user/petMS-app
    cd /home/ec2-user/petMS-app
    if [ ! -d "spring-petclinic-microservices" ]; then 
      echo "Cloning Spring Petclinic Microservices..."
      git clone https://github.com/spring-petclinic/spring-petclinic-microservices.git
    fi
    cd spring-petclinic-microservices
    chmod +x mvnw    
  }

  # --- Build application ---
  build_application(){
    echo "Building Spring Petclinic Microservices..."
    cd /home/ec2-user/petMS-app/spring-petclinic-microservices
    ./mvnw package -DskipTests
  }

  # --- Run application ---
  run_application(){
    echo "Running Spring Petclinic Microservices..."
    cd /home/ec2-user/petMS-app/spring-petclinic-microservices
    nohup ./mvnw spring-boot:run &
  }

  # --- Execute steps ---
  clone_repository
  build_application
  run_application