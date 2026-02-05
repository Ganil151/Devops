# 🏁 Backstage IDP Challenge Solutions

Internal Developer Portal (IDP) manifests and templates for a standardized corporate "Golden Path".

---

## 🏗️ Challenge 01: The "Service Catalog" Onboarding

### Example `catalog-info.yaml`

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: payment-gateway-api
  description: Core microservice handling external payment provider integrations.
  annotations:
    github.com/project-slug: internal/payment-gateway
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: fintech-team
  system: payment-ecosystem
```

---

## 🚀 Challenge 02: Software Templates (The "Golden Path")

### Backstage Scaffolder Template (`template.yaml`)

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: fastapi-microservice-template
  title: Standard FastAPI Microservice
  description: Scaffolds a Python FastAPI service with Docker and CI/CD.
spec:
  owner: platform-eng
  type: service

  parameters:
    - title: Provide service details
      properties:
        name:
          title: Name
          type: string
          description: Unique name of the service.
        description:
          title: Description
          type: string
        repoUrl:
          title: GitHub Repository Location
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com

  steps:
    - id: fetch-base
      name: Fetch Skeleton
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}

    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        description: ${{ parameters.description }}
        repoUrl: ${{ parameters.repoUrl }}

    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.remoteUrl }}
        catalogInfoPath: '/catalog-info.yaml'
```

---

## 📊 Challenge 03: The "Cost Transparency" Plugin

### Cost Oversight Integration
To enable the **Cost Insights** plugin, add the following to your `app-config.yaml`:

```yaml
costInsights:
  engineerCost: 200000
  products:
    awsItest:
      name: AWS Test Env
      icon: aws
    compute:
      name: Compute Engine
      icon: compute
```

**Discovery**: Showing costs in the Developer Portal shifts accountability "left." Developers see the financial impact of their architectural decisions during the development phase, rather than receiving a surprise bill from Finance weeks later.
