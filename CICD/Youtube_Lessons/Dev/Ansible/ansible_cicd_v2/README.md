## End-to-End DevOps CI/CD Project From Youtube
(Link)[https://youtu.be/NKUOSc9pCfk]

### Build Steps:
#### Step-1
**Follow script** : ()[app\scripts\Terraform-Server.sh]

#### Step-2:

Jenkins Important in CI/CD Development?
1. **Automates the CI/CD Pipeline:**
Jenkins listens to your Git repository.
When developers push code, Jenkins triggers jobs: build, test, package, deploy.
This removes manual steps and reduces human error.

2. **Plugin Ecosystem:**
Jenkins has 1,800+ plugins for integration with almost anything: GitHub, Docker, Kubernetes (including EKS), Slack, Jira, etc.
This makes Jenkins highly flexible in connecting different tools in your DevOps stack.

3. **Build Automation:**
Jenkins compiles code, runs tests, packages artifacts (e.g., Docker images, JAR files, npm bundles).
This ensures every commit is validated and ready to deploy.

4. **Supports Continuous Deployment:**
Jenkins pipelines can automatically deploy new builds to staging or production environments.
You can connect Jenkins to EKS (or any Kubernetes cluster, VMs, or servers).

5. **Pipeline-as-Code:**
Jenkins uses Jenkinsfile (written in Groovy DSL) to define pipelines.
Pipelines can be version-controlled alongside code → reproducible, consistent deployments.

6. **Extensible for Any Workflow:**
You can create pipelines with stages for unit tests, integration tests, security scans, approvals, deployments.
Teams can enforce policies before software is promoted to production.

7. **Scalability & Distributed Builds:**
Jenkins can run builds on multiple worker nodes (agents), scaling across infrastructure.
This speeds up pipelines by distributing workloads.

8. **Integration with Containers & Cloud:**
Jenkins works great with Docker and Kubernetes (via EKS).
Typical flow: Jenkins builds a Docker image → pushes to ECR → triggers deployment in EKS.

**In Simple Terms:**
Jenkins = the automation brain (triggers, builds, tests, deploys).
EKS = the execution environment (runs the deployed application).

**So in a CI/CD pipeline:**
Jenkins detects code changes, builds, and runs tests.
Jenkins creates a Docker image and pushes it to a registry.
Jenkins updates EKS manifests (via kubectl or Helm) to roll out the new version.
EKS runs and manages the application.

----

**Create jenkins.sh:**

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

----

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

--- 

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

---

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

----

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

----

# Verify File Creation
if [[ -f "providers.tf" && -f "main.tf" && -f "variables.tf" && -f "data.tf" && -f "security.tf" ]]; then
    echo "All Terraform files created successfully."
else
    echo "Failed to create one or more Terraform files."
    exit 1
fi

echo "Setup completed successfully."
```

----

#### Step-3 Install Jenkins on the jenkins-server
change to root:
```bash
sudo su -
```

**Install the dependencies on the server**
```bash
yum -y update 
```

**Install Jenkins**
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

**Configure Jenkins:**
```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

----

#### Step-4 Install Maven 

##### What is Maven?
Apache Maven is a build automation and dependency management tool, mainly for Java-based projects (but can also be used with other languages).
It automates the build lifecycle: compiling code, running tests, packaging applications (e.g., JAR, WAR), and managing dependencies.
Instead of being a deployment environment (like EKS) or a CI/CD orchestrator (like Jenkins), Maven is focused on building and packaging applications.

Why is Maven Important in CI/CD Development?
1. **Standardized Build Process:**
Maven uses a convention-over-configuration approach.
Every project follows a standard structure (src/main/java, src/test/java, etc.).
This makes builds predictable and consistent across environments.

2. **Dependency Management:**
Maven uses a pom.xml (Project Object Model) file to define dependencies.
It automatically downloads required libraries from Maven Central or other repositories.
This ensures reproducibility — the same versions are used in dev, CI, and production.

3. **Integration with CI/CD Tools:**
Jenkins (and other CI/CD servers) can run Maven commands (mvn clean install, mvn test, mvn package) as build steps.
This means the same Maven build pipeline developers use locally is automated in CI/CD.

4. **Testing Support:**
Maven integrates with popular testing frameworks (JUnit, TestNG).
CI/CD pipelines can run automated tests through Maven before moving to deployment stages.

5. **Artifact Management:**
Maven packages the application into build artifacts (like JARs/WARs).
These artifacts can be stored in artifact repositories (e.g., Nexus, Artifactory) and then deployed via CI/CD.

6. **Extensible Plugins:**
Maven has a rich plugin ecosystem (e.g., plugins for Docker builds, Kubernetes deployments, reporting).

In a CI/CD workflow, Maven plugins can be used to:
Build Docker images.
Run code quality checks (SonarQube, PMD, Checkstyle).
Generate documentation.

7. **Consistency Across Environments:**
With Maven, the build command is the same everywhere (mvn clean install).
CI/CD pipelines benefit from this because builds are reproducible and not tied to local developer setups.

**In Simple Terms:**
Maven = the builder and packager (compiles code, manages dependencies, runs tests, packages output).
Jenkins = the automation engine (triggers Maven builds, runs pipelines).
EKS = the runtime environment (deploys and manages the application).

**So in a CI/CD pipeline**:
Developer pushes code.
Jenkins triggers a pipeline.
Jenkins runs Maven to build, test, and package the application.
The packaged artifact (e.g., JAR or Docker image) is stored in a registry.
Jenkins/CD step deploys it to EKS.
EKS runs the application.

```bash
cd /opt
wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
tar -xzvf apache-maven-3.9.11-bin.tar.gz

# When done
rm -r apache-maven-3.9.11-bin.tar.gz

# Rename the apache-maven 
mv apache-maven-3.9.11/ maven
```

**Configure Maven in .bash_profile:**
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

----

- Option 2
```bash
[root@master-server ~]# which java
/usr/bin/java
[root@master-server ~]# readlink -f $(which java)
/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java

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

**Test if Maven is working:** 
```bash
mvn -v
Apache Maven 3.9.11 (3e54c93a704957b63ee3494413a2b544fd3d825b)
Maven home: /opt/maven
Java version: 21.0.8, vendor: Amazon.com Inc., runtime: /usr/lib/jvm/java-21-amazon-corretto
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "4.14.355-280.679.amzn2.x86_64", arch: "amd64", family: "unix"
```

----

#### Step-5 Login into Jenkins and Configure
Open a new tab in browser, then get the aws instance <jenkins-server public ip>
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Install the plugins:**
![alt text](<images\Screenshot (131).png>)

Then go to Manage Jenkins -> Plugins and install: 
**Pipeline: Stage Step**
![alt text](<images\Screenshot (133).png>)

**Maven integration:**
![alt text](<images\Screenshot (134)-1.png>)

**Then go to Manage Jenkins -> Tools**
- add JDK
![alt text](<Screenshot (136).png>)
```bash
echo $JAVA_HOME
```

**Then add Maven location**
- add Maven:
![alt text](<images\Screenshot (137).png>)
```bash
echo $M2_HOME
```

Then disable Github Branch Source Plugin
![alt text](<images\Screenshot (138)-1.png>)

#### Step-6 Test Jenkins Maven Job
![alt text](<images\Screenshot (139).png>)

- Pull the Register App from Github
()[https://github.com/Ganil151/Register-App.git]
![alt text](<images\Screenshot (140).png>)

- In the Jenkins Job
![alt text](<Screenshot (141).png>)
  - create a git token for the project

- Add github credentials
![alt text](<images\Screenshot (142).png>)

![alt text](<images\Screenshot (143).png>)

- Set branch to */main
![alt text](<images\Screenshot (144).png>)

#### Step-7 Provision Ansible Server with Terraform
- Go back to Terraform Server 
```sh
cp -r jenkins/ ansible && cd ansible

# then remove all old terraform builds from the jenkins build
rm -r .terraform 
```

Make changes to **ansible/main.tf** file:
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

----

Make changes to **ansible/provider.tf**
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

----

Make changes to **ansiable/security_group:**

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

----

Make changes **ansible/variables.tf**

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

----

Then Pass Terraform
```bash
terraform init -reconfigure

# Then
terrafom plan -out=tfplan

# Then 
terraform apply -auto-approve tfplan 
```

#### Step-8 Install and Configure Ansiable

What is Ansible?
Ansible is an open-source IT automation and configuration management tool.
It automates tasks like provisioning servers, configuring environments, deploying applications, and orchestration across infrastructure.
Unlike Maven (build tool) or Jenkins (pipeline orchestrator), Ansible is focused on automating infrastructure and deployments.
It uses playbooks (written in YAML) to define desired states, making deployments idempotent (running the same playbook multiple times always produces the same result).

Why is Ansible Important in CI/CD Development?
1. **Automated Deployment:**
CI/CD pipelines often use Ansible to deploy applications after Jenkins/Maven have built them.
Instead of manually copying files or running shell scripts, Ansible ensures consistent, repeatable deployments.

2. **Infrastructure as Code (IaC):**
Ansible playbooks define infrastructure and configurations as code.
These playbooks can be version-controlled alongside application code.
This allows CI/CD pipelines to provision environments (e.g., dev, staging, prod) automatically.

3. **Consistency Across Environments:**
With Ansible, the same playbook can configure all environments identically.
This removes the “works on my machine” problem in CI/CD.

4. **Agentless Architecture:**
Unlike Chef/Puppet, Ansible is agentless — it only requires SSH and Python.
This makes it lightweight and easy to integrate into CI/CD workflows.

5. **Integration with CI/CD Tools:**
Jenkins can call Ansible playbooks as part of a pipeline. Example:

- Stage 1: Build app with Maven.

- Stage 2: Package Docker image.

- Stage 3: Deploy with Ansible (to VMs, cloud, or even Kubernetes manifests).

6. **Application & Infrastructure Management**

Ansible isn’t just for deployment — it can also:
Configure servers (OS, network, firewall).
Manage cloud resources (AWS, Azure, GCP).
Orchestrate container deployments (with Kubernetes/EKS).

7.**Rollback & Recovery:**
Ansible playbooks can include rollback steps.
In CI/CD, this means if a deployment fails, Ansible can revert the system to a stable state.

In Simple Terms:
Maven = builds the app.
Jenkins = orchestrates the pipeline.
Ansible = deploys and configures infrastructure/app.
EKS = runs the containerized application.

So in a CI/CD pipeline:
Developer pushes code.
Jenkins triggers the pipeline.
Maven builds and tests the code.
Jenkins packages the app into Docker image.
Ansible deploys the app (to EKS, VMs, or servers).
EKS (or infrastructure managed by Ansible) runs the application.

**Create a new user**
```bash
sudo su -

# Then 
adduser ansadmin
passwd ansadmin
```

**Add to SudoGroup** 
```bash
visudo 

# Under: Same thing without a password
# %wheel    ALL=(ALL)     NOPASSWD: ALL
ansadmin  ALL=(ALL)   NOPASSWD: ALL
:wq


# then 
cd /etc/ssh

```

**Edit sshd_config**
```bash
nano sshd_config

# Change 
PasswordAuthentication to yes

# Reload SSHD
service sshd reload
```

**Create SSH Key**
```bash
[ansadmin@ansible-server ~]$ su ansadmin
[ansadmin@ansible-server ~]$ cd ~
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

**Change Ownership & Mode**
```bash
sudo chown -R ansadmin:ansadmin /home/ansadmin/.ssh
sudo chmod 700 /home/ansadmin/.ssh
sudo chmod 600 /home/ansadmin/.ssh/id_rsa
sudo chmod 644 /home/ansadmin/.ssh/id_rsa.pub
```

**Install Ansiable** 
```bash
sudo su - 
# then 
amazon-linux-extras install ansible2
```

#### Step-9 Integrate Ansible with Jenkins

**Install Publish over SSH**
![alt text](<Screenshot (147).png>)
![alt text](<Screenshot (149).png>)

**Restart Jenkins**
```bash
[root@jenkins-server ~]# systemctl restart jenkins
```

**Configure Publish over SSH**
![alt text](<images\Screenshot (145).png>)

**Add SSH Server**
![alt text](<images\Screenshot (150).png>)

**Fillin:** <ansible-server-public-ip>
![alt text](<images\Screenshot (151)-1.png>)

**Go to Advance**: Fillin password
![alt text](<images\Screenshot (152).png>)
Test the Configuration then apply & save

#### Step-10 Install Docker in Ansible Server
What is Docker?
Docker is a platform for building, packaging, and running applications in containers.
A container is a lightweight, portable environment that includes everything an application needs to run: code, libraries, and dependencies.
Unlike VMs, containers share the host OS kernel, making them faster, smaller, and more portable.
In CI/CD, Docker ensures that the same application image runs consistently on a developer’s laptop, in CI pipelines, and in production (EKS, servers, or cloud).

Why is Docker Important in CI/CD Development?
1. **Consistency Across Environments:**
Docker removes the “works on my machine” issue.
CI/CD pipelines build a Docker image once, and that exact image runs in all environments (dev → staging → prod).

2. **Immutable Build Artifacts:**
Each CI pipeline run creates a versioned Docker image.
This makes builds reproducible and traceable, improving auditability and rollback in CI/CD.

3. **Integration with CI/CD Tools:**
Jenkins, GitHub Actions, GitLab CI, etc., can build and push Docker images to registries (e.g., Amazon ECR, Docker Hub).
CD steps then pull these images and deploy them to environments like EKS.

4. **Lightweight & Fast Deployments:**
Containers start in seconds compared to VMs.
This speed is crucial for CI/CD pipelines that spin up test environments on demand.

5. **Microservices Architecture:**
Modern applications are built as microservices, each in its own Docker container.
CI/CD pipelines can independently build, test, and deploy services, then run them together in orchestrators like Kubernetes/EKS.

6. **Supports Automated Testing:**
Pipelines can use Docker to spin up ephemeral test environments.
Example: start a database container and run integration tests against it, then tear it down automatically.

7. **Portability:**
Docker images can run anywhere: developer laptops, CI/CD servers, Kubernetes clusters, or cloud VMs.
This makes Docker the universal packaging format in CI/CD workflows.

In Simple Terms:

- Maven = compiles/builds the app.

- Jenkins = automates the pipeline.

- Docker = packages the app into a portable container.

- Ansible = deploys/configures the app & infrastructure.

- EKS = runs and manages the containers in production.

**So in a CI/CD pipeline:**
Developer pushes code.
Jenkins runs Maven to build & test.
Jenkins builds a Docker image.
Docker image is pushed to a registry (ECR, Docker Hub).
Ansible (or Helm/Kubectl) deploys the Docker container to EKS.
EKS orchestrates and scales the running containers.

**Setup for Docker installation**
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
**Run a Docker Test:**
![alt text](<images\Screenshot (153).png>)

**Go to Configure:**
![alt text](<images\Screenshot (154).png>)

**Slide down Post-Build Actions:**
![alt text](<images\Screenshot (155).png>)

**Go to Send build artifacts over SSH:**
![alt text](<images\Screenshot (157).png>)

![alt text](<Screenshot (158).png>)

**Fillin:**
![alt text](<Screenshot (162).png>)
Apply and Save

**Then Build:**
![alt text](<images\Screenshot (160).png>)

**Install Docker after Build is successful**
```bash
[ansadmin@ansible-server ~]$ ls /opt/docker/
myprojectapp.war
[ansadmin@ansible-server ~]$ cd /opt/docker/
[ansadmin@ansible-server docker]$ sudo yum install -y docker
```

- Add Docker to ansadmin user group 
```bash
[ansadmin@ansible-server docker]$ sudo usermod -aG docker ansadmin
[ansadmin@ansible-server docker]$ id ansadmin
uid=1001(ansadmin) gid=1001(ansadmin) groups=1001(ansadmin),992(docker)
```

- Start Docker Services 
```bash
sudo systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: https://docs.docker.com
[ansadmin@ansible-server docker]$ sudo systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
[ansadmin@ansible-server docker]$ sudo systemctl start docker
[ansadmin@ansible-server docker]$ sudo systemctl status docker
# Then restart the Ansible-Server
sudo init 6
```

----

#### Create Project Dockefile in Ansible Server
```Dockerfile
FROM tomcat:latest 
RUN cp -R /usr/local/tomcat/webapps.dist/* /usr/local/tomcat/webapps
COPY ./*.war /usr/local/tomcat/webapps/register.war
```

----

#### Create Ansible Playbook for Docker Tasks

**Login into Docker**
```bash
[ansadmin@ansible-server ~]$ docker login -u ganil151
Password: # Docker Password 
```

**Edit Ansible Host**
```bash 
# Remove everything in the file   
sudo vi /etc/ansible/hosts

# Add Ansible-Server Private Ip in the 
[ansible]
10.0.1.45 ansible_user=ansadmin ansible_ssh_private_key_file=/home/ansadmin/.ssh/id_rsa
```

Copy ssh key to the private ip, from the **ssh-key** that was generated earlier
```sh
ssh-copy-id 10.0.1.45
#Or
ssh-copy-id ansadmin@10.0.1.45 # with the username

# Output-1:
/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansadmin/.ssh/id_rsa.pub"
/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed

/bin/ssh-copy-id: WARNING: All keys were skipped because they already exist on the remote system.
                (if you think this is a mistake, you may want to use -f option)

# Output-2:
/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansadmin/.ssh/id_rsa.pub"
The authenticity of host '10.0.1.45 (10.0.1.45)' can't be established.
ECDSA key fingerprint is SHA256:M13tZlvdk6nSPxntLNECArWpRNm95eLPr42FivSd3Zk.
ECDSA key fingerprint is MD5:c2:7b:1f:84:e5:1b:9e:b2:38:25:70:a3:9b:fd:60:f4.
Are you sure you want to continue connecting (yes/no)? yes
/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansadmin@10.0.1.45's password: # Add the ansadmin password

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '10.0.1.45'"
and check to make sure that only the key(s) you wanted were added.
```
**Create a Manifest file**
```bash
[ansadmin@ansible-server ~]$ sudo vi register-ci.yml

- hosts: ansible

  tasks:
  - name: create docker image
    command: docker build -t register-1:latest .
    args:
      chdir: /opt/docker

  - name: create tag to push image onto dockerhub
    command: docker tag register-1:latest ganil151/register-1:latest

  - name: push docker image
    command: docker push ganil151/register-1:latest

```
**AI Example:**
- before using AI Example:
```bash
ansible-galaxy collection install community.docker
```
- Then edit: register-1-ci.yml 
```bash
---
- hosts: ansible
  become: yes
  tasks:
    - name: Ensure Docker is installed
      package:
        name: docker
        state: present

    - name: Build docker image
      community.docker.docker_image:
        name: register-1
        tag: latest
        build:
          path: /opt/docker

    - name: Login to Docker Hub
      community.docker.docker_login:
        username: ganil151
        password: "{{ dockerhub_password }}"

    - name: Push docker image
      community.docker.docker_image:
        name: register-1
        tag: latest
        push: yes

```

Go back to Jenkins <http://52.55.121.151:8080/> and start a new Job:
![alt text](<images\Screenshot (163).png>)

Start a new Job
![alt text](<images\Screenshot (164).png>)

Get github repositories
![alt text](<images\Screenshot (165).png>)

then:
![alt text](<images\Screenshot (166).png>)

then: 
![alt text](<images\Screenshot (167).png>)

----

#### Provision EKS Server with Terraform 

**Set-up Eks Server in the Terraform Server**

```bash
cp -r ansible eks-server
[ec2-user@Terraform-Server ~]$ ls
ansible  eks-server  jenkins
[ec2-user@Terraform-Server ~]$ cd eks-server/
[ec2-user@Terraform-Server eks-server]$ ls
data.tf  main.tf  provider.tf  security.tf  tfplan  variables.tf
[ec2-user@Terraform-Server eks-server]$ ls -a
.   .terraform           data.tf  provider.tf  tfplan
..  .terraform.lock.hcl  main.tf  security.tf  variables.tf
[ec2-user@Terraform-Server eks-server]$ rm -r .terraform*
```

---- 

Change the name in **main.tf**
```bash
resource "aws_instance" "Eks-Server" { # here
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]

  tags = {
    Name = "Eks-Server" # here
  }
}
```

----

Make changes to **provider.tf**:
```bash
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
    key    = "eks-server/terraform.tfstate" # here
    region = "us-east-1"

  }
}

provider "aws" {
  region = "us-east-1"

}
```

----

Change the name in **Security.tf** file
```bash
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_sg_2_${var.project_name}"
  description = "Allow inbound/outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicd_sg_2"
  }
}
```

----

#### Provision EKS Cluster using eksctl

##### What is EKS Server?
When people say “EKS server”, they’re usually referring to Amazon EKS (Elastic Kubernetes Service) clusters that run on AWS.
EKS is Amazon’s managed Kubernetes service.
Instead of you setting up and managing Kubernetes control planes and nodes yourself, AWS does that heavy lifting.
With EKS, you get a Kubernetes cluster where you can deploy, manage, and scale containerized applications.
So, “EKS server” isn’t a literal single server — it’s shorthand for the Kubernetes cluster and infrastructure managed by AWS.

Why is EKS Important in CI/CD Development?
CI/CD (Continuous Integration / Continuous Deployment) is all about automating the software release pipeline so that code changes go from developer laptops → testing → staging → production quickly and safely.
Here’s where EKS fits in:

1. **Scalable & Reliable Deployment Environment**:
Kubernetes (via EKS) automatically handles load balancing, scaling, and failover for applications.
Your CI/CD pipeline can push new builds into EKS without worrying about infrastructure details.
As traffic grows, EKS scales up pods automatically.

2. **Containerized Workloads**:
Modern CI/CD pipelines usually build Docker containers.
EKS natively runs containers, so it becomes the natural target for deploying builds.
This ensures consistency: the same container that passed CI tests is the one running in production.

3. **Automated Rollouts & Rollbacks**:
EKS supports rolling updates. When a new image is deployed, pods are replaced gradually.
If something fails, Kubernetes automatically rolls back to the previous version.
This reduces downtime and risk in CI/CD releases.

4. **Integration with CI/CD Tools**:
Popular CI/CD platforms (e.g., Jenkins, GitHub Actions, GitLab CI, ArgoCD, Tekton) integrate seamlessly with EKS.
You can automate deployments: every time code is merged, a pipeline builds a new Docker image, pushes it to Amazon ECR (Elastic Container Registry), and updates workloads in EKS.

5. **Infrastructure as Code (IaC)**:
With tools like Terraform, Helm, or AWS CDK, you can define your Kubernetes deployments as code.
This fits naturally into CI/CD — infrastructure and app updates can be version-controlled and deployed together.

6. **Security & Compliance**:
AWS manages Kubernetes control plane patches, upgrades, and security fixes.
You can integrate IAM (Identity and Access Management), network policies, and secrets management into your CI/CD workflow.
This ensures secure, compliant software delivery.

7. **Multi-Environment Support**:
You can run multiple namespaces or clusters for dev, staging, and production.
Your CI/CD pipeline can promote builds across these environments automatically, ensuring consistent deployments.

**In Simple Terms:**
Think of EKS as the engine that runs all the containerized applications.
In CI/CD:
CI builds and tests the app → produces a Docker image.
CD pushes that image into EKS, where Kubernetes ensures it runs smoothly, scales, updates, or rolls back automatically.
Without something like EKS, you’d have to manually manage servers, scaling, and deployments — which defeats the purpose of CI/CD automation.

Go to Link: (Amazon_EKS)[https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html]


```bash
[ec2-user@eks-server ~]$ sudo su -
[root@eks-server ~]# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.4/2025-08-20/bin/linux/amd64/kubectl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 57.3M  100 57.3M    0     0  23.4M      0  0:00:02  0:00:02 --:--:-- 23.4M
[root@eks-server ~]# chmod +x ./kubectl
[root@eks-server ~]# ls
kubectl
[root@eks-server ~]# mv kubectl /bin
[root@eks-server ~]# ls /bin | grep kubectl
kubectl
```

- Install Eksctl At: [https://github.com/eksctl-io/eksctl/blob/main/README.md#installation]
```bash 
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
cd /tmp
sudo mv /tmp/eksctl /bin
eksctl version
```
- Create and Attach roles to the EKS Server
```bash
AmazonEC2FullAccess
AWSCloudFormationFullAccess
IAMFullAccess
AdministratorAccess
```
![alt text](<images\Screenshot (168).png>)
![alt text](<images\Screenshot (169).png>)
![alt text](<images\Screenshot (170).png>)
![alt text](<images\Screenshot (171).png>)
![alt text](<images\Screenshot (172).png>)
![alt text](<images\Screenshot (173).png>)

- Launch the Eks Cluster 
```bash
eksctl create cluster --name registerapp-cluster \
--region us-east-1 \
--node-type t3.small
```

##### To install the AWS CLI, run the following commands:
(Link)[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html]
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
Update and Get the Nodes
```bash
aws eks update-kubeconfig --region us-east-1 --name register-cluster

# Output:
Added new context arn:aws:eks:us-east-1:365269738775:cluster/register-cluster to /root/.kube/config

# Then
kubectl get nodes

# Output
NAME                            STATUS   ROLES    AGE   VERSION
ip-192-168-3-196.ec2.internal   Ready    <none>   36m   v1.32.8-eks-99d6cc0
ip-192-168-47-98.ec2.internal   Ready    <none>   36m   v1.32.8-eks-99d6cc0

# Then
kubectl get pods
```

##### Create deployment manifest files
```bash
vi register-deployment.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: register 
  labels:
    app: register

spec:
  replicas: 2
  selector:
    matchLabels:
      app: register
  template:
    metadata:
      labels:
        app: register
    spec:
      containers:
      - name: register
        image: ganil151/register
        ports:
        - containerPort: 8080
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

----

Create `Register Service` file:
```bash
vi register-service.yml

apiVersion: v1 
kind: Service 
metadata: 
  name: service
  labels: 
    app: register
spec:
  selector:
    app: register

  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
  
  type: LoadBalancer  
```

#### Intergrate EKS Server with Ansible

Enable: Go to /etc/ssh/sshd_config
`PasswordAuthentication yes` 

Set Password for Root:
```bash
[root@eks-server ~]# passwd root
Changing password for user root.
New password:
BAD PASSWORD: The password fails the dictionary check - it is based on a dictionary word
Retype new password:
passwd: all authentication tokens updated successfully

# Then
service sshd reload
```

Go back to the ansible-server:
```bash
# sudo to Root user that was created
[ansadmin@ansible-server ~]$ sudo su ansadmin

# Then 
[ansadmin@ansible-server ~]$ sudo vi /etc/ansible/hosts
[ansible]
10.0.1.45 ansible_user=ansadmin ansible_ssh_private_key_file=/home/ansadmin/.ssh/id_rsa

[kubernetes]                                                                         
10.0.1.13 #<eks-server-private-ip>
```
Copy ssh public key that was created earlier
```bash
[ansadmin@ansible-server ~]$ ssh-copy-id root@10.0.1.13
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/ansadmin/.ssh/id_rsa.pub"
The authenticity of host '10.0.1.13 (10.0.1.13)' can't be established.
ECDSA key fingerprint is SHA256:xDdHjirqKaRQJAij9sY49h/Zr2YX9EgR/NWYGUqk61I.
ECDSA key fingerprint is MD5:a4:69:23:2b:18:36:9d:56:de:42:76:0f:b5:be:50:1c.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@10.0.1.13's password: #<password from eks-server>

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@10.0.1.13'"
and check to make sure that only the key(s) you wanted were added.
```

#### Create Ansible Playbook for the deployment
Create kube_deploy.yml file in ansible-server /opt/docker
```bash
- hosts: kubernetes
  user: root 

  tasks: 
   - name: deploy regapp on kubernetes
     command: kubectl apply -f register-deployment.yml

   - name: create service for regapp
     command: kubectl apply -f register-service.yml
  
   - name: update deployment with new pods if image updated in docker hub
     command: kubectl rollout restart deployment.apps/register
```

Run a test Ansible Playbook kube_deploy.yml:
```bash
[ansadmin@ansible-server ~]$ ansible-playbook kube_deploy.yml --check

# Correct Output
PLAY [kubernetes] *******************************************************************

TASK [Gathering Facts] **************************************************************
[WARNING]: Platform linux on host 10.0.1.13 is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html
for more information.
ok: [10.0.1.13]

TASK [deploy regapp on kubernetes] **************************************************
skipping: [10.0.1.13]

TASK [create service for regapp] ****************************************************
skipping: [10.0.1.13]

TASK [update deployment with new pods if image updated in docker hub] ***************
skipping: [10.0.1.13]

PLAY RECAP **************************************************************************
10.0.1.13                  : ok=1    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

# Then Run the Code:
ansible-playbook kube_deploy.yml
```

Now go back to Eks-Server and check if everthings working:
```bash
[root@eks-server ~]# kubectl get pods
# Output
NAME                       READY   STATUS    RESTARTS   AGE
register-c7d4b99d4-d5dbr   1/1     Running   0          2m13s
register-c7d4b99d4-stcbc   1/1     Running   0          2m13s

# Then run:
[root@eks-server ~]# kubectl get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/register-c7d4b99d4-d5dbr   1/1     Running   0          9m24s
pod/register-c7d4b99d4-stcbc   1/1     Running   0          9m24s

NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
service/kubernetes   ClusterIP      10.100.0.1       <none>                                                                    443/TCP          126m
service/service      LoadBalancer   10.100.250.100   a8dece2e8b78b4326b1a89cc131375fc-2032408722.us-east-1.elb.amazonaws.com   8080:32481/TCP   9m25s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/register   2/2     2            2           9m27s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/register-6f8df655cb   0         0         0       9m27s
replicaset.apps/register-c7d4b99d4    2         2         2       9m24s
```

#### Create Continouse Deployment Job on Jenkins
Go to Jenkins and create a new Job:
![alt text](<images\Screenshot (174).png>)

Post-build Actions
![alt text](<images\Screenshot (175).png>)

Send build artifacts over SSH:
![alt text](<images\Screenshot (176).png>)

Under Exec command add the ansible playbook:
![alt text](<images\Screenshot (177).png>)

#### Integrate the CI and the CD Jobs:
Go to Register-CI job and configure:
![alt text](<images\Screenshot (178).png>)

Check Poll SCM:
![alt text](<images\Screenshot (179).png>)

Go to Add post-build action and click `Build other projects`:
![alt text](<images\Screenshot (180).png>)

Slide up to Post-Build Actions to build `Register-CD`:
![alt text](<images\Screenshot (181).png>)

Then Run the build on Register-CI, and confirm the it was built in Register-CD 

#### Deploy/Test the CI/CD Configurations
- Go to ~/Documents/Register-App and push to github
- Check github webhook 
- Check Docker Hub
- Check Eks-server:
```bash
 kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
register-77bfd55865-lhmxb   1/1     Running   0          16m
register-77bfd55865-nsf8d   1/1     Running   0          16m
[root@eks-server ~]# kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
register-77bfd55865-lhmxb   1/1     Running   0          18m
register-77bfd55865-nsf8d   1/1     Running   0          18m
[root@eks-server ~]# kubectl get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
kubernetes   ClusterIP      10.100.0.1       <none>                                                                    443/TCP          3h23m
service      LoadBalancer   10.100.250.100   a8dece2e8b78b4326b1a89cc131375fc-2032408722.us-east-1.elb.amazonaws.com   8080:32481/TCP   86m
```

Go to the browser: 
```bash
paste: a8dece2e8b78b4326b1a89cc131375fc-2032408722.us-east-1.elb.amazonaws.com:8080
```
![alt text](<images\Screenshot (182).png>)

![alt text](<images\Screenshot (183).png>)