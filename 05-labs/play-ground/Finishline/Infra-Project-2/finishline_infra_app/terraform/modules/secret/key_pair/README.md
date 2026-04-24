# Key Pair Module

## Overview
Generates and manages SSH key pairs for EC2 instance access, storing private keys locally with secure permissions.

## Functions
- **Key Generation**: Creates RSA key pairs using TLS provider
- **AWS Registration**: Registers public key with AWS
- **Local Storage**: Saves private key to local filesystem with 0400 permissions
- **Key Management**: Supports custom key names and storage locations

## Inputs
- `key_name`: Name of the key pair
- `key_algorithm`: Algorithm for key generation (default: RSA)
- `rsa_bits`: RSA key size in bits (default: 4096)
- `private_key_directory`: Directory to store private key
- `private_key_filename`: Custom filename for private key
- `project_name`, `environment`, `managedBy`: Tagging variables

## Outputs
- `key_name`: Key pair name
- `private_key_filename`: Generated private key filename
- `private_key_pathname`: Full path to private key
- `public_key`: Public key content

## Connections
- **Depends on**: None (standalone module)
- **Used by**: EC2 module (for instance access)
- **Purpose**: Provides SSH access credentials for infrastructure management
