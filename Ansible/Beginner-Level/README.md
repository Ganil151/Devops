# Beginner Level - Ansible Fundamentals

Master the core concepts and basic automation capabilities of Ansible through hands-on learning and practical exercises.

## 🎯 Learning Objectives

By completing this level, you will:
- Understand Ansible architecture and core concepts
- Install and configure Ansible on various platforms
- Create and manage inventory files for different environments
- Write basic playbooks with tasks, handlers, and variables
- Use essential Ansible modules for system administration
- Implement variables, facts, and basic templating
- Follow Ansible best practices and conventions

## 📚 Module Overview

### [01-Ansible-Fundamentals](./01-Ansible-Fundamentals/)
**Duration**: 1 week  
**Focus**: Core concepts, architecture, and installation

**Topics Covered**:
- What is Ansible and why use it
- Ansible architecture and components
- Installation methods and requirements
- Basic configuration and setup
- Ad-hoc commands and modules
- Understanding the control node and managed nodes

**Learning Outcomes**:
- [ ] Explain Ansible's agentless architecture
- [ ] Install Ansible on different operating systems
- [ ] Configure basic Ansible settings
- [ ] Execute ad-hoc commands successfully
- [ ] Understand the difference between control and managed nodes

### [02-Inventory-Management](./02-Inventory-Management/)
**Duration**: 1 week  
**Focus**: Host and group management, inventory patterns

**Topics Covered**:
- Static inventory (INI and YAML formats)
- Dynamic inventory concepts
- Host and group variables
- Inventory patterns and ranges
- Connection parameters and SSH configuration
- Inventory best practices

**Learning Outcomes**:
- [ ] Create static inventory files in both INI and YAML formats
- [ ] Organize hosts into logical groups
- [ ] Define host and group variables
- [ ] Use inventory patterns for host selection
- [ ] Configure SSH connections for managed nodes

### [03-Basic-Playbooks](./03-Basic-Playbooks/)
**Duration**: 1 week  
**Focus**: Playbook structure, tasks, and handlers

**Topics Covered**:
- YAML syntax and structure
- Playbook anatomy and components
- Tasks and task execution
- Handlers and notifications
- Play-level and task-level directives
- Basic playbook organization

**Learning Outcomes**:
- [ ] Write well-structured YAML playbooks
- [ ] Create tasks that perform specific actions
- [ ] Implement handlers for service management
- [ ] Use play-level directives effectively
- [ ] Organize playbooks for maintainability

### [04-Core-Modules](./04-Core-Modules/)
**Duration**: 1 week  
**Focus**: Essential modules for system administration

**Topics Covered**:
- File and directory operations (file, copy, template)
- Package management (package, yum, apt)
- Service management (service, systemd)
- Command execution (command, shell, script)
- User and group management (user, group)
- System information gathering (setup, debug)

**Learning Outcomes**:
- [ ] Manage files and directories effectively
- [ ] Install and manage software packages
- [ ] Control system services
- [ ] Execute commands safely
- [ ] Manage users and groups
- [ ] Gather and display system information

### [05-Variables-and-Facts](./05-Variables-and-Facts/)
**Duration**: 1 week  
**Focus**: Data management and system information

**Topics Covered**:
- Variable types and scopes
- Variable precedence rules
- Defining variables in different locations
- System facts and custom facts
- Registered variables
- Variable validation and debugging

**Learning Outcomes**:
- [ ] Define and use variables effectively
- [ ] Understand variable precedence
- [ ] Leverage system facts in playbooks
- [ ] Create and use registered variables
- [ ] Debug variable values and types

### [06-Basic-Templates](./06-Basic-Templates/)
**Duration**: 1 week  
**Focus**: Jinja2 templating fundamentals

**Topics Covered**:
- Jinja2 template syntax
- Variable substitution
- Basic filters and functions
- Conditional statements in templates
- Simple loops in templates
- Template best practices

**Learning Outcomes**:
- [ ] Create dynamic configuration files using templates
- [ ] Use Jinja2 filters for data manipulation
- [ ] Implement conditional logic in templates
- [ ] Use loops for repetitive content
- [ ] Follow template organization best practices

