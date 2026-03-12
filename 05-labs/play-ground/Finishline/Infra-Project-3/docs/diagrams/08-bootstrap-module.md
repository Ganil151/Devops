# Bootstrap Module Diagram

## Module: terraform/modules/bootstrap

```mermaid
flowchart TB
    subgraph Bootstrap_Module["Bootstrap Module"]

        subgraph S3_Bucket["S3 Bucket"]
            S3["aws_s3_bucket<br/>terraform_state"]

            Versioning["aws_s3_bucket_versioning<br/>Enabled"]
            Encryption["aws_s3_bucket_server_side_encryption_configuration<br/>AES256"]
            PublicBlock["aws_s3_bucket_public_access_block<br/>Block all public access"]
            Policy["aws_s3_bucket_policy<br/>Enforce TLS"]
        end

        subgraph DynamoDB["DynamoDB Table"]
            Table["aws_dynamodb_table<br/>terraform_locks"]

            HashKey["hash_key: LockID<br/>Type: S (String)"]
            Billing["billing_mode: PAY_PER_REQUEST"]
        end

        subgraph Inputs["Input Variables"]
            bucket_name["var.bucket_name"]
            project_name["var.project_name"]
            environment["var.environment"]
        end

        subgraph Outputs["Output Values"]
            bucket_name_out["bucket_name"]
            bucket_arn["bucket_arn"]
            dynamodb_table_name["dynamodb_table_name"]
            dynamodb_table_arn["dynamodb_table_arn"]
        end
    end

    TF["Terraform"]
    State["Terraform State"]

    S3 --> Versioning
    S3 --> Encryption
    S3 --> PublicBlock
    S3 --> Policy

    Table --> HashKey
    Table --> Billing

    TF --> S3
    TF --> Table

    S3 --> State
    Table -->|Locking| State
```

---

## Terraform Backend Architecture

```mermaid
flowchart TB
    subgraph AWS["AWS Cloud"]

        subgraph Backend["Terraform Backend"]

            subgraph S3_Storage["S3 Bucket"]
                Bucket["📦 ${bucket_name}<br/>Terraform State Storage"]

                subgraph S3_Config["Bucket Configuration"]
                    Versioning["🔄 Versioning: Enabled"]
                    Encryption["🔒 Encryption: AES256"]
                    PublicAccess["🚫 Public Access: Blocked"]
                    Policy["📋 Policy: TLS Required"]
                end

            end

            subgraph StateLocking["DynamoDB Locking"]
                LockTable["📊 ${bucket_name}-locks<br/>State Lock Table"]

                subgraph TableConfig["Table Configuration"]
                    PK["🔑 Partition Key: LockID"]
                    Billing["💰 Billing: Pay-per-request"]
                    ServerSide["🖥️ Server-side encryption"]
                end

            end
        end

    end

    Developer["👤 Developer"]
    CI_CD["🔄 CI/CD Pipeline"]
    Terraform["🏗️ Terraform"]

    Developer -->|terraform init| Terraform
    CI_CD -->|terraform plan/apply| Terraform

    Terraform -->|Read State| Bucket
    Terraform -->|Write State| Bucket

    Terraform -->|Lock Check| LockTable
    Terraform -->|Acquire Lock| LockTable
    LockTable -->|Lock ID| Terraform

    Bucket -->|State Version| LockTable
```

---

## State Locking Flow

