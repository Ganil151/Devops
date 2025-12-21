pipeline {
    agent { label 'worker-node-2' }

    environment {
        DOCKER_IMAGE = "ganil151/spring-petclinic-microservice"
        IMAGE_TAG = "latest"
        DOCKER_HUB_CREDENTIALS_ID = "dockerhub-credentials"
        SSH_CREDENTIALS_ID = "master_keys"
        REMOTE_USER = "ec2-user"
        HEALTH_URL_PATH = "/actuator/health"
    }

    parameters {
        string(
            name: 'EC2_INSTANCE_NAME',
            defaultValue: 'Spring-PetClinic-Docker',
            description: 'Name of the Docker-Server EC2 instance'
        )
    }

    stages {

        /* -----------------------------------------------------
           DISCOVER DOCKER SERVER PUBLIC IP
        ------------------------------------------------------ */
        stage('Find Docker-Server IP') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        env.DOCKER_SERVER_IP = sh(
                            script: """
                                INSTANCE_ID=\$(aws ec2 describe-instances \
                                    --filters "Name=tag:Name,Values=${EC2_INSTANCE_NAME}" \
                                             "Name=instance-state-name,Values=running" \
                                    --query "Reservations[0].Instances[0].InstanceId" \
                                    --output text)

                                if [ "\$INSTANCE_ID" = "None" ] || [ -z "\$INSTANCE_ID" ]; then
                                    echo "ERROR: EC2 instance not found." >&2
                                    exit 1
                                fi

                                PUBLIC_IP=\$(aws ec2 describe-instances \
                                    --instance-ids "\$INSTANCE_ID" \
                                    --query "Reservations[0].Instances[0].PublicIpAddress" \
                                    --output text)

                                if [ "\$PUBLIC_IP" = "None" ] || [ -z "\$PUBLIC_IP" ]; then
                                    echo "ERROR: EC2 instance has no public IP." >&2
                                    exit 1
                                fi

                                echo "\$PUBLIC_IP"
                            """,
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        /* -----------------------------------------------------
           BLUE/GREEN DEPLOYMENT
        ------------------------------------------------------ */
        stage('Blue/Green Deployment') {
            steps {
                script {

                    withCredentials([
                        usernamePassword(
                            credentialsId: env.DOCKER_HUB_CREDENTIALS_ID,
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'),
                        sshUserPrivateKey(
                            credentialsId: env.SSH_CREDENTIALS_ID,
                            keyFileVariable: 'SSH_KEY')
                    ]) {
                        sh '''#!/bin/bash
echo "Deploying to ${DOCKER_SERVER_IP}..."

ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ${REMOTE_USER}@${DOCKER_SERVER_IP} << 'EOF'

echo "Logging in to Docker Hub..."
echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin

# Determine active color
if docker ps --format '{{.Names}}' | grep -q '^spring-petclinic-blue$'; then
    ACTIVE_COLOR="blue"
    IDLE_COLOR="green"
elif docker ps --format '{{.Names}}' | grep -q '^spring-petclinic-green$'; then
    ACTIVE_COLOR="green"
    IDLE_COLOR="blue"
else
    ACTIVE_COLOR="none"
    IDLE_COLOR="blue"
fi

echo "Active: $ACTIVE_COLOR"
echo "Idle: $IDLE_COLOR"

docker pull ${DOCKER_IMAGE}:${IMAGE_TAG}

docker rm -f spring-petclinic-$IDLE_COLOR || true

docker run -d --restart unless-stopped \
    -p 8081:8080 \
    --name spring-petclinic-$IDLE_COLOR \
    ${DOCKER_IMAGE}:${IMAGE_TAG}

echo "Waiting for health check..."

for i in {1..20}; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/)
    if [ "$STATUS" = "200" ]; then
        echo "Health check PASSED (HTTP 200)."
        HEALTHY=true
        break
    fi
    echo "Waiting for app to become healthy... ($i/20)"
    sleep 3
done

if [ "$HEALTHY" != "true" ]; then
    echo "Health check failed."
    docker rm -f spring-petclinic-$IDLE_COLOR
    exit 1
fi

echo "Health check successful."
echo "Promoting $IDLE_COLOR..."
docker rm -f spring-petclinic || true
docker rm -f spring-petclinic-$ACTIVE_COLOR || true
docker rename spring-petclinic-$IDLE_COLOR spring-petclinic
docker image prune -f

EOF
'''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment SUCCESSFUL → http://${env.DOCKER_SERVER_IP}:8080"
        }
        failure {
            echo "Deployment FAILED — Blue/Green rollback handled safely."
        }
    }
}
