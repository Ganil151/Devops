# Helm: The Kubernetes Package Manager

Helm is a powerful tool that automates the creation, packaging, configuration, and deployment of Kubernetes applications. It treats infrastructure as "Apps" rather than just YAML files.

---

## 🗺️ The Helm Learning Path

Follow these modules in order to master Kubernetes package management:

1.  **[01-Helm-Fundamentals](./01-Helm-Fundamentals/README.md)**: Core concepts, architecture (v3), and basic installation.
2.  **[02-Chart-Templating](./02-Chart-Templating/README.md)**: Master Go templates, functions, and logic to build dynamic charts.
3.  **[03-Intermediate-Helm](./03-Intermediate-Helm/README.md)**: Subcharts, dependencies, and automated CI/CD integration.
4.  **[04-Advanced-Helm](./04-Advanced-Helm/README.md)**: Enterprise governance, security best practices (SOPS), and custom plugins.
5.  **[05-Interview-Questions-and-Quizzes](./05-Interview-Questions-and-Quizzes/README.md)**: Test your knowledge and prepare for job screenings.
6.  **[06-Real-Life-Scenarios](./06-Real-Life-Scenarios/README.md)**: Practical troubleshooting, multi-env management, and private registries.

---

## 🏗️ 1. Why Helm?
- **Manage Complexity**: Package multi-resource stacks (Deployment + Service + Ingress) into a single unit.
- **Easy Updates**: Change one parameter in `values.yaml` and roll out changes cluster-wide.
- **Safety**: Built-in release history and one-command rollbacks.
- **Shareability**: Use public charts from Artifact Hub to deploy community-standard software in seconds.

---

## 🛡️ Core Best Practices
- **No Hardcoding**: Everything that might change should be a variable in `values.yaml`.
- **Semantic Versioning**: Use proper versioning (SemVer) for your charts to avoid confusion.
- **Validate Early**: Use `helm lint` and `--dry-run` in your CI pipeline.
- **Security**: Never store plain-text secrets in charts; use Helm Secrets or external vaults.

---

## ✅ Knowledge Check
- [x] Install Helm and add a repository (e.g., Bitnami).
- [x] Create a custom chart using `helm create`.
- [x] Use `helm upgrade --install` to manage an application lifecycle.
- [x] Perform a rollback to a previous release version.
- [x] Use logic (`if/else`) and loops (`range`) in a template.
- [x] Pass the 20-Question assessment in module 05.

---

## 🔗 Next Steps
- **[Kubernetes Mastery](../07-Kubernetes/)** - The foundation Helm builds upon.
- **[CI/CD Pipelines](../06-CI-CD/)** - Automate your Helm deployments.

---
*Package your power. Ship with Helm.*
