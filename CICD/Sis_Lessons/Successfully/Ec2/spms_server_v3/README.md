### Webhook Configuration
Added the triggers block with githubPush() to enable automatic builds triggered by GitHub webhooks.
To set up the webhook:
Go to your GitHub repository settings.
Navigate to Webhooks > Add Webhook.
Set the Payload URL to your Jenkins server's webhook endpoint (e.g., http://<jenkins-server>/github-webhook/).
Select Content type as application/json.
Save the webhook.
2. Removed Docker Commands
Removed all Docker-specific commands (docker compose build, docker compose up -d, etc.) since Docker is no longer used.
Instead, the pipeline now focuses on building and testing the application directly.
3. Maven Build and Test
Used Maven (./mvnw) to build and test the application:
./mvnw clean package -DskipTests: Builds the application without running tests.
./mvnw test: Runs unit tests.
4. Deployment Step
Added a placeholder for deploying the application to a test environment. You can customize this step based on your deployment process (e.g., copying files to a server, uploading to AWS S3, etc.).
5. Post-Build Actions
Added cleanWs() in the post block to clean up the workspace after the build.
Added success and failure notifications for better visibility.
Steps to Configure Jenkins
Install Required Plugins
Ensure the following plugins are installed:
Pipeline
Git Plugin
Workspace Cleanup Plugin (for cleanWs())
Create a Multibranch Pipeline
Create a multibranch pipeline job in Jenkins.
Configure the repository URL and credentials.
Enable the GitHub hook trigger for GITScm polling option.
Set Up Webhook
Follow the steps mentioned above to configure the GitHub webhook.
Run the Pipeline
Push changes to the repository, and the webhook will trigger the pipeline automatically.
Advantages of This Approach
No Dependency on Docker: Simplifies the pipeline by removing Docker, making it easier to manage and debug.
Automated Builds: Webhooks ensure that builds are triggered automatically whenever changes are pushed to the repository.
Focus on Core Build Process: The pipeline focuses on building, testing, and deploying the application without unnecessary complexity.
Let me know if you need further assistance!

### 
```bash
sudo -u jenkins ssh-keyscan -H <WORKER-IP> | sudo tee -a /var/lib/jenkins/.ssh/known_hosts > /dev/null
```

### Configure Git tool in Jenkins
Go to Manage Jenkins → Global Tool Configuration → Git
Add an installation, e.g. name: Default, Path: /usr/bin/git
Save.
Jenkins will stop saying "Git tool = NONE".

### Use Jenkins credentials instead of hardcoding token
Go to Manage Jenkins → Credentials → Add Credentials
Kind: Username with password
```
Username: Ganil151
```

```
Password: <your GitHub personal access token>
```

```
ID: github-credentials
```

### Then change your pipeline Checkout stage to:
```
stage('Checkout') {
    steps {
        git branch: 'main',
            url: 'https://github.com/Ganil151/spring-petclinic-microservices.git',
            credentialsId: 'github-credentials'
    }
}
```

### Install Docker using Jenkinsfile

