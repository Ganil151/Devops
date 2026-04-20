# Key Pair Module

## Overview

The Key Pair module generates and manages SSH key pairs for EC2 instance access in the Finishline infrastructure. It uses Terraform's TLS provider to generate RSA keys and stores both the public key in AWS and the private key locally.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       Key Pair Module                            │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  TLS Private Key                           │  │
│  │  tls_private_key.rsa_4096                                  │  │
│  │                                                            │  │
│  │  • Algorithm: RSA                                          │  │
│  │  • Key Size: 4096 bits                                     │  │
│  │  • Generated: During Terraform apply                       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│              ┌───────────────┴───────────────┐                   │
│              │                               │                   │
│              ▼                               ▼                   │
│  ┌────────────────────────┐    ┌────────────────────────┐       │
│  │   AWS Key Pair         │    │   Local Private Key    │       │
│  │   aws_key_pair         │    │   local_file           │       │
│  │                        │    │                        │       │
│  │  • Stores public key   │    │  • Stores PEM file     │       │
│  │  • Available in EC2    │    │  • Permissions: 0600   │       │
│  │  • Used for SSH auth   │    │  • Local filesystem    │       │
│  └────────────────────────┘    └────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

## Resources Created

| Resource Type     | Resource Name            | Description                           |
| ----------------- | ------------------------ | ------------------------------------- |
| `tls_private_key` | `rsa_4096`               | Generates RSA private key (4096 bits) |
| `aws_key_pair`    | `finishline_public_key`  | Stores public key in AWS EC2          |
| `local_file`      | `finishline_private_key` | Saves private key to local filesystem |

## Inputs

### Project Configuration

| Name                | Type           | Description                  | Required |
| ------------------- | -------------- | ---------------------------- | -------- |
| `project_name`      | `string`       | Name of the project          | Yes      |
| `environment`       | `string`       | Environment name             | Yes      |
| `managed_by`        | `bool`         | Whether managed by Terraform | Yes      |
| `availability_zone` | `list(string)` | List of availability zones   | Yes      |

### Key Pair Configuration

| Name                            | Type          | Description                      | Required | Default |
| ------------------------------- | ------------- | -------------------------------- | -------- | ------- |
| `key_name`                      | `string`      | Name of the key pair in AWS      | Yes      | -       |
| `key_algorithm`                 | `string`      | Key algorithm (e.g., `RSA`)      | Yes      | -       |
| `rsa_bits`                      | `number`      | Number of bits for RSA key       | Yes      | -       |
| `file_permission`               | `string`      | File permissions for private key | No       | `0600`  |
| `private_key_filename`          | `string`      | Filename for the private key     | Yes      | -       |
| `private_key_directory`         | `string`      | Directory to store private key   | Yes      | -       |
| `computed_private_key_filename` | `string`      | Computed filename (override)     | No       | `""`    |
| `computed_private_key_path`     | `string`      | Computed full path (override)    | No       | `""`    |
| `computed_tags`                 | `map(string)` | Computed tags (override)         | No       | `{}`    |

## Outputs

| Name                | Description                      | Sensitive |
| ------------------- | -------------------------------- | --------- |
| `key_pair_id`       | Key pair ID                      | No        |
| `key_pair_key_name` | Key pair name                    | No        |
| `private_key_path`  | Full path to private key file    | No        |
| `private_key_pem`   | Private key content (PEM format) | **Yes**   |
| `public_key`        | Public key content (PEM format)  | No        |

## Usage Example

### Basic Key Pair

```hcl
module "key_pair" {
  source = "./modules/key_pair"

  # Project Configuration
  project_name        = "finishline-infra"
  environment         = "development"
  managed_by          = true
  availability_zone   = ["us-east-1a", "us-east-1b"]

  # Key Pair Configuration
  key_name              = "finishline-key"
  key_algorithm         = "RSA"
  rsa_bits              = 4096
  private_key_directory = path.module
  private_key_filename  = "finishline-key.pem"
}
```

### Using with VPC Module

