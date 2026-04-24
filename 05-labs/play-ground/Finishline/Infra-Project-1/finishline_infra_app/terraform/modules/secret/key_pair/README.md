# Key Pair Module

## Overview

This Terraform module creates and manages an AWS EC2 Key Pair for the Finishline Infrastructure project. The module generates an RSA 4096-bit key pair, uploads the public key to AWS, and saves the private key locally.

## Purpose

The Key Pair module serves as a fundamental security component for the Finishline Infrastructure project with the following key purposes:

1. **Secure Access**: Provides SSH key-based authentication for EC2 instances
2. **Key Generation**: Automatically generates RSA 4096-bit key pairs using Terraform's TLS provider
3. **AWS Integration**: Uploads the public key to AWS EC2 as a key pair
4. **Local Storage**: Saves the private key locally in PEM format with proper permissions

## Architecture

The module creates the following resources:

```
┌─────────────────────────────────────────────────────────────┐
│                    Key Pair Module                            │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  tls_private_key (rsa_4096)                              ││
│  │  • Generates RSA 4096-bit private key                    ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌──────────────────────┐  ┌──────────────────────────────┐│
│  │ aws_key_pair         │  │ local_file                    ││
│  │ • Uploads public key │  │ • Saves private key (.pem)   ││
│  │   to AWS EC2         │  │ • Sets 0400 permissions       ││
│  └──────────────────────┘  └──────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource          | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `tls_private_key` | Generates RSA 4096-bit private key                                |
| `aws_key_pair`    | Uploads the public key to AWS EC2                                 |
| `local_file`      | Saves the private key locally in PEM format with 0400 permissions |

## Inputs

| Variable       | Type   | Description                                 | Required |
| -------------- | ------ | ------------------------------------------- | -------- |
| `project_name` | string | The name of the project                     | Yes      |
| `environment`  | string | The environment (dev, staging, prod)        | Yes      |
| `manage_by`    | string | The entity responsible for managing the key | Yes      |
| `key_name`     | string | The name of the key pair                    | Yes      |

## Outputs

| Output                  | Description                                        |
| ----------------------- | -------------------------------------------------- |
| `key_name`              | The name of the key pair                           |
| `key_pair_id`           | The ID of the key pair in AWS                      |
| `key_pair_fingerprint`  | The SHA-1 digest of the key pair                   |
| `private_key_pem`       | The private key in PEM format (sensitive)          |
| `public_key_openssh`    | The public key in OpenSSH format                   |
| `private_key_file_path` | The local file path where the private key is saved |

## Usage Example

```hcl
module "key_pair" {
  source = "./modules/secret/key_pair"

  project_name = "finishline"
  environment  = "dev"
  manage_by    = "terraform"
  key_name     = "finishline-dev-key"
}
```

## Security Considerations

1. **Private Key Security**: The private key is marked as sensitive in outputs and should never be committed to version control
2. **File Permissions**: The private key file is saved with 0400 permissions (read-only for owner)
3. **Key Rotation**: For production environments, consider implementing key rotation strategies
4. **Access Control**: Limit access to the private key file to only authorized users and systems

## Dependencies

This module does not have any external dependencies. It uses:

- `tls` provider (built-in to Terraform)
- `local` provider (built-in to Terraform)
- `aws` provider (for AWS key pair creation)

## Troubleshooting

### Common Issues

1. **Permission Denied (SSH)**: Ensure the private key file has correct permissions (400)
2. **Key Pair Not Found**: Verify the key was created successfully in AWS Console
3. **File Not Created**: Check that the directory where the key is being saved exists and is writable

### Best Practices

- Store private keys in a secure location (e.g., AWS Secrets Manager, HashiCorp Vault)
- Never commit private keys to version control
- Use different key pairs for different environments
- Rotate keys periodically, especially in production
- Back up private keys in a secure location

## Maintenance

- **Updates**: Key pairs cannot be updated; to rotate, create a new key pair and update instances
- **Monitoring**: Track key pair creation in AWS CloudTrail
- **Versioning**: Track key pair configuration in version control (do not track private keys)