Configure Credentials: Follow the prerequisite steps to set up an SSH key pair and add the private key to Jenkins Credentials with the ID aws-ec2-ssh-key.
Create Jenkins Pipeline Job:
In the Jenkins UI, click New Item.
Enter a name for your job and select Pipeline. Click OK.
Define the Pipeline:
Scroll down to the Pipeline section in the job configuration.
Select Pipeline script from the "Definition" dropdown.
Copy and paste the Groovy script from above into the text area.
Important: Replace <YOUR_EC2_IP> with the public IP address or hostname of your Amazon Linux 2023 instance.
Run the Job:
Save the job configuration.
Click Build Now to execute the pipeline.
You can monitor the installation progress by viewing the Console Output of the build. 
Script explanation
pipeline { ... }: Defines a declarative pipeline.
agent any: Tells Jenkins to use any available agent to run the pipeline.
environment { ... }: Defines environment variables for your EC2 host and SSH credential ID.
sshagent(credentials: [...]) { ... }: This step from the SSH Agent Plugin makes the private key securely available to commands run inside its block.
ssh -o StrictHostKeyChecking=no ... << END_OF_SCRIPT: This is a heredoc that runs a series of commands on the remote host via SSH. StrictHostKeyChecking=no is added for automation to skip the host key verification prompt.
sudo yum install -y docker: Installs the Docker engine from the Amazon Linux 2023 repositories.
sudo usermod -a -G docker ${EC2_USER}: Adds the EC2 user to the docker group, allowing them to run Docker commands without sudo.
Re-authentication: Because group changes require a new login session, the script intentionally exits and reconnects.
curl ... -o /usr/libexec/docker/cli-plugins/docker-compose: This command downloads the Docker Compose V2 plugin binary directly from the Docker GitHub repository and places it in the correct directory for Amazon Linux 2023.
chmod +x: Makes the downloaded binary executable.
docker compose version: Verifies that both Docker and the new compose plugin are installed and working. 

```Jenkinsfile
// Use a stage-based declarative pipeline.
pipeline {
    agent any

    // Define environment variables.
    environment {
        // Use the ID of the SSH credential you stored in Jenkins.
        SSH_CREDENTIAL_ID = 'aws-ec2-ssh-key'
        // Replace with your EC2 instance's public IP or hostname.
        EC2_HOST = '<YOUR_EC2_IP>'
        // Replace with the user for your EC2 instance.
        EC2_USER = 'ec2-user'
    }

    stages {
        stage('Install Docker and Compose on EC2') {
            steps {
                // Use the SSH Agent plugin to securely provide credentials.
                sshagent(credentials: [SSH_CREDENTIAL_ID]) {
                    // Use a multiline shell command to execute all installation steps.
                    sh """
                        # Connect to the EC2 instance via SSH and run commands.
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << END_OF_SCRIPT
                            echo "Updating yum packages..."
                            sudo yum update -y
                            echo "Installing Docker..."
                            sudo yum install -y docker
                            echo "Starting Docker service..."
                            sudo systemctl start docker
                            echo "Enabling Docker service to start on boot..."
                            sudo systemctl enable docker
                            
                            echo "Adding ec2-user to the docker group..."
                            sudo usermod -a -G docker ${EC2_USER}
                            
                            # Log out and log back in to apply group changes.
                            echo "Applying group permissions and re-authenticating..."
                            exit

                        # Reconnect with new permissions to continue.
                        END_OF_SCRIPT
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << END_OF_SCRIPT
                            echo "Installing Docker Compose (v2 plugin)..."
                            sudo curl -sL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m) -o /usr/libexec/docker/cli-plugins/docker-compose
                            sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
                            
                            echo "Verifying installations..."
                            docker --version
                            docker compose version
                        END_OF_SCRIPT
                    """
                }
            }
        }
    }
}

```

### install maven on aws linux 2023 using Jenkinsfile pipeline
To install Maven on a remote Amazon Linux 2023 EC2 instance using a Jenkins Pipeline, you'll create a pipeline script that securely executes the installation steps via SSH. The process requires Java to be installed first, as Maven is a Java-based tool. 
Prerequisites
EC2 Instance: A running EC2 instance with Amazon Linux 2023.
Jenkins: A running Jenkins server with the following plugins installed:
SSH Agent Plugin: For handling SSH credentials securely in your pipeline.
Pipeline: Job: For running the declarative pipeline script.
SSH Key Pair: An SSH key pair for passwordless access between Jenkins and your EC2 instance.
Generate a key pair on the Jenkins server (ssh-keygen).
Add the public key to the ~/.ssh/authorized_keys file on the EC2 instance.
Store the private key in Jenkins credentials (Manage Jenkins > Credentials > System > Global credentials > Add Credentials), selecting SSH Username with private key. Give it a unique ID, like aws-ec2-ssh-key. 

