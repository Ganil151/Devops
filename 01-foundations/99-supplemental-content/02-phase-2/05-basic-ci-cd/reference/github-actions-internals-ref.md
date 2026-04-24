# GitHub Actions Internals Reference

**Doc Version:** 1.0.0
**Role:** DevOps Engineer
**Scope:** GitHub Actions Architecture & Security

---

## 1. The Workflow Hierarchy

GitHub Actions files (`.github/workflows/*.yml`) follow a strict hierarchy:

1.  **Workflow**: The highest level (the file). Triggered by an Event.
2.  **Job**: A set of steps that run on the **same runner**.
    - Jobs run in **parallel** by default.
    - Jobs have an isolated filesystem. To share files between jobs, you MUST use `upload-artifact`/`download-artifact`.
3.  **Step**: An individual task.
    - Runs sequentially.
    - Steps in the same job share the filesystem.
4.  **Action**: A reusable unit of code (`uses: actions/checkout@v4`).

---

## 2. The Context Object

The `github` context contains all the metadata about the event.
- `${{ github.sha }}`: The Commit ID.
- `${{ github.ref }}`: The Branch/Tag name (`refs/heads/main`).
- `${{ github.event_name }}`: The trigger (`push`, `pull_request`).

**Enterprise Usage:** Unique tagging.
```yaml
tags: user/app:${{ github.sha }}
```
This ensures every Docker image tag corresponds exactly to a Git commit from the Context.

---

## 3. Security: The `GITHUB_TOKEN`

Every workflow is injected with a temporary JWT token: `GITHUB_TOKEN`.

- **Scope:** By default, it has Read/Write access to the repo.
- **Enterprise Best Practice:** Principle of Least Privilege.
- **Explicit Permissions:**

```yaml
permissions:
  contents: read      # Clone code
  issues: write       # Comment on PRs
  packages: write     # Push to GHCR
```
*Always define permissions at the workflow top level.*

---

## 4. Secrets Management

Secrets are encrypted values stored in GitHub Settings.
- **Syntax:** `${{ secrets.MY_API_KEY }}`
- **Redaction:** The Runner automatically masks secrets in the logs (`***`).
- **Injection:** Secrets are not environment variables by default. You must explicitly pass them.

```yaml
- name: Deploy
  env:
    API_KEY: ${{ secrets.PROD_API_KEY }}  # Explicit injection
  run: ./deploy.sh
```

---

## 5. Matrix Strategy

A powerful feature to test across multiple dimensions simultaneously.

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [14, 16, 18]
```
This single configuration spawns **6 parallel jobs** (2 OSs * 3 Node versions).
- **Fail Fast:** `fail-fast: true` (default). If one matrix job fails, GitHub cancels the other 5 to save money.