The key pair is automatically created as a nested module within the VPC module:

```hcl
module "vpc" {
  source = "./modules/vpc"

  # ... VPC configuration ...

  # Key Pair Configuration (passed to nested module)
  key_name              = "finishline-key"
  key_algorithm         = "RSA"
  rsa_bits              = 4096
  private_key_directory = path.module
  private_key_filename  = "finishline-key.pem"
}
```

### Using with EC2 Instances

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  key_name      = module.key_pair.key_pair_key_name

  tags = {
    Name = "example-instance"
  }
}

# SSH into the instance
# ssh -i ${module.key_pair.private_key_path} ec2-user@<instance-ip>
```

## Dependencies

- TLS Provider (for key generation)
- AWS Provider (for key pair storage)
- Local Provider (for file storage)

## File Structure

```
key_pair/
├── main.tf         # Key pair resources
├── variables.tf    # Input variables
├── outputs.tf      # Output values
├── locals.tf       # Local values and path computation
└── README.md       # This documentation
```

## Key Generation Details

### Algorithm Support

The module supports any algorithm supported by the TLS provider:

| Algorithm | Variable                    | Notes                |
| --------- | --------------------------- | -------------------- |
| RSA       | `key_algorithm = "RSA"`     | Requires `rsa_bits`  |
| ECDSA     | `key_algorithm = "ECDSA"`   | Uses curve specified |
| ED25519   | `key_algorithm = "ED25519"` | Fixed key size       |

### Key Size Recommendations

| Algorithm | Recommended Size       |
| --------- | ---------------------- |
| RSA       | 4096 bits              |
| ECDSA     | P-256, P-384, or P-521 |
| ED25519   | Fixed (256 bits)       |

## Local File Storage

### Path Computation

The private key path is computed as follows:

```hcl
private_key_path = var.computed_private_key_path != ""
  ? var.computed_private_key_path
  : "${var.private_key_directory}/${local.private_key_filename}"
```

### File Permissions

The private key file is created with secure permissions:

```hcl
file_permission = "0600"  # Owner read/write only

provisioner "local-exec" {
  command = "chmod ${var.file_permission} ${local.private_key_path}"
}
```

### Lifecycle

```hcl
lifecycle {
  prevent_destroy = false
}
```

The private key file can be destroyed when the resource is removed.

## Security Considerations

1. **Private Key Storage**: The private key is stored locally on the machine running Terraform. Ensure:
   - The directory has appropriate permissions
   - The key is backed up securely
   - Consider using AWS Secrets Manager or Parameter Store for production

2. **File Permissions**: Default permissions are `0600` (owner read/write only). Do not relax these permissions.

3. **Key Rotation**: The module does not automatically rotate keys. To rotate:
   - Delete the existing key pair in AWS
   - Delete the local private key file
   - Re-run Terraform apply

4. **State File Security**: The private key content is marked as sensitive but may still appear in state files. Secure your Terraform state.

5. **Version Control**: Never commit private keys to version control. Add `*.pem` to `.gitignore`.

## Outputs Usage

### Getting the Key Path

```hcl
output "ssh_command" {
  value = "ssh -i ${module.key_pair.private_key_path} ec2-user@<instance-ip>"
}
```

### Using in Other Modules

```hcl
resource "aws_instance" "bastion" {
  # ... other configuration ...
  key_name = module.key_pair.key_pair_key_name
}
```

## Troubleshooting

### Permission Denied

If you get permission denied when using the key:

```bash
chmod 600 /path/to/finishline-key.pem
```

### Key Not Found

If the key file is not found:

1. Check `private_key_directory` exists
2. Verify `private_key_filename` is correct
3. Re-run `terraform apply`

### Key Pair Already Exists

If the key pair name already exists in AWS:

1. Use a unique `key_name`
2. Or delete the existing key pair in AWS Console

## Tags

All resources are tagged with:

- `Name` - Key pair name
- `Environment` - Environment name
- `Project` - Project identifier
- `ManageBy` - Terraform management flag
