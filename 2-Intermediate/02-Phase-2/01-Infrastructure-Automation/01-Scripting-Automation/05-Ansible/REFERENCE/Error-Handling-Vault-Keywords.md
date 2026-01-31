# 🛡️ Reference: Error Handling & Vault Keywords

Reliable automation must handle failures gracefully and keep secrets encrypted. These keywords are the "Safety Net" of Ansible.

---

## 🛠️ Error Handling

### `ignore_errors`
*   **Definition**: Continues execution even if a task fails.
*   **Risk**: Use sparingly. It can hide catastrophic failures.

### `failed_when`
*   **Definition**: Custom logic to decide if a task failed, regardless of the exit code.
*   **Example**: `failed_when: "'Error' in output.stdout"`.

### `any_errors_fatal`
*   **Definition**: If any host fails a task, stop the entire playbook for all hosts.
*   **DevOps Why**: Prevents a bad config from spreading to the rest of the cluster.

### `block...rescue...always`
*   **Definition**: The Ansible equivalent of Python's `try...except...finally`.
*   **rescue**: Runs tasks if the `block` fails.
*   **always**: Runs tasks regardless of success or failure.

---

## 🔐 Ansible Vault

### `ansible-vault`
*   **Definition**: A tool to encrypt files (variables, playbooks) using AES256.

### `--ask-vault-pass` vs `--vault-password-file`
*   **Standard**: Use `--vault-password-file` in CI/CD pipelines to pull the decryption key from a secure location (or env var).

---

## 🎙️ Staff Interview context
*   **"How do you ensure Ansible doesn't print secrets in its output logs?"**
    *   *Answer*: Use the `no_log: true` attribute on a task. This prevents the task's arguments and return values from being printed to the console or log files.
*   **"Explain the 'fail-fast' strategy using any_errors_fatal."**
    *   *Answer*: In a fleet of 100 servers, if the first 2 fail due to a disk space issue, it's likely they all will. `any_errors_fatal` stops the run immediately, saving time and preventing a partial (broken) deployment.
