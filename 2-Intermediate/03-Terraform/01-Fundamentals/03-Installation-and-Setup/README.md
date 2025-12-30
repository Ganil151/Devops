# Installation and Setup

Getting Terraform up and running on your local machine.

## Installation Methods

### 1. Download Binary (Universal)
```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### 2. Package Manager (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### 3. Using tfenv (Recommended for DevOps)
`tfenv` allows you to switch between different versions of Terraform easily, which is crucial for managing multiple projects.
```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
tfenv install 1.6.0
tfenv use 1.6.0
```

## IDE Setup (VS Code)
- Install the **HashiCorp Terraform** extension.
- Enables syntax highlighting, autocompletion, and integrated `terraform fmt` on save.

---

## 🏗️ Real-Life Scenario: The Version Conflict
**Problem**: You are working on Project A which uses Terraform 0.12, and Project B which uses 1.5. Installing one globally breaks the other.
**Solution**: Use **tfenv**! You can simply run `tfenv use 0.12` when in Project A's directory and `tfenv use 1.5` for Project B. This prevents hours of debugging configuration syntax errors caused by version mismatches.

---
## ❓ Interview Questions
1. **How do you verify your Terraform installation?**
   - *Answer*: Run `terraform version` or simply `terraform`.
2. **Why is using a version manager like `tfenv` recommended?**
   - *Answer*: It allows developers to maintain different versions of Terraform for different projects, avoiding breaking changes during team collaboration.

---
## 🧠 Quiz Snippet (5/20+)
1. **What command checks the installed Terraform version?** (`terraform version`)
2. **Which sub-directory stores provider plugins locally?** (`.terraform/`)
3. **True/False: Terraform is a single binary executable.** (True)
4. **On which OS can Terraform be installed?** (Linux, Windows, macOS, etc.)
5. **Does Terraform require a heavy server installation?** (No, it's a client-side CLI tool)