- Jenkinsfile for Maven installation
```
// Use a stage-based declarative pipeline.
pipeline {
    agent any

    // Define environment variables.
    environment {
        // Use the ID of the SSH credential stored in Jenkins.
        SSH_CREDENTIAL_ID = 'aws-ec2-ssh-key'
        // Replace with your EC2 instance's public IP or hostname.
        EC2_HOST = '<YOUR_EC2_IP>'
        // Replace with the user for your EC2 instance.
        EC2_USER = 'ec2-user'
    }

    stages {
        stage('Install Java and Maven on EC2') {
            steps {
                // Use the SSH Agent plugin to provide credentials securely.
                sshagent(credentials: [SSH_CREDENTIAL_ID]) {
                    // Use a multiline shell script to install dependencies via SSH.
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << 'END_OF_SCRIPT'
                            echo "Updating system packages..."
                            sudo dnf update -y

                            echo "Installing Java 17 (required by Maven)..."
                            sudo dnf install -y java-17-amazon-corretto-devel
                            java -version

                            echo "Downloading and installing Maven..."
                            MAVEN_VERSION="3.9.6" # Specify the desired Maven version
                            wget https://dlcdn.apache.org/maven/maven-3/\${MAVEN_VERSION}/binaries/apache-maven-\${MAVEN_VERSION}-bin.tar.gz -P /tmp
                            
                            sudo tar xf /tmp/apache-maven-\${MAVEN_VERSION}-bin.tar.gz -C /opt
                            sudo ln -s /opt/apache-maven-\${MAVEN_VERSION} /opt/maven

                            echo "Setting up Maven environment variables..."
                            sudo tee /etc/profile.d/maven.sh > /dev/null << 'EOF'
                            export M2_HOME=/opt/maven
                            export PATH=\${M2_HOME}/bin:\${PATH}
                            EOF
                            sudo chmod +x /etc/profile.d/maven.sh
                            
                            echo "Verifying Maven installation..."
                            source /etc/profile.d/maven.sh
                            mvn -version
                        END_OF_SCRIPT
                    """
                }
            }
        }
    }
}
```
#### 
How to use the script
Configure Jenkins Credentials: Follow the prerequisite steps to set up the aws-ec2-ssh-key SSH credential in Jenkins.
Create Jenkins Pipeline Job:
In the Jenkins UI, click New Item, enter a name, and select Pipeline.
Define the Pipeline Script:
In the job configuration, scroll to the Pipeline section.
Select Pipeline script from the "Definition" dropdown.
Copy and paste the Groovy script above into the text area.
Important: Replace <YOUR_EC2_IP> with the public IP address or hostname of your Amazon Linux 2023 instance.
Run the Job:
Save the job and click Build Now.
Check the Console Output to monitor the installation progress. The output should show Java and Maven versions successfully installed on the remote machine. 
Script explanation
sshagent(credentials: [...]) { ... }: This step from the SSH Agent Plugin securely makes your private key available to the commands run inside its block, so you don't need to manually expose keys.
ssh -o StrictHostKeyChecking=no ... << 'END_OF_SCRIPT': This is a "heredoc" that allows you to execute a multi-line shell script on the remote EC2 instance via SSH.
sudo dnf update -y: Updates the package manager on Amazon Linux 2023, ensuring that you are working with the latest packages.
sudo dnf install -y java-17-amazon-corretto-devel: Installs Java 17, which is a prerequisite for running modern Maven versions on Amazon Linux 2023.
wget ... -P /tmp: Downloads the Maven binary from the official Apache site to a temporary directory.
sudo tar xf ...: Extracts the Maven tarball into the /opt directory, which is a standard location for optional software.
sudo ln -s ...: Creates a symbolic link for Maven. This simplifies version updates and path management.
sudo tee /etc/profile.d/maven.sh: Creates a script to set the M2_HOME and PATH environment variables for all users. This makes the mvn command available system-wide.
source /etc/profile.d/maven.sh: Sources the newly created environment script to apply the changes immediately within the current session.
mvn -version: Verifies that Maven has been successfully installed and is accessible

