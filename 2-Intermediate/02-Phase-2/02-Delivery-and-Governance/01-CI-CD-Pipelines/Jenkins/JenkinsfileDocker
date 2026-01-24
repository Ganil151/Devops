pipeline {
    agent { label params.NODE_LABEL }

    environment {
        DOCKER_IMAGE = "ganil151/spring-petclinic-microservice"
        IMAGE_TAG    = "${env.BUILD_NUMBER ?: 'latest'}"
        REGION       = "us-east-1"
    }

    parameters {
        string(name: 'NODE_LABEL',        defaultValue: 'worker-node')
        string(name: 'EC2_INSTANCE_NAME', defaultValue: 'Spring-PetClinic-Docker')
        string(name: 'SSH_CREDENTIALS_ID', defaultValue: 'master_keys')
    }

    triggers { githubPush() }

    stages {

        /* ========================
         *  CHECKOUT PROJECT
         * ======================== */
        stage('Checkout') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/Ganil151/spring-petclinic-microservices.git',
                    credentialsId: 'github-credentials'
                )
            }
        }

        /* ========================
         *  BUILD JAR
         * ======================== */
        stage('Build App') {
            environment {
                JAVA_HOME = "/usr/lib/jvm/java-21-amazon-corretto"
                PATH = "${JAVA_HOME}/bin:${env.PATH}"
            }
            steps {
                sh '''
                chmod +x ./mvnw
                sed -i 's/\r$//' ./mvnw
                
                ./mvnw clean install

                JAR=$(ls spring-petclinic-config-server/target/*.jar | head -n 1)
                cp "$JAR" docker/application.jar
                '''
            }
        }

        /* ========================
         *  BUILD AND PUSH IMAGE
         * ======================== */
        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'D_USER',
                    passwordVariable: 'D_PASS')]) {

                    sh '''
                    echo "$D_PASS" | docker login -u "$D_USER" --password-stdin

                    cd docker
                    docker build -t $DOCKER_IMAGE:$IMAGE_TAG -t $DOCKER_IMAGE:latest .

                    docker push $DOCKER_IMAGE:$IMAGE_TAG
                    docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        /* ========================
         *  EC2 PROVISION + SOFTWARE INSTALL
         * ======================== */
        stage('Provision EC2 Instance') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials'],
                    [$class: 'SSHUserPrivateKeyBinding', credentialsId: params.SSH_CREDENTIALS_ID,
                        keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER']
                ]) {

                    sh '''
                    echo "Searching for EC2 instance…"
                    INSTANCE_ID=$(aws ec2 describe-instances \
                        --filters "Name=tag:Name,Values=${EC2_INSTANCE_NAME}" \
                                  "Name=instance-state-name,Values=running" \
                        --query "Reservations[0].Instances[0].InstanceId" \
                        --output text || echo "None")

                    if [ "$INSTANCE_ID" = "None" ]; then
                        echo "Creating a NEW EC2 instance..."
                        INSTANCE_ID=$(aws ec2 run-instances \
                            --image-id ami-052064a798f08f0d3 \
                            --instance-type c7i-flex.large \
                            --key-name master_keys \
                            --security-group-ids sg-00c6bccfbdec3bb9d \
                            --subnet-id subnet-0e2489f42748d00f3 \
                            --associate-public-ip-address \
                            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${EC2_INSTANCE_NAME}}]" \
                            --query "Instances[0].InstanceId" --output text)
                        echo "New instance started: $INSTANCE_ID"
                    else
                        echo "Found existing EC2 instance: $INSTANCE_ID"
                    fi

                    echo "Waiting for instance to enter running state..."
                    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

                    PUBLIC_IP=$(aws ec2 describe-instances \
                        --instance-ids $INSTANCE_ID \
                        --query "Reservations[0].Instances[0].PublicIpAddress" \
                        --output text)

                    echo "$PUBLIC_IP" > public_ip.txt
                    echo "EC2 Public IP: $PUBLIC_IP"

                    echo "===== Installing Docker, Java, Maven, Docker Compose on EC2 ====="
                    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" $SSH_USER@$PUBLIC_IP <<'EOF'

                        sudo yum update -y

                        echo "Installing Java 21..."
                        sudo yum install -y java-21-amazon-corretto-devel git

                        echo "Installing Maven..."
                        sudo yum install -y maven

                        echo "Configuring JAVA_HOME and M2_HOME..."
                        JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
                        M2_HOME="/usr/share/maven"

                        sudo bash -c 'cat << EOS > /etc/profile.d/jenkins_env.sh
export JAVA_HOME='${JAVA_HOME}'
export M2_HOME='${M2_HOME}'
export PATH=\$PATH:\$JAVA_HOME/bin:\$M2_HOME/bin
EOS'
                        sudo chmod +x /etc/profile.d/jenkins_env.sh
                        # Source the new environment for the current session
                        source /etc/profile.d/jenkins_env.sh

                        echo "Installing Docker..."
                        sudo yum install -y docker
                        sudo systemctl enable docker
                        sudo systemctl start docker
                        sudo usermod -aG docker ec2-user

                        echo "Installing Docker Compose v2..."
                        sudo mkdir -p /usr/libexec/docker/cli-plugins/
                        sudo curl -SL \
                          https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m) \
                          -o /usr/libexec/docker/cli-plugins/docker-compose
                        sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

                        # Verify installations
                        docker --version
                        docker compose version
EOF
                    '''
                }
            }
        }

        /* ========================
         *  COPY COMPOSE + DEPLOY APP
         * ======================== */
        stage('Deploy Application to EC2') {
            steps {
                withCredentials([
                    [$class: 'SSHUserPrivateKeyBinding', credentialsId: params.SSH_CREDENTIALS_ID,
                        keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER'],
                    usernamePassword(credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'D_USER', passwordVariable: 'D_PASS')
                ]) {

                    sh '''
                    PUBLIC_IP=$(cat public_ip.txt)

                    echo "Copying docker-compose.yml..."
                    scp -o StrictHostKeyChecking=no -i "$SSH_KEY" docker-compose.yml \
                        $SSH_USER@$PUBLIC_IP:~/docker-compose.yml

                    echo "Deploying on EC2..."
                    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" $SSH_USER@$PUBLIC_IP << EOF

                        # Source environment to ensure docker compose is in PATH
                        source /etc/profile.d/jenkins_env.sh
                        source ~/.bash_profile || true
                        source ~/.bashrc || true

                        echo "$D_PASS" | docker login -u "$D_USER" --password-stdin

                        echo "Pulling latest app image..."
                        docker pull ${DOCKER_IMAGE}:latest

                        echo "Deploying with Docker Compose..."
                        docker compose -f ~/docker-compose.yml pull
                        docker compose -f ~/docker-compose.yml up -d

                        echo "✔ Deployment completed on EC2"
EOF
                    '''
                }
            }
        }
    }

    post { always { echo "Pipeline finished." } }
}