Pull Java 
```bash
[root@master-server ~]# which java
/usr/bin/java
[root@master-server ~]# readlink -f $(which java)
/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java
```

Copy SSH Key from master to worker
```bash
ssh-copy-id <user-name@public-ip>
```

Plugins

Credentials
> **⚠️ Missing Image**: *alt text* ('Image/Screenshot%20(195').png)

---- Jenkins Test Job ----
```groovy
pipeline {
    agent { label params.NODE_LABEL }

    environment {
        COMPOSE_PROJECT_NAME = "spring-petclinic"
        DOCKER_IMAGE         = "ganil151/spring-petclinic-microservice:latest"
    }

    parameters {
        string(
            name: 'NODE_LABEL',
            defaultValue: 'worker-node-1',
            description: 'Label of the Jenkins worker node to run this pipeline'
        )
        string(
            name: 'EC2_INSTANCE_NAME',
            defaultValue: 'spring-petclinic-ec2',
            description: 'Name tag for the EC2 instance'
        )
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Ganil151/spring-petclinic-microservices.git'
                )
            }
            post {
                always {
                    echo "========Checkout========"
                }
                success {
                    echo "========Checkout ⭐Successfully⭐========"
                }
                failure {
                    echo "========Checkout failed❌========"
                }
            }
        }

        stage('Install yq') {
            steps {
                sh '''
                if ! command -v yq &> /dev/null; then
                    echo "Installing yq..."
                    sudo wget https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64 -O /usr/local/bin/yq
                    sudo chmod +x /usr/local/bin/yq
                fi
                '''
            }
            post {
                always {
                    echo "========Install yq========"
                }
                success {
                    echo "========Install yq ⭐Successfully⭐========"
                }
                failure {
                    echo "========Install yq failed❌========"
                }
            }
        }

        stage('Remove genai-service from docker-compose.yml') {
            steps {
                sh '''
                cp docker-compose.yml docker-compose.yml.bak
                yq eval 'del(.services.genai-service)' -i docker-compose.yml
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    echo "Docker Login Successful..."
                    '''
                }
            }
            post {
                always {
                    echo "========Docker Login========"
                }
                success {
                    echo "========Docker Login ⭐Successfully⭐========"
                }
                failure {
                    echo "========Docker Login failed❌========"
                }
            }
        }

        stage('Build Application') {
            environment {
                JAVA_HOME = "/usr/lib/jvm/java-21-amazon-corretto"
                PATH = "${JAVA_HOME}/bin:${env.PATH}"
            }
            steps {
                script {
                    try {
                        sh '''
                        echo "Building the Spring PetClinic application..."
                        ./mvnw clean install

                        JAR_FILE=$(ls spring-petclinic-config-server/target/*.jar | head -n 1)

                        echo "Copying $JAR_FILE to docker/application.jar"
                        cp "$JAR_FILE" docker/application.jar
                        '''
                    } catch (err) {
                        echo "Build failed: ${err}"
                        error("Stopping pipeline")
                    }
                }
            }
            post {
                always {
                    echo "========Build Application========"
                }
                success {
                    echo "========Build Application ⭐Successfully⭐========"
                }
                failure {
                    echo "========Build Application failed❌========"
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                sh '''
                echo "Building and Pushing Docker Image..."
                cd docker

                ls -la
                if [ ! -f "application.jar" ]; then
                    echo "application.jar not found in the build context."
                    exit 1
                fi

                docker build \
                  --build-arg JAR_FILE=application.jar \
                  -t $DOCKER_IMAGE \
                  -f Dockerfile .

                docker push $DOCKER_IMAGE
                '''
            }
            post {
                always {
                    echo "========Docker Build and Push========"
                }
                success {
                    echo "========Docker Build and Push ⭐Successfully⭐========"
                }
                failure {
                    echo "========Docker Build and Push failed❌========"
                }
            }
        }

        stage('EC2 Provisioning') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        sh '''
                        echo "Checking if EC2 Instance already exists..."
                        INSTANCE_ID=$(aws ec2 describe-instances \
                          --filters "Name=tag:Name,Values=${EC2_INSTANCE_NAME}" "Name=instance-state-name,Values=running" \
                          --query "Reservations[0].Instances[0].InstanceId" \
                          --output text)

                        if [ "$INSTANCE_ID" == "None" ]; then
                          echo "No existing instance found. Launching a new EC2 instance..."
                          INSTANCE_ID=$(aws ec2 run-instances \
                            --image-id ami-00ca32bbc84273381 \
                            --instance-type t3.small \
                            --key-name sis_keys \
                            --security-group-ids sg-05ca6243c057b95fe \
                            --subnet-id subnet-07d92cb4846fd94a3 \
                            --associate-public-ip-address \
                            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${EC2_INSTANCE_NAME}}]" \
                            --query "Instances[0].InstanceId" \
                            --output text)
                          echo "Launched new EC2 Instance: $INSTANCE_ID"
                        else
                          echo "Using existing EC2 Instance: $INSTANCE_ID"
                        fi

                        aws ec2 wait instance-running --instance-ids $INSTANCE_ID

                        PUBLIC_IP=$(aws ec2 describe-instances \
                          --instance-ids $INSTANCE_ID \
                          --query "Reservations[0].Instances[0].PublicIpAddress" \
                          --output text)

                        echo "EC2 Instance is running at $PUBLIC_IP"
                        echo $PUBLIC_IP > public_ip.txt
                        '''
                    }
                }
            }
            post {
                always {
                    echo "======= EC2 Provisioning ======="
                }
                success {
                    echo "======= EC2 Provisioning ⭐Successfully⭐========"
                }
                failure {
                    echo "======= EC2 Provisioning failed❌========"
                }
            }
        }

        stage('Configure EC2 & Pull Image') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    withCredentials([
                        sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY'),
                        usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                    ]) {
                        sh '''
                        PUBLIC_IP=$(cat public_ip.txt)

                        echo "Copying docker-compose.yml to EC2..."
                        scp -i $SSH_KEY -o StrictHostKeyChecking=no docker-compose.yml ec2-user@$PUBLIC_IP:/home/ec2-user/

                        echo "SSH into $PUBLIC_IP to configure..."
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$PUBLIC_IP 
                          set -e
                          echo "Updating packages & installing Docker..."
                          sudo yum update -y
                          sudo yum install -y docker

                          echo "Configure Docker..."
                          sudo systemctl enable docker
                          sudo usermod -aG docker ec2-user
                          sudo systemctl start docker

                          echo "Installing Docker Compose..."
                          mkdir -p ~/.docker/cli-plugins/
                          curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
                            -o ~/.docker/cli-plugins/docker-compose
                          chmod +x ~/.docker/cli-plugins/docker-compose

                          echo "Login to Docker Hub..."
                          echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin

                          echo "Starting application with Docker Compose..."
                          cd /home/ec2-user/
                          sudo docker compose build
                          sudo docker compose up -d
                        
                        '''
                    }
                }
            }
            post {
                always {
                    echo "======= EC2 Configure & Pull Image ======="
                }
                success {
                    echo "======= EC2 Configure & Pull Image ⭐Successfully⭐========"
                }
                failure {
                    echo "======= EC2 Configure & Pull Image failed❌========"
                }
            }
        }

    }

    post {
        always {
            echo "========always========"
        }
        success {
            echo "✅ Build, Docker push, and EC2 deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed"
        }
    }
}
```