```mermaid
sequenceDiagram
    participant Dev1 as Developer 1
    participant Dev2 as Developer 2
    participant TF1 as Terraform 1
    participant TF2 as Terraform 2
    participant S3 as S3 Bucket
    participant DynamoDB as DynamoDB

    Note over Dev1,TF1: Developer 1 starts terraform apply

    TF1->>DynamoDB: Acquire Lock (LockID: env/dev)
    DynamoDB->>TF1: ✅ Lock Acquired

    TF1->>S3: Read current state
    S3->>TF1: Current state

    TF1->>TF1: Plan changes

    TF1->>S3: Upload new state (v2)
    S3->>TF1: ✅ State saved

    Note over Dev2,TF2: Developer 2 starts terraform apply

    TF2->>DynamoDB: Acquire Lock (LockID: env/dev)
    DynamoDB->>TF2: ❌ Lock held by Dev1

    TF2->>Dev2: ⏳ Waiting for lock...

    Note over TF1,DynamoDB: Developer 1 completes

    TF1->>DynamoDB: Release Lock
    DynamoDB->>TF1: ✅ Lock Released

    DynamoDB->>TF2: ✅ Lock Acquired
    TF2->>Dev2: Proceeding with apply
```

---

## Key Features

| Feature             | Implementation                           | Reference |
| ------------------- | ---------------------------------------- | --------- |
| **S3 Backend**      | Terraform state storage in S3            | §101      |
| **State Locking**   | DynamoDB for concurrent operation safety | §102      |
| **Versioning**      | S3 versioning enabled                    | §28       |
| **Encryption**      | S3 server-side encryption (AES256)       | §101      |
| **Public Access**   | Block all public access                  | §102      |
| **TLS Policy**      | Deny non-TLS requests                    | §105      |
| **Pay-per-request** | DynamoDB on-demand billing               | §102      |

---

## S3 Bucket Security Configuration

```mermaid
flowchart TB
    subgraph S3_Security["S3 Bucket Security"]

        subgraph AccessControl["Access Control"]
            BlockACLs["✅ Block public ACLs"]
            BlockPolicy["✅ Block public policy"]
            IgnoreACLs["✅ Ignore public ACLs"]
            RestrictBuckets["✅ Restrict public buckets"]
        end

        subgraph EncryptionConfig["Encryption"]
            Algorithm["🔐 SSE Algorithm: AES256"]
            Default["Apply by default: Yes"]
        end

        subgraph BucketPolicy["Bucket Policy"]
            TLS_Required["📋 Deny non-TLS<br/>aws:SecureTransport = false"]
            Version["Version: 2012-10-17"]
        end

    end

    S3["S3 Bucket"] --> AccessControl
    S3 --> EncryptionConfig
    S3 --> BucketPolicy
```

---

## DynamoDB Table Schema

```mermaid
erDiagram
    TERRAFORM_LOCKS {
        string LockID PK "Environment path"
        string Info "Lock metadata"
        string Who "Who holds the lock"
        string Version "Terraform version"
        string Created "Lock timestamp"
    }

    TERRAFORM_LOCKS ||--|| LockMechanism : "represents"

    class LockMechanism {
        string purpose "Prevents concurrent tf runs"
        string scope "Per workspace"
    }
```

---

## Terraform Backend Configuration

```mermaid
flowchart LR
    subgraph BackendConfig["backend.tf Configuration"]
        BackendType["backend \"s3\""]

        Bucket["bucket = \"${bucket_name}\""]
        Key["key = \"terraform.tfstate\""]
        Region["region = \"${var.region}\""]
        DynamoLock["dynamodb_endpoint = \"${dynamodb_table}\""]
        Encrypt["encrypt = true"]
    end

    BackendConfig --> Terraform
    Terraform --> S3
    Terraform --> DynamoDB
```

---

## Outputs Reference

```mermaid
classDiagram
    class Outputs {
        <<output>>
        +string bucket_name
        +string bucket_arn
        +string dynamodb_table_name
        +string dynamodb_table_arn
    }

    class S3Bucket {
        <<resource>>
        +string id
        +string bucket
        +string bucket_domain_name
        +string arn
    }

    class DynamoDBTable {
        <<resource>>
        +string id
        +string name
        +string arn
        +string hash_key
    }

    Outputs --> S3Bucket
    Outputs --> DynamoDBTable
```

---

_Generated from: terraform/modules/bootstrap/main.tf_
