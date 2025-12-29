# Helm Real-Life Scenarios

Put your package management skills into practice with these real-world DevOps challenges.

---

## 🛠️ Scenario 1: Multi-Environment Values Management
**Problem:** You have one application but three environments (Dev, Staging, Prod). Each needs different CPU limits, database URLs, and replica counts.

**The Strategy:**
1. Maintain a base `values.yaml` for common settings.
2. Create environment-specific files: `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`.
3. Use the `-f` flag during deployment:
   ```bash
   helm upgrade --install my-app ./my-chart -f values-prod.yaml
   ```
**Goal**: Achieve "DRY" (Don't Repeat Yourself) configuration across environments.

---

## 🏗️ Scenario 2: Troubleshooting a Failed Upgrade
**Problem:** You triggered an upgrade, but the new version has a broken container image. The application is now offline.

**The Strategy:**
1. Check the status: `helm status my-app`.
2. View the history: `helm history my-app`. You see revision 5 is "FAILED".
3. **The Fix**: Immediately rollback to the last stable state (revision 4):
   ```bash
   helm rollback my-app 4
   ```
4. Investigate the cause in the dev environment using `helm install --dry-run --debug`.
**Goal**: Master rapid recovery and diagnostic workflows.

---

## 🌩️ Scenario 3: Versioning and Private Registries
**Problem:** Your company builds custom microservices. You need to store your Helm charts securely so they are not public but can be pulled by your CI/CD pipelines.

**The Strategy:**
1. Setup a private chart repository (e.g., AWS ECR, Harbor, or a private S3 bucket).
2. Use **Semantic Versioning** in `Chart.yaml` (e.g., `version: 1.2.3`).
3. Authenticate your CLI: `helm repo add my-private-repo https://... --username ...`
4. Use the pipeline to `helm package` and `helm push` charts automatically on every Git tag.
**Goal**: Manage a secure, professional software supply chain.

---

## 🔄 Scenario 4: The Umbrella (Parent) Chart
**Problem:** Your "Storefront" application consists of a Web UI, a Payment API, and a Database. You want to manage them all as a single unit rather than three separate releases.

**The Strategy:**
1. Create a parent "Umbrella" chart.
2. Define the UI, API, and DB as **Dependencies** in `Chart.yaml`:
   ```yaml
   dependencies:
     - name: payment-api
       version: "1.0.0"
       repository: "http://my-repo/"
   ```
3. Use `helm dep update` to pull the subcharts.
4. Pass global values from the parent to subcharts using the `global:` key in `values.yaml`.
**Goal**: Manage complex, multi-tier microservice architectures.

---

## 🛡️ Scenario 5: Enforcing Security Compliance
**Problem:** You need to ensure that every pod deployed via Helm has a specific security label and does not run as root.

**The Strategy:**
1. Create a **Library Chart** that defines a standard "security" template snippet.
2. In your application charts, `include` this library template in every deployment manifest.
3. Use **Helm Lint** in your CI pipeline to fail any chart that doesn't include the required security metadata.
**Goal**: Implement governance and compliance at scale.

---

## 💡 Key Takeaway
Helm turns Kubernetes from a collection of raw manifests into a **Product**. Its power lies in **Customizability** (Templates), **Safety** (Rollbacks), and **Composition** (Subcharts).
