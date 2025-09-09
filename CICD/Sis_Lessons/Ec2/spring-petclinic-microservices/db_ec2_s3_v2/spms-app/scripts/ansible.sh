#!/bin/bash
set -e
set -x

# Update packages
sudo yum update -y || sudo dnf update -y

# Change the hostname
sudo hostnamectl set-hostname "ansible-server"

# Increase tmp files size (avoid duplicates)
grep -q "/tmp tmpfs" /etc/fstab || echo "tmpfs /tmp tmpfs defaults,size=1500M 0 0" | sudo tee -a /etc/fstab
sudo mount -o remount /tmp

# Install Ansible (works for AL2 or AL2023)
if command -v amazon-linux-extras &>/dev/null; then
    sudo yum install -y epel-release
else
    sudo yum install -y ansible
fi

# Verify
ansible --version

# Create a new user
if ! id ansadmin &>/dev/null; then
    sudo useradd -m -s /bin/bash ansadmin
    echo "ansadmin:ansadmin" | sudo chpasswd  
    sudo usermod -aG wheel ansadmin
fi

# Add sudoers entry in correct place
echo "ansadmin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansadmin
sudo chmod 0440 /etc/sudoers.d/ansadmin

# Enable password authentication for SSH
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Generate SSH key for ansadmin
sudo -u ansadmin -i ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa


# Install Docker
sudo yum install -y docker

# Configure Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user
sudo systemctl restart jenkins