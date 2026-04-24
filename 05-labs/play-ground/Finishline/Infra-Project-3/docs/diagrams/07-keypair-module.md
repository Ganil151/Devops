# Key Pair Module Diagram

## Module: terraform/modules/key_pair

```mermaid
flowchart TB
    subgraph KeyPair_Module["Key Pair Module"]

        subgraph TLS_Key["TLS Private Key"]
            TLSKey["tls_private_key<br/>rsa_4096"]

            Algorithm["algorithm: RSA<br/>rsa_bits: 4096"]
        end

        subgraph AWS_Key["AWS Key Pair"]
            AWSKey["aws_key_pair<br/>finishline_key"]

            PublicKey["public_key<br/>OpenSSH format"]
        end

        subgraph Local_Key["Local Private Key"]
            LocalFile["local_file<br/>private_key"]

            FilePath["filename: ${path.module}/${key_name}.pem"]
            Permissions["file_permission: 0600"]
        end

        subgraph Warning["Null Resource Warning"]
            Warning["null_resource<br/>key_warning"]
            WarningMsg["Display key location<br/>and security reminders"]
        end

        subgraph Inputs["Input Variables"]
            key_name["var.key_name"]
            project_name["var.project_name"]
            environment["var.environment"]
        end

        subgraph Outputs["Output Values"]
            key_name_out["key_name"]
            key_fingerprint["key_fingerprint"]
        end
    end

    EC2["EC2 Instance<br/>JumpHost"]

    TLSKey -->|public_key_openssh| AWSKey
    TLSKey -->|private_key_pem| LocalFile
    TLSKey --> Warning

    AWSKey -->|key_name| EC2
    LocalFile -->|SSH Access| EC2
```

---

## Key Pair Generation Flow

```mermaid
flowchart TB
    subgraph Generation["Key Generation Process"]

        Step1["1. Generate RSA Key"]
        Step2["2. Upload Public Key to AWS"]
        Step3["3. Save Private Key Locally"]
        Step4["4. Set File Permissions"]
        Step5["5. Display Warning"]
    end

    TLS["tls_private_key<br/>RSA 4096-bit"]
    AWS["aws_key_pair"]
    Local["local_file<br/>*.pem"]
    chmod["chmod 400"]
    echo["echo warning message"]

    Step1 --> TLS
    TLS --> Step2
    Step2 --> AWS
    AWS --> Step3
    Step3 --> Local
    Local --> chmod
    chmod --> Step4
    Step4 --> echo
    echo --> Step5
```

---

## Key Pair Architecture

```mermaid
flowchart LR
    subgraph Terraform["Terraform"]

        subgraph KeyGen["Key Generation"]
            TLSKeyGen["🔐 tls_private_key<br/>RSA 4096-bit<br/>algorithm: RSA"]
        end

        subgraph AWS_Resources["AWS Resources"]
            AWSKeyPair["☁️ aws_key_pair<br/>EC2 Key Pair"]
        end

        subgraph LocalResources["Local Resources"]
            PrivateKey["📄 ${key_name}.pem<br/>Private Key (PEM)"]
            PublicKey["📄 Public Key (OpenSSH)"]
        end

    end

    EC2["🖥️ EC2 Instance<br/>JumpHost"]
    Admin["👤 Admin"]

    TLSKeyGen -->|Generate| PrivateKey
    TLSKeyGen -->|Extract| PublicKey
    PublicKey -->|Upload| AWSKeyPair
    AWSKeyPair -->|key_name| EC2
    PrivateKey -->|SSH| Admin
    Admin -->|SSH :22| EC2
```

---

## Key Features

| Feature                | Implementation                     | Reference |
| ---------------------- | ---------------------------------- | --------- |
| **Key Type**           | RSA 4096-bit                       | §71       |
| **Private Key Format** | PEM (local file)                   | §71       |
| **Public Key Format**  | OpenSSH (AWS)                      | §71       |
| **File Permissions**   | 0600 (owner read/write only)       | §71       |
| **Terraform Managed**  | Generated and managed by Terraform | §71       |
| **Key Name**           | Configurable via `var.key_name`    | §71       |

---

## SSH Key Usage Flow

```mermaid
sequenceDiagram
    participant Terraform as Terraform
    participant TLS as tls_private_key
    participant AWS as aws_key_pair
    participant Local as local_file
    participant Admin as Admin
    participant EC2 as JumpHost EC2

    Note over TLS: Generates RSA 4096-bit<br/>key pair

    TLS->>AWS: Upload public key<br/>(OpenSSH format)
    AWS->>AWS: Register with EC2

    TLS->>Local: Save private key<br/>(PEM format)
    Local->>Local: Set permissions 0600

    Note over Admin: Admin copies key<br/>to ~/.ssh/

    Admin->>EC2: SSH connection<br/>ssh -i key.pem user@host

    alt Key Matches
        EC2->>Admin: ✅ Authentication Successful
    else Key Mismatch
        EC2->>Admin: ❌ Permission Denied
    end
```

---

## Security Considerations

```mermaid
flowchart TB
    subgraph Security["Security Best Practices"]

        subgraph Before["After Key Generation"]
            Step1["📍 Note key location"]
            Step2["📦 Copy to secure location<br/>(e.g., ~/.ssh/)"]
            Step3["🔐 Set permissions<br/>chmod 400 key.pem"]
            Step4["🗑️ Delete from terraform dir"]
        end

        subgraph Storage["Secure Storage"]
            SSH_Dir["~/.ssh/ directory<br/>700 permissions"]
            Key_File["key.pem<br/>600 permissions"]
            NotShared["❌ Don't share<br/>Don't commit to git"]
        end

        subgraph Access["Access Control"]
            IAM["IAM user/role with<br/>EC2 access"]
            SSH["SSH access to<br/>JumpHost only"]
        end
    end

    KeyGen["Key Generated"] --> Step1
    Step1 --> Step2
    Step2 --> Step3
    Step3 --> Step4

    Step2 --> SSH_Dir
    SSH_Dir --> Key_File

    Key_File --> IAM
    Key_File --> SSH
```

---

## Outputs Reference

```mermaid
classDiagram
    class Outputs {
        <<output>>
        +string key_name
        +string key_fingerprint
    }

    class TLSKey {
        <<resource>>
        +string id
        +string private_key_pem
        +string public_key_openssh
        +string rsa_public_key_pem
    }

    class AWSKey {
        <<resource>>
        +string id
        +string key_name
        +string key_fingerprint
        +string public_key
    }

    class LocalFile {
        <<resource>>
        +string filename
        +string content
        +string file_permission
    }

    Outputs --> TLSKey
    Outputs --> AWSKey
```

---

_Generated from: terraform/modules/key_pair/main.tf_
