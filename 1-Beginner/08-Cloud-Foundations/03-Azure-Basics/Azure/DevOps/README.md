# Azure DevOps

Comprehensive guide to Azure DevOps services including Pipelines, Repos, and deployment strategies.

## Azure DevOps Services
```yaml
Core Services:
  - Azure Repos: Git repositories
  - Azure Pipelines: CI/CD automation
  - Azure Boards: Work item tracking
  - Azure Test Plans: Testing tools
  - Azure Artifacts: Package management
```

## Azure Pipelines
```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'

    - task: DotNetCoreCLI@2
      displayName: 'Build application'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

    - task: DotNetCoreCLI@2
      displayName: 'Run tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --collect "Code coverage"'

    - task: DotNetCoreCLI@2
      displayName: 'Publish application'
      inputs:
        command: 'publish'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'

    - task: PublishBuildArtifacts@1
      displayName: 'Publish artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop'

- stage: Deploy
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployToAzure
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            displayName: 'Deploy to Azure Web App'
            inputs:
              azureSubscription: 'Azure-Connection'
              appType: 'webApp'
              appName: 'mywebapp'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'
```

## Infrastructure as Code
```yaml
# ARM Template deployment
- task: AzureResourceManagerTemplateDeployment@3
  displayName: 'Deploy ARM Template'
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: 'Azure-Connection'
    subscriptionId: '$(subscriptionId)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: 'East US'
    templateLocation: 'Linked artifact'
    csmFile: 'infrastructure/template.json'
    csmParametersFile: 'infrastructure/parameters.json'
    deploymentMode: 'Incremental'
```

## Container Deployment
```yaml
# Docker build and push
- task: Docker@2
  displayName: 'Build and push Docker image'
  inputs:
    containerRegistry: 'myContainerRegistry'
    repository: 'myapp'
    command: 'buildAndPush'
    Dockerfile: '**/Dockerfile'
    tags: |
      $(Build.BuildId)
      latest

# Deploy to AKS
- task: KubernetesManifest@0
  displayName: 'Deploy to AKS'
  inputs:
    action: 'deploy'
    kubernetesServiceConnection: 'aks-connection'
    namespace: 'production'
    manifests: |
      k8s/deployment.yaml
      k8s/service.yaml
    containers: 'myregistry.azurecr.io/myapp:$(Build.BuildId)'
```

This guide covers Azure DevOps for continuous integration and deployment automation.