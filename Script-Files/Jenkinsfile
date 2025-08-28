pipeline {
    agent { label params.NODE_LABEL }

    environment {
        COMPOSE_PROJECT_NAME = "spring-petclinic"
    }

    parameters {
        string(
            name: 'NODE_LABEL',
            defaultValue: 'worker-node-1',
            description: 'Label of the Jenkins worker node to run this pipeline'
        )
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

        stage('Build Images') {
            steps {
                script {
                    sh 'docker compose build'
                }
            }
        }

        stage('Start Services') {
            steps {
                script {
                    sh 'docker compose up -d'
                }
            }
        }

        stage('Verify Running Containers') {
            steps {
                script {
                    sh 'docker ps --format "table {{.Names}}\t{{.Status}}"'
                }
            }
        }

        stage('Check Service Health') {
            steps {
                script {
                    sh '''
                    echo "Checking Config Server..."
                    curl -s http://localhost:8888/actuator/health

                    echo "Checking Discovery Server..."
                    curl -s http://localhost:8761

                    echo "Checking API Gateway..."
                    curl -s http://localhost:8080/actuator/health
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'docker compose down -v'
            }
        }
    }
}