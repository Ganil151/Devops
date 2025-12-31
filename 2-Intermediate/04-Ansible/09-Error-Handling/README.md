# Error Handling and Debugging

Things go wrong. Services crash, disks fill up, and typos happen. Ansible is programmed to **Fail Fast**, but it also provides a suite of tools to manage failures gracefully and find the root cause of issues quickly.

## 📚 Learning Path

| # | Topic | Description | Key Modules/Flags |
| :--- | :--- | :--- | :--- |
| **01** | [**Failure Strategies**](./01-Failure-Strategies/README.md) | Controlling Playbook Abortion | `ignore_errors`, `max_fail_percentage` |
| **02** | [**Debugging Tools**](./02-Debugging-Tools/README.md) | Inspecting State | `debug`, `-vvvv`, `--check`, `debugger` |
| **03** | [**Handler Management**](./03-Handler-Management/README.md) | Deferred Tasks | `notify`, `meta: flush_handlers`, `listen` |
| **04** | [**Validation & Abortion**](./04-Validation-and-Abortion/README.md) | Stopping Safely | `assert`, `fail`, `pause`, `wait_for` |

---

## 🏗️ Troubleshooting Flow

```mermaid
graph TD
    Error[Task Error Detected] --> Strat{Failure Strategy?}
    Strat -->|Ignore| Continue[Continue to Next Task]
    Strat -->|Fatal| Abort[Stop Playbook]
    
    Tabort[Abort Triggered] --> Handlers{Force Handlers?}
    Handlers -->|Yes| RunH[Run notified Handlers]
    Handlers -->|No| End[Exit Playbook]
    
    Abort --> End
    RunH --> End
    
    style Abort fill:#ff4444,color:#fff
```

## Quick Start

To debug a task that keeps failing due to unknown reasons:

```bash
ansible-playbook site.yml --limit <hostname> -vvvv
```

To verify variable values during a run:

```yaml
- name: Debug my_var
  debug:
    var: my_var
```

Please proceed to **[01-Failure-Strategies](./01-Failure-Strategies/README.md)**.