## Steps to generate and configure a webhook secret in Jenkins
1. Generate a random secret

On your Jenkins master (or locally), run:
```bash
openssl rand -hex 20
```

Example output:
```bash
4a1d5b6f7a9c2e8d1f3a4b7c6e8d9a2f3b7c5a4d
```

This is your webhook secret.


## Build & Push Docker 
```groovy
pipeline {
    agent { label params.NODE_LABEL }

    environment {
        COMPOSE_PROJECT_NAME = "spring-petclinic"
        DOCKER_IMAGE = "ganil151/spring-petclinic:latest"
    }

    parameters {
        string(
            name: 'NODE_LABEL',
            defaultValue: 'worker-node-1',
            description: 'Label of the Jenkins worker node to run this pipeline'
        )
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Ganil151/spring-petclinic-microservices.git'
            }
        }

        stage('Install yq') {
            steps {
                script {
                    sh '''
                    if ! command -v yq &> /dev/null; then
                        echo "Installing yq..."
                        sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq
                        sudo chmod +x /usr/local/bin/yq
                    fi
                    '''
                }
            }
        }

        stage('Remove genai-service from docker-compose.yml') {
            steps {
                script {
                    sh '''
                    cp docker-compose.yml docker-compose.yml.bak
                    yq eval 'del(.services.genai-service)' -i docker-compose.yml
                    '''
                }
            }
        }

        stage('Build Application') {
            environment {
                JAVA_HOME = '/usr/lib/jvm/java-17-amazon-corretto.x86_64'
                PATH = "${JAVA_HOME}/bin:${env.PATH}
            }
            steps {
                script {
                    sh '''
                    echo "Building the Spring PetClinic application..."
                    ./mvnw clean package -DskipTests
                    JAR_FILE=$(ls target/*.jar | head -n 1)
                    cp "$JAR_FILE" spring-petclinic
                    '''
                }
            }
        }


        stage('Docker Build UP') {
            steps {
                script {
                    sh '''
                    echo "Building Docker up"
                    docker compose up -d 
                    '''
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    echo "Building Docker image..."
                    docker build -t $DOCKER_IMAGE .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                echo "Pushing Docker image to DockerHub..."
                docker push $DOCKER_IMAGE
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Build and Docker push successful!"
        }
        failure {
            echo "❌ Build failed!"
        }
        always {
            cleanWs()
        }
    }
}
```

## Worked and Tested
```groovy
pipeline {
    agent {label params.NODE_LABEL}
    
    environment {
        COMPOSE_PROJECT_NAME = "spring-petclinic"
        DOCKER_IMAGE = "ganil151/spring-petclinic:latest"
    }
    
    parameters {
        string(
            name: 'NODE_LABEL',
            defaultValue: 'worker-node-1',
            description: 'Label of the Jenkins worker node to run this pipeline '
        )
    }
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Ganil151/spring-petclinic-microservices.git'
            }
        }
        
        stage('Install yq'){
            steps {
                script {
                    sh '''
                    if ! command -v yq &> /dev/null; then
                        echo "Installing yq..."
                        sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq
                        sudo chmod +x /usr/local/bin/yq
                    fi
                    '''
                }
            }
        }
        stage('Remove genai-service from docker-compose.yml') {
            steps {
                script {
                    sh '''
                    cp docker-compose.yml docker-compose.yml.bak
                    yq eval 'del(.services.genai-service)' -i docker-compose.yml
                    '''
                }
            }
        }
        stage('Build Application') {
            steps {
                script {
                    sh '''
                    echo "Building the Spring PetClinic application..."
                    ./mvnw clean package -DskipTests
                    '''
                }
            }
        }
        stage('Docker Login') {
            steps {
                 withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                     sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    echo "Docker Login..."
                    '''
                 }
            }
        }
        
        stage('Docker Build & Docker Push'){
            steps {
                script {
                    sh ''' 
                     echo "Docker Build & Docker Push Successfully"
                     docker build -t $DOCKER_IMAGE .
                     docker push $DOCKER_IMAGE
                     '''
                }
            }
        }
    }
}
```

