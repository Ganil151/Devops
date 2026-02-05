# 01-Beginner-Level - Helm Fundamentals

## Overview
This level introduces you to Helm basics, chart creation, and fundamental concepts needed for managing Kubernetes applications using Helm.

## Prerequisites
- Basic understanding of Kubernetes concepts (Pods, Services, Deployments)
- Familiarity with command-line tools
- Access to a Kubernetes cluster (Minikube, Kind, or cloud-based)

## Learning Objectives
After completing this level, you will be able to:
- Install and configure Helm
- Understand Helm architecture and components
- Create basic Helm charts
- Deploy and manage applications using Helm
- Work with Helm repositories
- Troubleshoot basic Helm issues

## Curriculum

### Module 1: Helm Fundamentals (Week 1)
#### Topics Covered:
- What is Helm and why do we need it?
- Helm architecture (Helm v3 vs v2 differences)
- Understanding Charts, Releases, and Repositories
- Installing Helm client
- Basic Helm commands (helm install, upgrade, rollback, uninstall)

#### Hands-on Activities:
- Install Helm on your local machine
- Connect to official Helm repositories (Bitnami, Kubernetes Stable)
- Deploy a simple application using an existing chart

### Module 2: Chart Basics (Week 1-2)
#### Topics Covered:
- Chart structure and files
- Understanding Chart.yaml
- Template files (templates/ directory)
- Values files and configuration
- Creating your first simple chart

#### Hands-on Activities:
- Create a basic chart from scratch
- Customize chart values
- Package and install your chart

### Module 3: Templates and Functions (Week 2)
#### Topics Covered:
- Go templates in Helm
- Built-in template functions
- Variables in templates
- Conditionals and loops
- Common template patterns

#### Hands-on Activities:
- Enhance your chart with template functions
- Add conditional sections based on values
- Use range loops for dynamic resource creation

### Module 4: Release Management (Week 2-3)
#### Topics Covered:
- Installing releases
- Upgrading releases
- Rolling back releases
- Checking release history
- Uninstalling releases

#### Hands-on Activities:
- Perform install, upgrade, and rollback operations
- Check release status and history
- Use dry-run options

### Module 5: Helm Repositories (Week 3)
#### Topics Covered:
- Public vs Private repositories
- Adding and removing repositories
- Searching for charts
- Updating repository cache
- Setting up a simple HTTP-based repository

#### Hands-on Activities:
- Add multiple public repositories
- Search for charts in different repositories
- Create a simple web server to host your chart

### Module 6: Troubleshooting and Debugging (Week 4)
#### Topics Covered:
- Debugging with --dry-run and --debug
- Understanding common error messages
- Inspecting chart templates
- Using Helm's built-in inspection commands
- Reading logs and diagnosing issues

#### Hands-on Activities:
- Debug a chart with intentional errors
- Practice identifying common issues
- Create a troubleshooting reference guide

## Assessment
Complete the following to validate your beginner level skills:
- [ ] Create and deploy a chart with at least 3 Kubernetes resources
- [ ] Successfully install, upgrade, and rollback a release
- [ ] Add and use templates from at least 2 different public repositories
- [ ] Demonstrate proper use of values to customize installations
- [ ] Debug and fix at least 2 chart issues

## Resources
- [Official Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- Sample charts in this repository
