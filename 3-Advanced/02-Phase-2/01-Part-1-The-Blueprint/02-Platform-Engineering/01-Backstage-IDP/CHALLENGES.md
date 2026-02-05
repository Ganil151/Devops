# 🏆 Backstage IDP Challenges

Master the creation of Internal Developer Portals (IDP) and the "Golden Path" for development teams.

---

## 🏗️ Challenge 01: The "Service Catalog" Onboarding
**Objective**: Build a single pane of glass for all technical assets.

1.  **Requirement**: Your company has 50 repos across various teams. No one knows who owns what.
2.  **Task**: Define a `catalog-info.yaml` for a sample service that includes:
    *   `kind: Component`
    *   `spec.owner`: defined team.
    *   `spec.system`: the parent architecture.
    *   `spec.lifecycle`: (Experimental/Production).
3.  **Discovery**: How does Backstage use Git as the source of truth for this catalog?
4.  **Verification**: Confirm the service appears in the Backstage search and shows its documentation (TechDocs).

---

## 🚀 Challenge 02: Software Templates (The "Golden Path")
**Objective**: Eliminate "Copy-Paste" microservice creation.

1.  **Goal**: Create a template that scaffolds a new Python FastAPI service with a Dockerfile and CI pipeline.
2.  **Task**: Write a Backstage `Scaffolder` template (`template.yaml`).
3.  **Requirement**: The template must ask for:
    *   `Name`
    *   `Description`
    *   `GitHub Repo Destination`.
4.  **Action**: Use the `publish:github` action to automatically create the repo and push the initial code.
5.  **Discovery**: How do you enforce security standards (e.g., adding `CODEOWNERS` automatically) through the template?

---

## 📊 Challenge 03: The "Cost Transparency" Plugin
**Objective**: Surface FinOps data directly to the developer.

1.  **Scenario**: Developers are accidentally deploying expensive nodes.
2.  **Task**: Use the Backstage **Cost Insights** plugin.
3.  **Action**: Mock data showing the monthly spend for "Service A."
4.  **Discovery**: Why is it more effective to show costs in the Developer Portal rather than a separate monthly billing report?

---

## 📁 Solutions
Sample `catalog-info.yaml` and Scaffolder templates are located in the `Boilerplates/` directory.
