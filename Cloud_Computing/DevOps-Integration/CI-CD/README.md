# Cloud CI/CD Integration

Comprehensive guide to implementing CI/CD pipelines across cloud platforms with various tools and services.

## Multi-Cloud CI/CD Strategy
```yaml
Pipeline Components:
  Source Control:
    - GitHub, GitLab, Azure DevOps
    - Branch strategies
    - Code review processes
    - Webhook triggers

  Build Systems:
    - Jenkins (self-hosted)
    - GitHub Actions
    - Azure Pipelines
    - AWS CodeBuild
    - Google Cloud Build

  Artifact Storage:
    - Docker registries
    - Package repositories
    - Binary artifacts
    - Infrastructure templates

  Deployment Targets:
    - Kubernetes clusters
    - Serverless functions
    - Virtual machines
    - Container services
```

## GitHub Actions Multi-Cloud
```yaml
# .github/workflows/multi-cloud-deploy.yml
name: Multi-Cloud Deployment

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t myapp:${{ github.sha }} .
        
    - name: Push to AWS ECR
      env:
        AWS_REGION: us-east-1
      run: |
        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        docker tag myapp:${{ github.sha }} $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp:${{ github.sha }}
        docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/myapp:${{ github.sha }}
    
    - name: Push to Azure ACR
      run: |
        az acr login --name myregistry
        docker tag myapp:${{ github.sha }} myregistry.azurecr.io/myapp:${{ github.sha }}
        docker push myregistry.azurecr.io/myapp:${{ github.sha }}
    
    - name: Push to GCP Artifact Registry
      run: |
        gcloud auth configure-docker us-central1-docker.pkg.dev
        docker tag myapp:${{ github.sha }} us-central1-docker.pkg.dev/my-project/my-repo/myapp:${{ github.sha }}
        docker push us-central1-docker.pkg.dev/my-project/my-repo/myapp:${{ github.sha }}

  deploy-aws:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to EKS
      run: |
        aws eks update-kubeconfig --region us-east-1 --name my-cluster
        kubectl set image deployment/myapp myapp=$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/myapp:${{ github.sha }}

  deploy-azure:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to AKS
      run: |
        az aks get-credentials --resource-group myRG --name myAKSCluster
        kubectl set image deployment/myapp myapp=myregistry.azurecr.io/myapp:${{ github.sha }}

  deploy-gcp:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to GKE
      run: |
        gcloud container clusters get-credentials my-cluster --zone us-central1-a
        kubectl set image deployment/myapp myapp=us-central1-docker.pkg.dev/my-project/my-repo/myapp:${{ github.sha }}
```

## Jenkins Multi-Cloud Pipeline
```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        AZURE_RESOURCE_GROUP = 'myRG'
        GCP_PROJECT = 'my-project'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    def image = docker.build("myapp:${IMAGE_TAG}")
                    
                    // Push to multiple registries in parallel
                    parallel(
                        "AWS ECR": {
                            sh """
                                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                                docker tag myapp:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/myapp:${IMAGE_TAG}
                                docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/myapp:${IMAGE_TAG}
                            """
                        },
                        "Azure ACR": {
                            sh """
                                az acr login --name myregistry
                                docker tag myapp:${IMAGE_TAG} myregistry.azurecr.io/myapp:${IMAGE_TAG}
                                docker push myregistry.azurecr.io/myapp:${IMAGE_TAG}
                            """
                        },
                        "GCP Artifact Registry": {
                            sh """
                                gcloud auth configure-docker us-central1-docker.pkg.dev
                                docker tag myapp:${IMAGE_TAG} us-central1-docker.pkg.dev/${GCP_PROJECT}/my-repo/myapp:${IMAGE_TAG}
                                docker push us-central1-docker.pkg.dev/${GCP_PROJECT}/my-repo/myapp:${IMAGE_TAG}
                            """
                        }
                    )
                }
            }
        }
        
        stage('Deploy') {
            parallel {
                stage('Deploy to AWS') {
                    steps {
                        sh """
                            aws eks update-kubeconfig --region ${AWS_REGION} --name my-cluster
                            kubectl set image deployment/myapp myapp=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/myapp:${IMAGE_TAG}
                            kubectl rollout status deployment/myapp
                        """
                    }
                }
                
                stage('Deploy to Azure') {
                    steps {
                        sh """
                            az aks get-credentials --resource-group ${AZURE_RESOURCE_GROUP} --name myAKSCluster
                            kubectl set image deployment/myapp myapp=myregistry.azurecr.io/myapp:${IMAGE_TAG}
                            kubectl rollout status deployment/myapp
                        """
                    }
                }
                
                stage('Deploy to GCP') {
                    steps {
                        sh """
                            gcloud container clusters get-credentials my-cluster --zone us-central1-a --project ${GCP_PROJECT}
                            kubectl set image deployment/myapp myapp=us-central1-docker.pkg.dev/${GCP_PROJECT}/my-repo/myapp:${IMAGE_TAG}
                            kubectl rollout status deployment/myapp
                        """
                    }
                }
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

## GitOps with ArgoCD
```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: multi-cloud-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/k8s-manifests
    targetRevision: HEAD
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Infrastructure as Code Integration
```yaml
# Terraform with CI/CD
name: Terraform Deploy

on:
  push:
    branches: [main]
    paths: ['infrastructure/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Init
      run: terraform init
      working-directory: infrastructure
    
    - name: Terraform Plan
      run: terraform plan -out=tfplan
      working-directory: infrastructure
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve tfplan
      working-directory: infrastructure
```

This guide covers comprehensive CI/CD integration strategies across multiple cloud platforms.