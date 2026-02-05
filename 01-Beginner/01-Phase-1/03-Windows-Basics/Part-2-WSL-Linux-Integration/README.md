# WSL DevOps Environment Setup

This directory contains a bash script designed to automate the installation of essential DevOps tools on **WSL Ubuntu 25.04**.

## 🛠️ Tools Included

The `setup-wsl-devops.sh` script installs and configures the following tools:

| Tool | Description | Reference Link |
| :--- | :--- | :--- |
| **Docker** | Containerization platform for developing, shipping, and running applications. | [Official Site](https://www.docker.com/) |
| **Docker Compose** | Tool for defining and running multi-container Docker applications. | [Docs](https://docs.docker.com/compose/) |
| **Java 21** | The latest long-term support (LTS) release of the Java SE platform (OpenJDK). | [JDK 21](https://openjdk.org/projects/jdk/21/) |
| **Terraform** | Infrastructure as Code (IaC) tool for building, changing, and versioning infrastructure. | [Official Site](https://www.terraform.io/) |
| **Minikube** | Local Kubernetes, focusing on making it easy to learn and develop for Kubernetes. | [Docs](https://minikube.sigs.k8s.io/) |
| **Ansible** | IT automation tool that automates provisioning, configuration management, and more. | [Official Site](https://www.ansible.com/) |
| **AWS CLI v2** | Unified tool to manage your AWS services from the command line. | [Docs](https://docs.aws.amazon.com/cli/) |

## 📦 Scripts in this Directory

- `setup-wsl-devops.sh`: Installs the DevOps tools listed above (Excluding AWS CLI).
- `install-aws-cli.sh`: Installs or updates the latest AWS CLI v2 binary.
- `upgrade-wsl-version.sh`: Configures your system to allow upgrades to the latest Ubuntu releases and starts the `do-release-upgrade` process.


## 🚀 How to Launch the Installation

Follow these steps to execute the setup script within your WSL terminal:

### 1. Navigate to the directory
Since the files are stored on your Windows host, you need to access them via the `/mnt/c` mount point:
```bash
cd /mnt/c/Users/Ganil/Documents/Devops/09-Resources/WSL/
```

### 2. Make the script executable
Ensure the script has the necessary permissions to run:
```bash
chmod +x setup-wsl-devops.sh
```

### 3. Run the scripts

**To install DevOps tools:**
```bash
./setup-wsl-devops.sh
```

**To install AWS CLI v2:**
```bash
./install-aws-cli.sh
```

**To upgrade your Ubuntu version:**
```bash
./upgrade-wsl-version.sh
```

## 🛠️ Distribution Upgrade Notes
The `upgrade-wsl-version.sh` script automates the editing of `/etc/update-manager/release-upgrades` by setting the prompt to `normal`. This allows you to upgrade to the absolute latest version (including non-LTS releases like 24.10 or 25.04).


## ⚠️ Post-Installation Notes
- **Docker Group**: The script adds your user to the `docker` group. You must close and restart your WSL terminal (or run `newgrp docker`) for these changes to take effect, allowing you to run Docker without `sudo`.
- **System Updates**: The script performs a full system upgrade (`apt upgrade`) before and after installation to ensure all packages are on the latest release versions.
