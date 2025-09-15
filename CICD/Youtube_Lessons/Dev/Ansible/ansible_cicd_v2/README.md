## End-to-End DevOps CI/CD Project From Youtube
(Link)[https://youtu.be/NKUOSc9pCfk]

### Build Steps:
#### Step-1
- Follow script : ()[app\scripts\Terraform-Server.sh]

#### Step-2:
- Create jenkins.sh:
```bash
#!/bin/bash

set -e 

# Change Host Name
echo "Changing Host Name..."
sudo hostnamectl set-hostname "Jenkins-Server"

# Install dependencies
echo "Installing dependencies..."
sudo yum update -y
sudo yum -y upgrade --releasever=2023.8.20250908
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ansible git python3 net-tools bind-utils

# Install Terraform 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Verfiy Terraform installation
if ! command -v terraform &> /dev/null; then
    echo "Terraform installation failed."
    exit 1
fi

# Create Jenkins Directory
mkdir -p jenkins && cd ~/jenkins

# Create Modules in Jenkins Directory
touch providers.tf main.tf variables.tf data.tf security.tf

# Create Providers file
cat <<EOF > providers.tf
terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "ansible-register"
    key    = "jenkins/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"

}
EOF

# Create Date file
cat <<EOF > data.tf
data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}


EOF

# Create Security file
cat <<EOF > security.tf
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_sg_${var.project_name}"
  description = "Allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = "Allow port \${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicd_sg"
  }
}
EOF

# Create Main file
cat <<EOF > main.tf
resource "aws_instance" "JenkinsServer" {
  ami           = data.aws_ami.amazonlinux2.id
  instance_type = "t3.small"
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]

  tags = {
    Name = "Jenkins"
  }
}
EOF

# Create Variables file
cat <<EOF > variables.tf
variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "Jenkins"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "cicd_vpc"
}

variable "key_name" {
  type        = string
  description = "Key Pair"
  default     = "cicd-keys"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  default     = "cicd_subnet"
}

variable "ingress_rules" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [22, 80, 443, 8080, 8090, 9000, 8081, 2479]
}

variable "egressrules" {
  type    = list(number)
  default = [0]
}
EOF

# Verify File Creation
if [[ -f "providers.tf" && -f "main.tf" && -f "variables.tf" && -f "data.tf" && -f "security.tf" ]]; then
    echo "All Terraform files created successfully."
else
    echo "Failed to create one or more Terraform files."
    exit 1
fi

echo "Setup completed successfully."
```

#### Step-3 Install Jenkins on the jenkins-server
change to root:
```bash
sudo su -
```

- Install the dependencies on the server
```bash
yum -y update 
```

- Install Jenkins
```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Then Import Key:
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

#Then Upgrade and Epel
yum -y upgrade amazon-linux-extras install epel -y

# Then install Java JDk
sudo yum install -y java-21-amazon-corretto-devel

# Now Install Jenkins
sudo yum install -y jenkins
```    

- Configure Jenkins
```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

#### Step-4 Install Maven 
```bash
cd /opt
wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
tar -xzvf apache-maven-3.9.11-bin.tar.gz

# When done
rm -r apache-maven-3.9.11-bin.tar.gz

# Rename the apache-maven 
mv apache-maven-3.9.11/ maven
```

- Configure Maven in .bash_profile
```bash
cd ~

find / -name java-11*

# Copy this output:
/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-1.amzn2.0.2.x86_64

nano .bash_profile

#---Edit .bash_profile file ---#

# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
         .~/.bashrc
fi 

M2_HOME=/opt/maven
M2=/opt/maven/bin
JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto

# User specific environment and startup programs 
PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2

export
```
- Option 2
```bash
M2=/opt/maven/bin
echo "export M2=$M2" | sudo tee -a .bash_profile
M2_HOME=/opt/maven
echo "export M2_HOME=$M2_HOME" | sudo tee -a .bash_profile
JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto 
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a .bash_profile
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2" | sudo tee -a .bash_profile
```
- Add to jenkins
```sh
touch /var/lib/jenkins/.bash_profile
sudo chown -R jenkins:jenkins /var/lib/jenkins/.bash_profile
M2=/opt/maven/bin
echo "export M2=$M2" | sudo tee -a > /var/lib/jenkins/.bash_profile
M2_HOME=/opt/maven
echo "export M2_HOME=$M2_HOME" | sudo tee -a > /var/lib/jenkins/.bash_profile
JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto 
echo "export JAVA_HOME=$JAVA_HOME" | sudo tee -a /var/lib/jenkins/.bash_profile
echo "export PATH=$PATH:$HOME/bin:$JAVA_HOME:$M2_HOME:$M2" | sudo tee -a > /var/lib/jenkins/.bash_profile
source /var/lib/jenkins/.bash_profile
```

- Test if Maven is working 
```bash
mvn -v
Apache Maven 3.9.11 (3e54c93a704957b63ee3494413a2b544fd3d825b)
Maven home: /opt/maven
Java version: 21.0.8, vendor: Amazon.com Inc., runtime: /usr/lib/jvm/java-21-amazon-corretto
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "4.14.355-280.679.amzn2.x86_64", arch: "amd64", family: "unix"
```

#### Step-5 Login into Jenkins and Configure
Open a new tab in browser, then get the aws instance <jenkins-server public ip>
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Install the plugins:
![alt text](<Screenshot (131).png>)

Then go to Manage Jenkins -> Plugins and install: 
- Pipeline: Stage Step
![alt text](<Screenshot (133).png>)

- maven integration
![alt text](<Screenshot (134)-1.png>)

Then go to Manage Jenkins -> Tools
- add JDK
![alt text](<Screenshot (136).png>)
```bash
echo $JAVA_HOME
```

Then add Maven location
- add Maven
![alt text](<Screenshot (137).png>)
```bash
echo $M2_HOME
```

Then disable Github Branch Source Plugin
![alt text](<Screenshot (138)-1.png>)

#### Step-6 Test Jenkins Maven Job
![alt text](<Screenshot (139).png>)

- Pull the Register App from Github
()[https://github.com/Ganil151/Register-App.git]
![alt text](<Screenshot (140).png>)

- In the Jenkins Job
![alt text](<Screenshot (141).png>)
  - create a git token for the project

- Add github credentials
![alt text](<Screenshot (142).png>)

![alt text](<Screenshot (143).png>)

- Set branch to */main
![alt text](<Screenshot (144).png>)

#### Step-7 Provision Ansible Server with Terraform
- Go back to Terraform Server 
```sh
cp -r jenkins/ ansible && cd ansible

# then all old terraform builds from the jenkins build
rm -r .terraform 
```

- Make changes to ansible/main.tf file
```sh
# Create Main file
cat <<EOF > main.tf
resource "aws_instance" "AnsibleServer" { 
  ami           = data.aws_ami.amazonlinux2.id
  instance_type = "t3.small"
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.cicd_sg_${var.project_name}.id]

  tags = {
    Name = "Ansible-Server"
  }
}
EOF
```

- Make changes to ansible/provider.tf
```bash
# Create Providers file
cat <<EOF > providers.tf
terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "ansible-register"
    key    = "ansible/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"

}
EOF
```

- Make changes to ansiable/security_group
```bash
# Create Security file
cat <<EOF > security.tf
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_sg_1_${var.project_name}"
  description = "Allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = "Allow port \${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicd_sg_1"
  }
}
EOF
```

- Make changes ansible/variables.tf
```bash
# Create Variables file
cat <<EOF > variables.tf
variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "Jenkins"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "cicd_vpc"
}

