### Steps

Edit Dockerfile:
```dockerfile
# Dockerfile in the `docker` directory

  

FROM eclipse-temurin:17 AS builder

WORKDIR application

# Change the build argument name to match the Jenkinsfile

ARG JAR_FILE

# Copy the JAR using the new argument

COPY ${JAR_FILE} application.jar

RUN java -Djarmode=layertools -jar application.jar extract

  
  

FROM eclipse-temurin:17

WORKDIR application

  

ARG EXPOSED_PORT

EXPOSE ${EXPOSED_PORT}

  

ENV SPRING_PROFILES_ACTIVE=docker

  

COPY --from=builder application/dependencies/ ./

RUN true

COPY --from=builder application/spring-boot-loader/ ./

RUN true

COPY --from=builder application/snapshot-dependencies/ ./

RUN true

COPY --from=builder application/application/ ./

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "application.jar", "org.springframework.boot.loader.launch.JarLauncher"]
```

Edit pom.xml file
```xml
 <plugins>

                    <plugin>

                        <groupId>org.springframework.boot</groupId>

                        <artifactId>spring-boot-maven-plugin</artifactId>

                        <executions>

                            <execution>

                                <!-- Spring Boot Actuator displays build-related information if a META-INF/build-info.properties file is present -->

                                <goals>

                                    <goal>build-info</goal>

                                </goals>

                                <configuration>

                                    <additionalProperties>

                                        <encoding.source>${project.build.sourceEncoding}</encoding.source>

                                        <encoding.reporting>${project.reporting.outputEncoding}</encoding.reporting>

                                        <java.version>${java.version}</java.version>

                                    </additionalProperties>

                                    <layers>

                                        <enabled>true</enabled>  # << ---- Here --

                                    </layers>

                                </configuration>

                            </execution>

                        </executions>

                    </plugin>
```

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