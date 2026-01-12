# 02-Intermediate-Level - Advanced Helm Concepts

## Overview
This level builds on Helm fundamentals, focusing on advanced chart templating, security, and CI/CD integration for complex Kubernetes applications.

## Prerequisites
- Completion of 01-Beginner-Level
- Understanding of Kubernetes advanced concepts
- Experience with Git and CI/CD pipelines

## Learning Objectives
After completing this level, you will be able to:
- Create complex, reusable Helm chart templates
- Implement security best practices
- Integrate Helm with CI/CD pipelines
- Test and validate charts effectively
- Manage chart dependencies

## Curriculum

### Module 1: Advanced Templates (Week 1-2)
#### Topics Covered:
- Complex template functions and operations
- Named templates and template composition
- Advanced control structures
- Helm template helpers
- Chart testing and linting

#### Hands-on Activities:
- Create reusable named templates
- Implement complex conditional logic
- Use advanced Helm functions
- Set up testing with ct (chart testing)

### Module 2: Chart Dependencies and Subcharts (Week 2-3)
#### Topics Covered:
- Managing chart dependencies in Chart.yaml
- Using and creating subcharts
- Dependency updates and versioning
- Alias and dependency conditions
- Chart repositories for dependencies

#### Hands-on Activities:
- Create a parent chart with subcharts
- Implement dependency management
- Use aliases for multiple instances of same chart
- Version dependencies properly

### Module 3: Security Best Practices (Week 3-4)
#### Topics Covered:
- RBAC configuration in charts
- Secrets management
- Image security and scanning
- Network policies
- Security scanning tools integration

#### Hands-on Activities:
- Create security-aware charts
- Implement proper RBAC rules
- Integrate security scanning in deployment
- Configure network policies

### Module 4: CI/CD Integration (Week 4-5)
#### Topics Covered:
- GitLab CI/CD with Helm
- GitHub Actions for Helm
- Automated chart testing and publishing
- Deployment strategies (blue-green, canary)
- GitOps with Helm

#### Hands-on Activities:
- Set up automated chart publishing
- Implement deployment pipelines
- Configure automated security scanning
- Set up GitOps deployment

### Module 5: Chart Testing and Validation (Week 5-6)
#### Topics Covered:
- Unit testing for Helm templates
- Integration testing of releases
- Linting and formatting
- Pre-commit hooks for charts
- Quality gates for releases

#### Hands-on Activities:
- Write template unit tests
- Set up chart linting pipeline
- Implement quality gates
- Create test suite for chart

### Module 6: Advanced Configuration Management (Week 6)
#### Topics Covered:
- Complex values management
- Environment-specific configurations
- Secrets vs configmaps
- External configuration sources
- Chart documentation

#### Hands-on Activities:
- Create environment-specific values
- Implement external configuration
- Document your charts properly
- Create comprehensive values schema

## Assessment
Complete the following to validate your intermediate level skills:
- [ ] Create a complex chart with subcharts and dependencies
- [ ] Implement security best practices in a production-like chart
- [ ] Set up automated CI/CD pipeline with testing
- [ ] Demonstrate advanced templating techniques
- [ ] Create comprehensive chart documentation

## Resources
- [Helm Security Guide](https://helm.sh/docs/topics/security/)
- [Chart Testing](https://github.com/helm/chart-testing)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- CI/CD platform documentation
