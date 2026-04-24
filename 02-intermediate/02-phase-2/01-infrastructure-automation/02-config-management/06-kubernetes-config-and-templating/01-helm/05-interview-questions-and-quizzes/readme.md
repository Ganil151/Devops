# Helm Interview Questions & Quiz

Solidify your chart management skills and prepare for technical interviews.

---

## 🎤 Top 20 Helm Interview Questions

<b>1. </b>
<details>
<summary>Show Answer</summary>
Answer: * Helm automates the creation, packaging, configuration, and deployment of Kubernetes applications. Just like `apt` or `npm`, it allows you to install complex software stacks with a single command.
</details>


<b>2. </b>
<details>
<summary>Show Answer</summary>
Answer: * A collection of files that describe a related set of Kubernetes resources. It consists of a `Chart.yaml` (metadata), `values.yaml` (configuration), and a `templates/` directory (manifests).
</details>


<b>3. </b>
<details>
<summary>Show Answer</summary>
Answer: * A release is an instance of a chart running in a Kubernetes cluster. Every time you install a chart, a new release is created.
</details>


<b>4. </b>
<details>
<summary>Show Answer</summary>
Answer: * Helm 3 removed **Tiller** (the server-side component), significantly improving security. It also introduced better release management and JSON schema validation.
</details>


<b>5. </b>
<details>
<summary>Show Answer</summary>
Answer: * It provides the default configuration values for a chart. Users can override these values during installation using `--set` or their own YAML files.
</details>


<b>6. </b>
<details>
<summary>Show Answer</summary>
Answer: * Using the syntax `{{ .Values.keyName }}`.
</details>


<b>7. </b>
<details>
<summary>Show Answer</summary>
Answer: * It's used to define reusable Go template snippets (named templates) that can be included in multiple manifest files.
</details>


<b>8. </b>
<details>
<summary>Show Answer</summary>
Answer: * `include` allows you to pass the output of a template through other functions (like `nindent`), whereas `template` cannot be used in a pipeline.
</details>


<b>9. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use **Helm Secrets** (with SOPS), or store secrets in an external vault (Vault, Secrets Manager) and inject them at runtime. Never hardcode secrets in `values.yaml`.
</details>


<b>10. </b>
<details>
<summary>Show Answer</summary>
Answer: * It stands for "newline + indent." It starts the output on a new line and indents it by the specified number of spaces, which is essential for valid YAML formatting.
</details>


<b>11. </b>
<details>
<summary>Show Answer</summary>
Answer: * A chart that is nested inside another chart to handle dependencies (e.g., a "Web-App" chart that includes a "PostgreSQL" subchart).
</details>


<b>12. </b>
<details>
<summary>Show Answer</summary>
Answer: * Run `helm rollback <release-name> <revision-number>`.
</details>


<b>13. </b>
<details>
<summary>Show Answer</summary>
Answer: * A type of chart that provides useful helper functions and templates but cannot be installed on its own.
</details>


<b>14. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use `helm lint` and `helm install --dry-run --debug`.
</details>


<b>15. </b>
<details>
<summary>Show Answer</summary>
Answer: * It locks the versions of your dependencies to ensure consistent and reproducible deployments.
</details>


<b>16. </b>
<details>
<summary>Show Answer</summary>
Answer: * Use `helm repo add`, `helm repo update`, and `helm repo index` (to create a repo).
</details>


<b>17. </b>
<details>
<summary>Show Answer</summary>
Answer: * A public central repository for finding, installing, and sharing Kubernetes packages (Helm charts, operators, etc.).
</details>


<b>18. </b>
<details>
<summary>Show Answer</summary>
Answer: * Install -> Upgrade -> Rollback (optional) -> Uninstall.
</details>


<b>19. </b>
<details>
<summary>Show Answer</summary>
Answer: * It allows you to evaluate a string as a Go template. This is useful for processing values that contain template logic themselves.
</details>


<b>20. </b>
<details>
<summary>Show Answer</summary>
Answer: * By using the Helm CLI in build stages to package charts, push to registries, and run `helm upgrade --install` during deployment phases.
</details>


---

## 🧠 Helm Knowledge Quiz

<b>1. Which file contains the metadata (name, version) of a chart?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>2. Which Helm command is used to see the configuration values of a deployed release?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>3. What is the correct way to install a chart and automatically give the release a name?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>4. How do you override a value from the command line?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>5. Which directory contains the Kubernetes manifests?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>6. To revert to the previous version of a release, you run:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>7. In Helm 3, where is the release state stored by default?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>8. Which command checks your chart for potential issues/best practices?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>9. What is a "partial" or "named template" started with in `_helpers.tpl`?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>10. To download dependencies defined in `Chart.yaml`, you run:</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>11. Which function is used to handle YAML indentation in templates?</b>
<details>
<summary>Show Answer</summary>
Answer: C (and B, but C is preferred for newlines)
</details>


<b>12. What does `helm upgrade --install` do?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>13. A `.tgz` file in Helm terms is:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>14. What is the first version of Helm that did NOT require Tiller?</b>
<details>
<summary>Show Answer</summary>
Answer: C
</details>


<b>15. To see the history of a release, you run:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>16. Which value is automatically injected by Helm into every template?</b>
<details>
<summary>Show Answer</summary>
Answer: D
</details>


<b>17. How do you delete a release but keep the history?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>18. What is the purpose of `tests/` directory in a chart?</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>19. `helm repo index` is used when:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


<b>20. The `|` character in a template (e.g., `{{ .Value | upper }}`) is a:</b>
<details>
<summary>Show Answer</summary>
Answer: B
</details>


---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Helm 2 and Helm 3