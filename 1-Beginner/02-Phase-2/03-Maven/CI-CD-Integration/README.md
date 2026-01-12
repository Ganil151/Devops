# Maven CI/CD Integration

Continuous integration and deployment patterns with Maven in various CI/CD platforms.

## Jenkins Integration

### Jenkinsfile for Maven
```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.4'
        jdk 'JDK-11'
    }
    
    environment {
        MAVEN_OPTS = '-Xmx1024m'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/user/maven-project.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'mvn verify -Pintegration-tests'
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'mvn deploy -DskipTests'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

## GitHub Actions

### Maven Workflow
```yaml
# .github/workflows/maven.yml
name: Maven CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        java-version: [11, 17]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK ${{ matrix.java-version }}
      uses: actions/setup-java@v3
      with:
        java-version: ${{ matrix.java-version }}
        distribution: 'temurin'
        cache: maven
    
    - name: Run tests
      run: mvn clean test
    
    - name: Generate test report
      uses: dorny/test-reporter@v1
      if: success() || failure()
      with:
        name: Maven Tests (JDK ${{ matrix.java-version }})
        path: target/surefire-reports/*.xml
        reporter: java-junit
  
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'
        cache: maven
    
    - name: Build application
      run: mvn clean package -DskipTests
    
    - name: Build Docker image
      run: |
        docker build -t myapp:${{ github.sha }} .
        docker tag myapp:${{ github.sha }} myapp:latest
    
    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment"
        # Add deployment commands here
```

## GitLab CI

### GitLab CI Configuration
```yaml
# .gitlab-ci.yml
image: maven:3.9.4-openjdk-11

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"
  MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version"

cache:
  paths:
    - .m2/repository/

stages:
  - validate
  - test
  - package
  - deploy

validate:
  stage: validate
  script:
    - mvn $MAVEN_CLI_OPTS validate

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test
  artifacts:
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
    paths:
      - target/site/jacoco/
  coverage: '/Total.*?([0-9]{1,3})%/'

package:
  stage: package
  script:
    - mvn $MAVEN_CLI_OPTS package -DskipTests
  artifacts:
    paths:
      - target/*.jar
    expire_in: 1 week

deploy-staging:
  stage: deploy
  script:
    - mvn $MAVEN_CLI_OPTS deploy -DskipTests -Pstaging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy-production:
  stage: deploy
  script:
    - mvn $MAVEN_CLI_OPTS deploy -DskipTests -Pproduction
  environment:
    name: production
    url: https://production.example.com
  only:
    - main
  when: manual
```

## Docker Integration

### Multi-stage Dockerfile
```dockerfile
# Multi-stage build for Maven projects
FROM maven:3.9.4-openjdk-11 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose for Development
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    depends_on:
      - database
    volumes:
      - ./target:/app/target
  
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

This guide covers comprehensive Maven CI/CD integration across multiple platforms.