## 🛠️ Prerequisites

### Technical Requirements
- **Operating System**: Linux, macOS, or Windows (with WSL)
- **Python**: Version 3.6 or higher
- **SSH**: Basic understanding of SSH key authentication
- **Text Editor**: Any text editor (VS Code, Vim, Nano, etc.)

### Knowledge Prerequisites
- Basic Linux/Unix command line skills
- Understanding of YAML syntax
- Basic networking concepts (IP addresses, ports)
- Text editing and file management skills

### Hardware Requirements
- **Control Node**: 2GB RAM, 10GB disk space
- **Test Environment**: Virtual machines or containers for practice

## 🏗️ Lab Environment Setup

### Option 1: Local Virtual Machines
```bash
# Using Vagrant for lab setup
mkdir ansible-lab && cd ansible-lab

# Create Vagrantfile
cat > Vagrantfile << 'EOF'
Vagrant.configure("2") do |config|
  # Control node
  config.vm.define "control" do |control|
    control.vm.box = "ubuntu/20.04"
    control.vm.hostname = "ansible-control"
    control.vm.network "private_network", ip: "192.168.56.10"
    control.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
  end
  
  # Managed nodes
  (1..3).each do |i|
    config.vm.define "node#{i}" do |node|
      node.vm.box = "ubuntu/20.04"
      node.vm.hostname = "ansible-node#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{10+i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
      end
    end
  end
end
EOF

# Start the lab environment
vagrant up
```

### Option 2: Docker Containers
```bash
# Create Docker-based lab environment
mkdir ansible-docker-lab && cd ansible-docker-lab

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  control:
    image: ubuntu:20.04
    container_name: ansible-control
    command: sleep infinity
    volumes:
      - ./ansible-workspace:/workspace
    networks:
      ansible-net:
        ipv4_address: 172.20.0.10
  
  node1:
    image: ubuntu:20.04
    container_name: ansible-node1
    command: sleep infinity
    networks:
      ansible-net:
        ipv4_address: 172.20.0.11
  
  node2:
    image: ubuntu:20.04
    container_name: ansible-node2
    command: sleep infinity
    networks:
      ansible-net:
        ipv4_address: 172.20.0.12

networks:
  ansible-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

# Start the lab environment
docker-compose up -d
```

### Option 3: Cloud-Based Lab
```bash
# AWS EC2 instances using Terraform
mkdir ansible-aws-lab && cd ansible-aws-lab

# Create main.tf
cat > main.tf << 'EOF'
provider "aws" {
  region = "us-east-1"
}

# Security group for Ansible
resource "aws_security_group" "ansible_sg" {
  name_prefix = "ansible-lab-"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Control node
resource "aws_instance" "control" {
  ami           = "ami-0c02fb55956c7d316"  # Ubuntu 20.04
  instance_type = "t3.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.ansible_sg.name]
  
  tags = {
    Name = "ansible-control"
    Type = "control"
  }
}

# Managed nodes
resource "aws_instance" "nodes" {
  count         = 3
  ami           = "ami-0c02fb55956c7d316"  # Ubuntu 20.04
  instance_type = "t3.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.ansible_sg.name]
  
  tags = {
    Name = "ansible-node-${count.index + 1}"
    Type = "managed"
  }
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}
EOF

# Deploy the infrastructure
terraform init
terraform plan
terraform apply
```

## 📝 Hands-On Labs

### Lab 1: Ansible Installation and Setup
**Objective**: Install Ansible and verify the installation
**Duration**: 30 minutes

**Tasks**:
1. Install Ansible using package manager
2. Verify installation with version check
3. Create basic ansible.cfg file
4. Set up SSH key authentication
5. Test connectivity to managed nodes

### Lab 2: Inventory Creation and Management
**Objective**: Create and manage inventory files
**Duration**: 45 minutes

**Tasks**:
1. Create static inventory in INI format
2. Convert inventory to YAML format
3. Define host and group variables
4. Test inventory with ansible commands
5. Use inventory patterns for host selection

