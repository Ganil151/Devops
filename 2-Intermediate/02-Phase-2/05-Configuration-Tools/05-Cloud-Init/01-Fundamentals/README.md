# Cloud-Init Fundamentals

## Boot Stages Overview

Cloud-Init operates in five distinct stages during system boot:

### 1. Generator Stage
- Determines which data sources are available
- Runs very early in boot process
- Configures network for metadata access

### 2. Local Stage
- Runs before networking is configured
- Processes local data sources
- Configures basic system settings

### 3. Network Stage
- Runs after networking is available
- Processes remote data sources
- Configures network interfaces

### 4. Config Stage
- Runs user-defined configuration modules
- Installs packages, creates files
- Configures services and applications

### 5. Final Stage
- Runs final configuration tasks
- Executes scripts and commands
- Completes system initialization

## Data Sources

Cloud-Init can retrieve configuration from multiple sources:

- **Metadata Service**: Cloud provider metadata endpoints
- **User Data**: Configuration passed during instance launch
- **Vendor Data**: Cloud provider specific configuration
- **Local Files**: Configuration files on the instance

## Basic Commands

```bash
# Check cloud-init version
cloud-init --version

# Show available data sources
cloud-init query --list-keys

# Get instance metadata
cloud-init query instance-id
cloud-init query local-hostname
cloud-init query public-keys

# Check configuration status
cloud-init status --long
```