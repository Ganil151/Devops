# Helm Interview Questions & Quiz

Solidify your chart management skills and prepare for technical interviews.

---

## 🎤 Top 20 Helm Interview Questions

### 🔰 Basics
1. **What is Helm and why is it called the "Kubernetes Package Manager"?**
   - *Answer:* Helm automates the creation, packaging, configuration, and deployment of Kubernetes applications. Just like `apt` or `npm`, it allows you to install complex software stacks with a single command.
2. **What is a Helm Chart?**
   - *Answer:* A collection of files that describe a related set of Kubernetes resources. It consists of a `Chart.yaml` (metadata), `values.yaml` (configuration), and a `templates/` directory (manifests).
3. **What is a "Release" in Helm?**
   - *Answer:* A release is an instance of a chart running in a Kubernetes cluster. Every time you install a chart, a new release is created.
4. **Explain the difference between Helm 2 and Helm 3.**
   - *Answer:* Helm 3 removed **Tiller** (the server-side component), significantly improving security. It also introduced better release management and JSON schema validation.
5. **What is the purpose of `values.yaml`?**
   - *Answer:* It provides the default configuration values for a chart. Users can override these values during installation using `--set` or their own YAML files.

### ⚙️ Templating & Logic
6. **How do you access a value from `values.yaml` in a template?**
   - *Answer:* Using the syntax `{{ .Values.keyName }}`.
7. **What is the `_helpers.tpl` file used for?**
   - *Answer:* It's used to define reusable Go template snippets (named templates) that can be included in multiple manifest files.
8. **What does the `include` function do vs. `template`?**
   - *Answer:* `include` allows you to pass the output of a template through other functions (like `nindent`), whereas `template` cannot be used in a pipeline.
9. **How do you handle secrets in Helm?**
   - *Answer:* Use **Helm Secrets** (with SOPS), or store secrets in an external vault (Vault, Secrets Manager) and inject them at runtime. Never hardcode secrets in `values.yaml`.
10. **Explain the `nindent` function.**
    - *Answer:* It stands for "newline + indent." It starts the output on a new line and indents it by the specified number of spaces, which is essential for valid YAML formatting.

### 🚀 Advanced Ops
11. **What is a "Subchart"?**
    - *Answer:* A chart that is nested inside another chart to handle dependencies (e.g., a "Web-App" chart that includes a "PostgreSQL" subchart).
12. **How do you rollback a failed release?**
    - *Answer:* Run `helm rollback <release-name> <revision-number>`.
13. **What is the "Library Chart"?**
    - *Answer:* A type of chart that provides useful helper functions and templates but cannot be installed on its own.
14. **How do you verify your chart for syntax errors before installing?**
    - *Answer:* Use `helm lint` and `helm install --dry-run --debug`.
15. **What is the "Chart.lock" file?**
    - *Answer:* It locks the versions of your dependencies to ensure consistent and reproducible deployments.
16. **How do you manage Helm repositories?**
    - *Answer:* Use `helm repo add`, `helm repo update`, and `helm repo index` (to create a repo).
17. **What is "Artifact Hub"?**
    - *Answer:* A public central repository for finding, installing, and sharing Kubernetes packages (Helm charts, operators, etc.).
18. **Explain the lifecycle of a Helm release.**
    - *Answer:* Install -> Upgrade -> Rollback (optional) -> Uninstall.
19. **What is the `tpl` function?**
    - *Answer:* It allows you to evaluate a string as a Go template. This is useful for processing values that contain template logic themselves.
20. **How do you use Helm in a CI/CD pipeline?**
    - *Answer:* By using the Helm CLI in build stages to package charts, push to registries, and run `helm upgrade --install` during deployment phases.

---

## 🧠 Helm Knowledge Quiz

**1. Which file contains the metadata (name, version) of a chart?**
- A) values.yaml
- B) Chart.yaml
- C) metadata.yaml
- D) package.json
*Answer: B*