variable "key_name" {
  type        = string
  description = "Key Pair"
  default     = "cicd-keys"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
  default     = "cicd_subnet"
}

variable "ingress_rules" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [22, 80, 443, 8080, 8090, 9000, 8081, 2479]
}

variable "egressrules" {
  type    = list(number)
  default = [25, 80, 443, 8080, 8090, 3306, 53] 
}
EOF
```

- Then Pass Terraform
```bash
terraform init -reconfigure

# Then
terrafom plan -out=tfplan

# Then 
terraform apply -auto-approve tfplan 
```

#### Step-8 Install and Configure Ansiable
- Create a new user
```bash
sudo su -

# Then 
adduser ansadmin
passwd ansadmin
```

- Add to SudoGroup 
```bash
visudo 

# Under: Same thing without a password
# %wheel    ALL=(ALL)     NOPASSWD: ALL
ansadmin  ALL=(ALL)   NOPASSWD: ALL
:wq


# then 
cd /etc/ssh

```

- Edit sshd_config
```bash
nano sshd_config

# Change 
PasswordAuthentication to yes

# Reload SSHD
service sshd reload
```

- Create SSH Key 
```bash
[ansadmin@ansible-server ~]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansadmin/.ssh/id_rsa):
Created directory '/home/ansadmin/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ansadmin/.ssh/id_rsa.
Your public key has been saved in /home/ansadmin/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:HRi6JpBA2uz/3rrv1Y0UTdsJuR2HbHF/Hyy5yboZC7k ansadmin@ansible-server
The key's randomart image is:
+---[RSA 2048]----+
|o.      .    o+o.|
|.+ .   . o   +B=+|
|. =   . . . .+=+*|
| . .   . . ..o+.+|
|  . . o S . .+  .|
|   . o    .o.o   |
|    .    o.oo .  |
|     . . .o =    |
|     .==+E +     |
+----[SHA256]-----+
[ansadmin@ansible-server ~]$
```
- Install Ansiable 
```bash
sudo su - 
# then 
amazon-linux-extras install ansible2
```

#### Step-9 Integrate Ansible with Jenkins

- Install Publish over SSH
![alt text](<Screenshot (147).png>)
![alt text](<Screenshot (149).png>)

- Restart Jenkins
```bash
[root@jenkins-server ~]# systemctl restart jenkins
```

- Configure Publish over SSH
![alt text](<Screenshot (145).png>)

- Add SSH Server
![alt text](<Screenshot (150).png>)
Fillin <ansible-server-public-ip>
![alt text](<Screenshot (151)-1.png>)
Go to Advance: Fillin password
![alt text](<Screenshot (152).png>)
Test the Configuration then apply & save

#### Step-10 Install Docker in Ansible Server

- Setup for Docker installation
```bash
[root@ansible-server ~]# su ansadmin
[ansadmin@ansible-server root]$ cd ~
[ansadmin@ansible-server ~]$ sudo mkdir /opt/docker
[ansadmin@ansible-server ~]$ ls /opt
aws  docker  rh
[ansadmin@ansible-server ~]$ cd /opt/docker
[ansadmin@ansible-server docker]$ sudo chown -R ansadmin:ansadmin /opt/docker
[ansadmin@ansible-server docker]$ ls -la /opt/docker
total 0
drwxr-xr-x 2 ansadmin ansadmin  6 Sep 15 18:14 .
drwxr-xr-x 5 root     root     41 Sep 15 18:14 ..
```

- Run a Docker Test 
![alt text](<Screenshot (153).png>)

Go to Configure:
![alt text](<Screenshot (154).png>)

Slide down Post-Build Actions
![alt text](<Screenshot (155).png>)

Go to Send build artifacts over SSH
![alt text](<Screenshot (157).png>)

![alt text](<Screenshot (158).png>) 
Fillin:
![alt text](<Screenshot (159).png>)
Apply and Save

Then Build:
![alt text](<Screenshot (160).png>)