### Lab 3: First Playbook Creation
**Objective**: Write and execute your first playbook
**Duration**: 60 minutes

**Tasks**:
1. Create a simple playbook structure
2. Add tasks for package installation
3. Implement handlers for service management
4. Use variables in playbook
5. Execute playbook and verify results

### Lab 4: System Administration with Modules
**Objective**: Use core modules for system tasks
**Duration**: 90 minutes

**Tasks**:
1. Manage files and directories
2. Install and configure software packages
3. Manage system services
4. Create and manage users
5. Gather system information

### Lab 5: Working with Variables and Facts
**Objective**: Implement variables and leverage facts
**Duration**: 60 minutes

**Tasks**:
1. Define variables at different levels
2. Use system facts in playbooks
3. Create registered variables
4. Debug variable values
5. Implement variable validation

### Lab 6: Template Configuration Files
**Objective**: Create dynamic configuration files
**Duration**: 75 minutes

**Tasks**:
1. Create Jinja2 templates
2. Use variables in templates
3. Implement conditional logic
4. Use loops for repetitive content
5. Deploy templates to managed nodes

## 📊 Assessment Methods

### Practical Assessments (60%)
- **Lab Completion**: Successfully complete all hands-on labs
- **Playbook Creation**: Create functional playbooks for given scenarios
- **Problem Solving**: Troubleshoot and fix broken automation

### Knowledge Checks (25%)
- **Concept Quizzes**: Multiple choice questions on Ansible concepts
- **Scenario Analysis**: Analyze automation scenarios and recommend solutions
- **Best Practices**: Identify and explain Ansible best practices

### Project Work (15%)
- **Mini Project**: Automate a complete system setup scenario
- **Documentation**: Document playbooks and procedures
- **Presentation**: Present automation solution to peers

## 🎯 Success Criteria

### Module Completion Requirements
- [ ] Complete all hands-on labs with 80% accuracy
- [ ] Pass knowledge checks with 75% or higher score
- [ ] Successfully complete the mini project
- [ ] Demonstrate understanding through peer discussions

### Skill Validation Checklist
- [ ] Can install and configure Ansible
- [ ] Can create and manage inventory files
- [ ] Can write basic playbooks with tasks and handlers
- [ ] Can use essential Ansible modules effectively
- [ ] Can implement variables and use system facts
- [ ] Can create simple Jinja2 templates
- [ ] Follows Ansible best practices and conventions

## 🚀 Next Steps

Upon successful completion of Beginner Level:

### Immediate Actions
1. **Review and Reinforce**: Practice the concepts learned
2. **Build Portfolio**: Create a collection of playbooks
3. **Join Community**: Participate in Ansible forums and discussions

### Preparation for Intermediate Level
1. **Advanced YAML**: Study complex YAML structures
2. **Python Basics**: Learn Python fundamentals for module development
3. **Git Proficiency**: Improve version control skills
4. **Linux Administration**: Strengthen system administration skills

### Recommended Reading
- "Ansible: Up and Running" by Lorin Hochstein
- "Ansible for DevOps" by Jeff Geerling
- Official Ansible Documentation
- Ansible Best Practices Guide

## 📚 Additional Resources

### Documentation
- [Ansible Beginner's Guide](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html)
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [YAML Syntax Guide](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)

### Video Tutorials
- Ansible Basics Video Series
- Red Hat Ansible Automation Platform Training
- YouTube Ansible Tutorials

### Practice Platforms
- [Katacoda Ansible Scenarios](https://www.katacoda.com/courses/ansible)
- [Play with Ansible](https://labs.play-with-docker.com/)
- Local lab environments

### Community Support
- [Ansible Community Forum](https://forum.ansible.com/)
- [Reddit r/ansible](https://www.reddit.com/r/ansible/)
- [Stack Overflow Ansible Tag](https://stackoverflow.com/questions/tagged/ansible)

---

**Ready to begin your Ansible journey? Start with Module 01-Ansible-Fundamentals and work through each module systematically. Remember to practice regularly and don't hesitate to ask questions in the community forums!**