**2. Which Helm command is used to see the configuration values of a deployed release?**
- A) `helm list`
- B) `helm show values`
- C) `helm get values`
- D) `helm describe release`
*Answer: C*

**3. What is the correct way to install a chart and automatically give the release a name?**
- A) `helm install my-release ./my-chart`
- B) `helm install --generate-name ./my-chart`
- C) Both A and B
- D) Neither
*Answer: C*

**4. How do you override a value from the command line?**
- A) `--value key=val`
- B) `--set key=val`
- C) `--config key=val`
- D) `--env key=val`
*Answer: B*

**5. Which directory contains the Kubernetes manifests?**
- A) `manifests/`
- B) `k8s/`
- C) `templates/`
- D) `base/`
*Answer: C*

**6. To revert to the previous version of a release, you run:**
- A) `helm undo`
- B) `helm rollback`
- C) `helm revert`
- D) `helm fix`
*Answer: B*

**7. In Helm 3, where is the release state stored by default?**
- A) In the Tiller server
- B) In an etcd database
- C) In Kubernetes Secrets in the release namespace
- D) On the local workstation disk
*Answer: C*

**8. Which command checks your chart for potential issues/best practices?**
- A) `helm check`
- B) `helm audit`
- C) `helm lint`
- D) `helm test`
*Answer: C*

**9. What is a "partial" or "named template" started with in `_helpers.tpl`?**
- A) `{{ partial "name" }}`
- B) `{{ define "name" }}`
- C) `{{ snippet "name" }}`
- D) `{{ func "name" }}`
*Answer: B*

**10. To download dependencies defined in `Chart.yaml`, you run:**
- A) `helm dep build`
- B) `helm dep update`
- C) Both A and B
- D) `helm install --deps`
*Answer: C*

**11. Which function is used to handle YAML indentation in templates?**
- A) `space`
- B) `indent`
- C) `nindent`
- D) `yamlFill`
*Answer: C (and B, but C is preferred for newlines)*

**12. What does `helm upgrade --install` do?**
- A) Upgrades if it exists, otherwise fails.
- B) Installs if it doesn't exist, otherwise fails.
- C) Upgrades if it exists, otherwise installs it.
- D) Deletes and reinstalls.
*Answer: C*

**13. A `.tgz` file in Helm terms is:**
- A) A source folder
- B) A packaged chart
- C) A log file
- D) A secret key
*Answer: B*

**14. What is the first version of Helm that did NOT require Tiller?**
- A) v1.0
- B) v2.5
- C) v3.0
- D) v4.0
*Answer: C*

**15. To see the history of a release, you run:**
- A) `helm log`
- B) `helm history`
- C) `helm revisions`
- D) `helm status`
*Answer: B*

**16. Which value is automatically injected by Helm into every template?**
- A) .Global
- B) .Chart
- C) .Release
- D) All of the above
*Answer: D*

**17. How do you delete a release but keep the history?**
- A) `helm delete --keep-history`
- B) `helm uninstall --keep-history`
- C) `helm remove --save`
- D) You cannot; history is always deleted.
*Answer: B*

**18. What is the purpose of `tests/` directory in a chart?**
- A) To store unit tests for the Go code
- B) To store Kubernetes pods that run health checks on the release
- C) To store example values
- D) It's just a placeholder
*Answer: B*

**19. `helm repo index` is used when:**
- A) Searching for a chart
- B) Creating your own chart repository
- C) Optimizing performance
- D) Installing Helm
*Answer: B*

**20. The `|` character in a template (e.g., `{{ .Value | upper }}`) is a:**
- A) Logical OR
- B) Pipeline (passes output to next function)
- C) Comment
- D) Multi-line marker
*Answer: B*

---

## ✅ Knowledge Check
- [x] Passed the 20-Question Quiz
- [x] Reviewed the Top 20 Interview Questions
- [x] Understand the difference between Helm 2 and Helm 3