--- 

---- Ansible Script ----
```yaml
#!/bin/bash
set -e

echo "Changing Host Name..."
sudo hostnamectl set-hostname "ansible-server"

echo "Updating system..."
sudo yum -y update && sudo yum -y upgrade

# Install Ansible
echo "Installing Ansible..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils
echo "Ansible installed successfully!"

# Add New User
echo "Adding new user..."
sudo useradd -m -s /bin/bash ansadmin
echo "Enter password for ansadmin:"
sudo passwd ansadmin
echo "ansadmin user added successfully!"
echo "Adding ansadmin to sudoers..."
echo "ansadmin ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
echo "ansadmin added to sudoers successfully!"
echo "Adding ansadmin to wheel group..."
sudo usermod -aG wheel ansadmin
echo "ansadmin added to wheel group successfully!"
echo "Adding ansadmin to docker group..."

# Su into Ansible User
echo "Logging in as ansadmin..."
sudo su - ansadmin
echo "ansadmin logged in successfully!"
echo "Adding ansadmin to docker group..." 

# Install Docker /opt/docker 
cd /opt/docker 

# Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
echo "Docker installed successfully!"

# Configure Docker User
echo "Configuring Docker user..."
sudo usermod -aG docker ansadmin
sudo systemctl restart docker


```



---

----Volume Increase Script----
```bash
#!/bin/bash

set -e

# Change Host Name
echo "Change Host Name"
sudo hostnamectl set-hostname "master-server"

# Install dependencies
echo "Install dependencies"
sudo yum update -y

# Then install Java JDK
sudo yum install -y java-21-amazon-corretto-devel git

# Configure Java
echo "Configure Java"
JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a ~/.bashrc
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a ~/.bashrc

# Install Jenkins 
echo "Install Jenkins"
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo  

# Then Import Key:
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key  
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo  

# Now Install Jenkins
sudo yum install -y jenkins

# Configure Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Configure Java in Jenkins
echo "Configure Java"
sudo touch /var/lib/jenkins/.bash_profile
sudo chown jenkins:jenkins /var/lib/jenkins/.bash_profile
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
source /var/lib/jenkins/.bash_profile

# Configure SSH for Jenkins user
echo "Generating SSH key for Jenkins..."
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh
sudo chmod 600 /var/lib/jenkins/.ssh/id_rsa
sudo chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub

# Create known_hosts file
sudo touch /var/lib/jenkins/.ssh/known_hosts
sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Increase /tmp file
echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Increase the root volume size
echo "Increasing root volume size..."

# Step 1: Get the current root volume ID
ROOT_VOLUME_ID=$(aws ec2 describe-volumes \
    --filters Name=attachment.instance-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) \
    --query "Volumes[?Attachments[0].Device=='/dev/xvda'].VolumeId" \
    --output text)

if [ -z "$ROOT_VOLUME_ID" ]; then
    echo "Failed to retrieve root volume ID."
    exit 1
fi

echo "Root volume ID: $ROOT_VOLUME_ID"

# Step 2: Modify the volume size (e.g., increase to 50 GB)
NEW_SIZE=50
aws ec2 modify-volume --volume-id $ROOT_VOLUME_ID --size $NEW_SIZE

# Step 3: Wait for the volume modification to complete
echo "Waiting for volume modification to complete..."
aws ec2 wait volume-modified --volume-ids $ROOT_VOLUME_ID

# Step 4: Extend the file system to use the new size
echo "Extending the file system..."
sudo growpart /dev/xvda 1
sudo xfs_growfs -d /

echo "Root volume increased and file system extended successfully."
echo "Setup completed successfully."
```