# 🛡️ Robust Bash Execution - Visual Architecture

## Complete Signal Management & Error Handling Flow

```mermaid
graph TB
    subgraph "Script Initialization"
        A[Script Start] --> B[set -euo pipefail]
        B --> C[Define cleanup function]
        C --> D[Set trap handlers]
    end
    
    subgraph "Execution Phase"
        D --> E[Create Lockfile]
        E --> F{Lock Acquired?}
        F -->|No| G[Exit: Already Running]
        F -->|Yes| H[Create Temp Resources]
        H --> I[Main Script Logic]
    end
    
    subgraph "Signal Handling"
        J[SIGINT - Ctrl+C] --> K[Trap Handler]
        L[SIGTERM - kill] --> K
        M[EXIT - Normal End] --> K
        N[ERR - Command Fail] --> K
        K --> O[cleanup function]
    end
    
    subgraph "Cleanup Process"
        O --> P[Remove Lockfile]
        P --> Q[Delete Temp Files]
        Q --> R[Close File Descriptors]
        R --> S[Log Cleanup Status]
        S --> T[Exit with Status]
    end
    
    I --> M
    I -.->|Interrupted| J
    I -.->|Killed| L
    I -.->|Command Fails| N
    
    style A fill:#2ecc71,stroke:#27ae60,color:#fff
    style G fill:#e74c3c,stroke:#c0392b,color:#fff
    style K fill:#f39c12,stroke:#e67e22,color:#fff
    style T fill:#9b59b6,stroke:#8e44ad,color:#fff
```

## Defensive Programming Layers

```mermaid
graph LR
    subgraph "Layer 1: Fail-Fast"
        A1[set -e<br/>Exit on Error] 
        A2[set -u<br/>Undefined Variables]
        A3[set -o pipefail<br/>Pipeline Failures]
    end
    
    subgraph "Layer 2: Resource Management"
        B1[Atomic Locking<br/>mkdir/flock]
        B2[Temporary Files<br/>mktemp]
        B3[File Descriptors<br/>exec]
    end
    
    subgraph "Layer 3: Signal Handling"
        C1[EXIT Trap<br/>Always Runs]
        C2[SIGINT Trap<br/>Ctrl+C]
        C3[SIGTERM Trap<br/>kill command]
    end
    
    subgraph "Layer 4: Cleanup"
        D1[Remove Locks]
        D2[Delete Temps]
        D3[Log Status]
    end
    
    A1 --> B1
    A2 --> B2
    A3 --> B3
    B1 --> C1
    B2 --> C2
    B3 --> C3
    C1 --> D1
    C2 --> D2
    C3 --> D3
    
    style A1 fill:#e74c3c,stroke:#c0392b,color:#fff
    style A2 fill:#e74c3c,stroke:#c0392b,color:#fff
    style A3 fill:#e74c3c,stroke:#c0392b,color:#fff
    style B1 fill:#3498db,stroke:#2980b9,color:#fff
    style B2 fill:#3498db,stroke:#2980b9,color:#fff
    style B3 fill:#3498db,stroke:#2980b9,color:#fff
    style C1 fill:#f39c12,stroke:#e67e22,color:#fff
    style C2 fill:#f39c12,stroke:#e67e22,color:#fff
    style C3 fill:#f39c12,stroke:#e67e22,color:#fff
    style D1 fill:#2ecc71,stroke:#27ae60,color:#fff
    style D2 fill:#2ecc71,stroke:#27ae60,color:#fff
    style D3 fill:#2ecc71,stroke:#27ae60,color:#fff
```

## Lock Mechanism Comparison

```mermaid
graph TB
    subgraph "mkdir Method (Atomic)"
        M1[mkdir /tmp/script.lock] --> M2{Success?}
        M2 -->|Yes| M3[Script Continues]
        M2 -->|No| M4[Exit: Already Running]
        M3 --> M5[Script Completes]
        M5 --> M6[rmdir /tmp/script.lock]
        M7[Process Crash] -.->|Manual Cleanup| M8[Stale Lock Remains]
    end
    
    subgraph "flock Method (Kernel)"
        F1[exec 200>/var/lock/script] --> F2[flock -n 200]
        F2 --> F3{Lock Acquired?}
        F3 -->|Yes| F4[Script Continues]
        F3 -->|No| F5[Exit: Already Running]
        F4 --> F6[Script Completes]
        F6 --> F7[FD Auto-Released]
        F8[Process Crash] -.->|Kernel Cleanup| F9[Lock Auto-Released]
    end
    
    style M4 fill:#e74c3c,stroke:#c0392b,color:#fff
    style M8 fill:#e74c3c,stroke:#c0392b,color:#fff
    style F5 fill:#e74c3c,stroke:#c0392b,color:#fff
    style F9 fill:#2ecc71,stroke:#27ae60,color:#fff
```

## Error Propagation with Pipefail

```mermaid
graph LR
    subgraph "Without pipefail"
        A1[command1] -->|fails| A2[command2] 
        A2 -->|succeeds| A3[Exit Code: 0]
        A3 --> A4[❌ Error Hidden]
    end
    
    subgraph "With pipefail"
        B1[command1] -->|fails| B2[command2]
        B2 -->|succeeds| B3[Exit Code: 1]
        B3 --> B4[✅ Error Detected]
    end
    
    style A4 fill:#e74c3c,stroke:#c0392b,color:#fff
    style B4 fill:#2ecc71,stroke:#27ae60,color:#fff
```

## Production Script Template

```mermaid
sequenceDiagram
    participant S as Script
    participant OS as Operating System
    participant FS as File System
    participant L as Logs
    
    Note over S: Initialization Phase
    S->>S: set -euo pipefail
    S->>S: Define cleanup()
    S->>S: trap cleanup EXIT SIGINT SIGTERM
    
    Note over S: Execution Phase
    S->>FS: Create lockfile (atomic)
    FS-->>S: Lock acquired/denied
    S->>FS: Create temp directory
    S->>L: Log start
    
    Note over S: Main Logic
    S->>S: Execute business logic
    
    Note over S: Cleanup Phase (Always Runs)
    OS->>S: Signal received
    S->>S: cleanup() triggered
    S->>FS: Remove lockfile
    S->>FS: Remove temp files
    S->>L: Log completion
    S->>OS: Exit with status
```

## 📖 Navigation

- **Previous**: [Core Concepts](./01-Robust-Execution-and-Traps.md)
- **Next**: [Advanced Patterns and Examples](./03-Advanced-Patterns-and-Examples.md)
- **Module Home**: [Robust Execution Module](./README.md)

[⬅️ Back to Advanced Bash](../README.md)