##  Jenkins enforces CSRF (Cross-Site Request Forgery)
```bash
#!/bin/bash

# Jenkins credentials and URL
USERNAME="admin"
API_TOKEN="12345678abcdef"
JENKINS_URL="http://localhost:8080"
JOB_NAME="spms-pipeline-2"

# Retrieve the crumb
CRUMB=$(curl -u "$USERNAME:$API_TOKEN" "$JENKINS_URL/crumbIssuer/api/json" | jq -r '.crumb')

# Trigger the Jenkins job
curl -u "$USERNAME:$API_TOKEN" -X POST "$JENKINS_URL/job/$JOB_NAME/build" \
--header "Jenkins-Crumb: $CRUMB"
```

## Edits:
```groovy
pipeline {
    agent { label params.NODE_LABEL }
    
    environment {
        COMPOSE_PROJECT_NAME = "spring-petclinic"
        DOCKER_IMAGE = "ganil151/spring-petclinic1:latest"
    }
    
    parameters {
        string(
            name: 'NODE_LABEL',
            defaultValue: 'worker-node-1',
            description: 'Label of the Jenkins worker node to run this pipeline'
        )
    }
    
    triggers {
        githubPush()
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Ganil151/spring-petclinic-microservices.git'
            } 
        }
        
        stage('Install yq') {
            steps {
                script {
                    sh '''
                    if ! command -v yq &> /dev/null; then
                        echo "Installing yq..."
                        sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq
                        sudo chmod +x /usr/local/bin/yq
                    fi
                    '''
                }
            }
        }
        
        stage('Remove genai-service from docker-compose.yml') {
            steps {
                script {
                    sh '''
                    cp docker-compose.yml docker-compose.yml.bak
                    yq eval 'del(.services.genai-service)' -i docker-compose.yml
                    '''
                }
            }
        }
        
        stage('Docker Login') {
            steps {
                 withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                     sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    echo "Docker Login..."
                    '''
                 }
            }
        }
        
        stage('Build Application') {
            environment {
                JAVA_HOME = "/usr/lib/jvm/java-17-amazon-corretto.x86_64/"
                PATH = "${JAVA_HOME}/bin:${env.PATH}"
            }
            
            steps {
                script {
                    sh '''
                    echo "Building the Spring PetClinic application..."
                    ./mvnw clean package -DskipTests
                    
                    # Example: pick the config-server JAR
                    JAR_FILE=$(ls spring-petclinic-config-server/target/*.jar | head -n 1)
        
                    echo "Copying $JAR_FILE to docker/application.jar"
                    cp "$JAR_FILE" docker/application.jar
                    '''
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    sh '''
                    echo "Building Docker image"
                    docker compose build --no-cache
                    '''
                }
            }
        }
        
        stage('Docker Image Build') {
            steps {
                script {
                    sh '''
                    echo "Docker Image Building"
                    cd /home/ec2-user/workspace/spms-pipeline/docker
                     # Verify the .jar file
                    ls -la
                    if [ ! -f "application.jar" ]; then
                        echo "application.jar not found in the build context."
                        exit 1
                    fi
        
                    # Build the Docker image
                    docker build \\
                    --build-arg JAR_FILE=application.jar \\
                    -t $DOCKER_IMAGE \\
                    -f Dockerfile .
                    '''
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    sh '''
                    echo "Docker Push Successfully"
                    docker push $DOCKER_IMAGE
                    '''
                }
            }
        }
    }
    post {
        success {
            echo "Build and Docker push Successful!"
        }
        failure {
            echo "Build Failed"
        }
    }
}
```