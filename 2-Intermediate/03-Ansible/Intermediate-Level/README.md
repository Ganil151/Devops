# Intermediate Level - Advanced Ansible Automation

Develop advanced Ansible skills including role development, complex playbooks, secrets management, and enterprise automation patterns.

## 🎯 Learning Objectives

By completing this level, you will:
- Design and develop reusable Ansible roles
- Create complex multi-play playbooks with advanced features
- Implement secure secrets management with Ansible Vault
- Handle errors gracefully and implement recovery mechanisms
- Master advanced control structures (loops, conditionals, blocks)
- Develop custom modules and plugins for specific requirements
- Apply enterprise automation patterns and best practices

## 📚 Module Overview

### [01-Ansible-Roles](./01-Ansible-Roles/)
**Duration**: 2 weeks  
**Focus**: Role development, structure, and distribution

**Topics Covered**:
- Role anatomy and directory structure
- Role development best practices
- Role dependencies and meta information
- Ansible Galaxy integration
- Role testing with Molecule
- Role versioning and distribution

**Learning Outcomes**:
- [ ] Create well-structured, reusable Ansible roles
- [ ] Implement role dependencies and meta information
- [ ] Publish roles to Ansible Galaxy
- [ ] Test roles using Molecule framework
- [ ] Version and maintain roles effectively

### [02-Advanced-Playbooks](./02-Advanced-Playbooks/)
**Duration**: 2 weeks  
**Focus**: Complex playbook patterns and orchestration

**Topics Covered**:
- Multi-play playbooks and orchestration
- Playbook includes and imports
- Dynamic includes and conditional execution
- Playbook strategies and execution control
- Rolling updates and zero-downtime deployments
- Playbook optimization techniques

**Learning Outcomes**:
- [ ] Design complex multi-tier deployment playbooks
- [ ] Implement dynamic playbook execution
- [ ] Orchestrate rolling updates safely
- [ ] Optimize playbook performance
- [ ] Handle complex deployment scenarios

### [03-Ansible-Vault](./03-Ansible-Vault/)
**Duration**: 1 week  
**Focus**: Comprehensive secrets management

**Topics Covered**:
- Vault encryption and decryption
- Multiple vault IDs and password management
- Vault integration with external systems
- Vault best practices and security
- CI/CD integration with Vault
- Vault troubleshooting and recovery

**Learning Outcomes**:
- [ ] Implement comprehensive secrets management
- [ ] Use multiple vault IDs effectively
- [ ] Integrate Vault with external secret stores
- [ ] Secure CI/CD pipelines with Vault
- [ ] Troubleshoot Vault-related issues

### [04-Error-Handling](./04-Error-Handling/)
**Duration**: 1 week  
**Focus**: Robust automation and recovery

**Topics Covered**:
- Error handling strategies
- Block, rescue, and always constructs
- Failed_when and changed_when conditions
- Retry mechanisms and timeouts
- Debugging techniques and tools
- Rollback and recovery procedures

**Learning Outcomes**:
- [ ] Implement robust error handling
- [ ] Design recovery and rollback mechanisms
- [ ] Use debugging tools effectively
- [ ] Create resilient automation workflows
- [ ] Handle edge cases and failures gracefully

### [05-Loops-and-Conditionals](./05-Loops-and-Conditionals/)
**Duration**: 1 week  
**Focus**: Advanced control structures

**Topics Covered**:
- Advanced loop constructs (with_items, loop, until)
- Complex conditional logic
- Combining loops and conditionals
- Performance considerations
- Loop control and optimization
- Dynamic data structures

**Learning Outcomes**:
- [ ] Implement complex loop patterns
- [ ] Use advanced conditional logic
- [ ] Optimize loop performance
- [ ] Handle dynamic data structures
- [ ] Combine control structures effectively

### [06-Custom-Modules](./06-Custom-Modules/)
**Duration**: 2 weeks  
**Focus**: Module and plugin development

**Topics Covered**:
- Python module development
- Module documentation and testing
- Custom filter and lookup plugins
- Callback and connection plugins
- Module distribution and packaging
- Plugin development best practices

**Learning Outcomes**:
- [ ] Develop custom Python modules
- [ ] Create filter and lookup plugins
- [ ] Test and document custom modules
- [ ] Package and distribute modules
- [ ] Follow plugin development best practices

## 🛠️ Prerequisites

### Technical Requirements
- **Completed**: Beginner Level Ansible course
- **Python**: Intermediate Python programming skills
- **Git**: Proficiency with Git version control
- **Linux**: Advanced Linux system administration
- **Networking**: Understanding of network protocols and services

### Knowledge Prerequisites
- Solid understanding of Ansible fundamentals
- Experience with YAML and Jinja2 templating
- Basic Python programming knowledge
- Understanding of software development lifecycle
- Familiarity with testing frameworks

### Development Environment
- **IDE**: VS Code, PyCharm, or similar with Ansible extensions
- **Testing**: Molecule, Ansible Lint, pytest
- **Version Control**: Git with GitHub/GitLab
- **Virtualization**: Docker, Vagrant, or cloud instances

## 🏗️ Advanced Lab Environment

### Multi-Tier Infrastructure Setup
```bash
# Advanced lab environment with multiple tiers
mkdir ansible-advanced-lab && cd ansible-advanced-lab

# Create comprehensive Vagrantfile
cat > Vagrantfile << 'EOF'
Vagrant.configure("2") do |config|
  # Load balancer
  config.vm.define "lb" do |lb|
    lb.vm.box = "ubuntu/20.04"
    lb.vm.hostname = "loadbalancer"
    lb.vm.network "private_network", ip: "192.168.56.10"
    lb.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end
  end
  
  # Web servers
  (1..3).each do |i|
    config.vm.define "web#{i}" do |web|
      web.vm.box = "ubuntu/20.04"
      web.vm.hostname = "webserver#{i}"
      web.vm.network "private_network", ip: "192.168.56.#{10+i}"
      web.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 1
      end
    end
  end
  
  # Database servers
  (1..2).each do |i|
    config.vm.define "db#{i}" do |db|
      db.vm.box = "ubuntu/20.04"
      db.vm.hostname = "database#{i}"
      db.vm.network "private_network", ip: "192.168.56.#{20+i}"
      db.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 2
      end
    end
  end
  
  # Monitoring server
  config.vm.define "monitor" do |monitor|
    monitor.vm.box = "ubuntu/20.04"
    monitor.vm.hostname = "monitoring"
    monitor.vm.network "private_network", ip: "192.168.56.30"
    monitor.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
  end
end
EOF
```

### Container-Based Development Environment
```bash
# Docker-based development environment
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'
services:
  ansible-dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: ansible-development
    volumes:
      - ./workspace:/workspace
      - ~/.ssh:/root/.ssh:ro
      - ~/.aws:/root/.aws:ro
    environment:
      - ANSIBLE_HOST_KEY_CHECKING=False
    networks:
      - ansible-dev-net
    command: sleep infinity
  
  molecule-test:
    image: quay.io/ansible/molecule:latest
    container_name: molecule-testing
    volumes:
      - ./roles:/roles
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - ansible-dev-net

networks:
  ansible-dev-net:
    driver: bridge
EOF

# Development Dockerfile
cat > Dockerfile.dev << 'EOF'
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    git \
    ssh \
    sshpass \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    ansible \
    molecule[docker] \
    ansible-lint \
    yamllint \
    pytest \
    pytest-ansible

WORKDIR /workspace
EOF
```

## 📝 Advanced Hands-On Labs

### Lab 1: Enterprise Role Development
**Objective**: Create a comprehensive web server role
**Duration**: 4 hours

**Scenario**: Develop a production-ready web server role that supports multiple web servers (Nginx, Apache), SSL configuration, and monitoring integration.

**Tasks**:
1. Design role structure with proper defaults and variables
2. Implement multi-OS support (Ubuntu, CentOS, RHEL)
3. Add SSL/TLS configuration with Let's Encrypt integration
4. Include monitoring and logging configuration
5. Write comprehensive tests using Molecule
6. Document the role with examples and usage guidelines

### Lab 2: Multi-Tier Application Deployment
**Objective**: Orchestrate complex application deployment
**Duration**: 6 hours

**Scenario**: Deploy a three-tier web application (load balancer, web servers, database) with zero-downtime deployment capabilities.

**Tasks**:
1. Create playbooks for each tier with proper dependencies
2. Implement rolling updates for web servers
3. Configure database replication and failover
4. Set up load balancer with health checks
5. Implement deployment validation and rollback
6. Add monitoring and alerting integration

### Lab 3: Secrets Management Implementation
**Objective**: Implement comprehensive secrets management
**Duration**: 3 hours

**Scenario**: Secure a multi-environment deployment with proper secrets management using Ansible Vault and external secret stores.

**Tasks**:
1. Set up multiple Vault IDs for different environments
2. Integrate with HashiCorp Vault or AWS Secrets Manager
3. Implement secure CI/CD pipeline integration
4. Create secret rotation procedures
5. Set up audit logging for secret access
6. Test disaster recovery scenarios

### Lab 4: Error Handling and Recovery
**Objective**: Build resilient automation workflows
**Duration**: 3 hours

**Scenario**: Create robust playbooks that handle failures gracefully and implement automatic recovery mechanisms.

**Tasks**:
1. Implement comprehensive error handling strategies
2. Create rollback procedures for failed deployments
3. Set up retry mechanisms with exponential backoff
4. Implement health checks and validation
5. Create notification systems for failures
6. Test failure scenarios and recovery procedures

### Lab 5: Custom Module Development
**Objective**: Develop custom Ansible modules
**Duration**: 5 hours

**Scenario**: Create custom modules for specific business requirements that aren't covered by existing modules.

**Tasks**:
1. Develop a custom module for API integration
2. Create filter plugins for data transformation
3. Implement lookup plugins for external data sources
4. Write comprehensive unit tests
5. Create module documentation
6. Package and distribute the module

### Lab 6: Performance Optimization
**Objective**: Optimize Ansible performance for large-scale deployments
**Duration**: 4 hours

**Scenario**: Optimize playbook execution for managing 100+ servers with minimal execution time.

**Tasks**:
1. Implement parallel execution strategies
2. Optimize fact gathering and caching
3. Use async tasks for long-running operations
4. Implement efficient inventory management
5. Profile and benchmark playbook performance
6. Create performance monitoring dashboards

## 📊 Assessment Methods

### Practical Projects (50%)
- **Role Development**: Create production-ready roles with tests
- **Complex Deployments**: Implement multi-tier application deployments
- **Custom Solutions**: Develop custom modules or plugins

### Scenario-Based Assessments (30%)
- **Problem Solving**: Troubleshoot complex automation issues
- **Architecture Design**: Design automation solutions for given requirements
- **Performance Optimization**: Optimize existing playbooks for scale

### Knowledge Validation (20%)
- **Code Reviews**: Peer review of automation code
- **Best Practices**: Demonstrate understanding of enterprise patterns
- **Security Implementation**: Implement secure automation practices

## 🎯 Success Criteria

### Module Completion Requirements
- [ ] Complete all advanced labs with 85% accuracy
- [ ] Successfully implement at least one custom module
- [ ] Create and test production-ready roles
- [ ] Demonstrate error handling and recovery capabilities
- [ ] Pass peer code reviews with minimal revisions

### Advanced Skill Validation
- [ ] Can design and implement complex automation workflows
- [ ] Can develop reusable, well-tested Ansible roles
- [ ] Can implement comprehensive secrets management
- [ ] Can handle errors and implement recovery mechanisms
- [ ] Can optimize playbooks for performance and scale
- [ ] Can develop custom modules and plugins

## 🚀 Career Applications

### DevOps Engineer Responsibilities
- Design automation frameworks for CI/CD pipelines
- Implement infrastructure as code practices
- Manage configuration drift and compliance
- Optimize deployment processes for speed and reliability

### Platform Engineer Focus Areas
- Build self-service automation platforms
- Implement multi-cloud orchestration
- Design scalable automation architectures
- Create developer productivity tools

### Site Reliability Engineer Tasks
- Automate incident response procedures
- Implement chaos engineering practices
- Build monitoring and alerting automation
- Create disaster recovery automation

## 📈 Advanced Topics Preview

### Preparing for Advanced Level
1. **Ansible Collections**: Understanding collection development
2. **API Integration**: Advanced REST API automation
3. **Cloud Orchestration**: Multi-cloud deployment strategies
4. **Container Orchestration**: Kubernetes and Docker automation
5. **Security Automation**: Compliance and hardening automation

### Recommended Advanced Reading
- "Ansible for Real-Life Automation" by Gineesh Madapparambath
- "Infrastructure as Code" by Kief Morris
- "Site Reliability Engineering" by Google SRE Team
- "The DevOps Handbook" by Gene Kim

## 📚 Additional Resources

### Advanced Documentation
- [Ansible Developer Guide](https://docs.ansible.com/ansible/latest/dev_guide/)
- [Molecule Testing Framework](https://molecule.readthedocs.io/)
- [Ansible Galaxy Developer Guide](https://galaxy.ansible.com/docs/)

### Development Tools
- **Ansible Lint**: Code quality and best practices
- **Molecule**: Role testing framework
- **Ansible Navigator**: Enhanced CLI experience
- **VS Code Extensions**: Ansible language support

### Community Contributions
- [Ansible Community Collections](https://github.com/ansible-collections)
- [Ansible AWX Project](https://github.com/ansible/awx)
- [Ansible Runner](https://github.com/ansible/ansible-runner)

### Professional Development
- **Conferences**: AnsibleFest, DevOps Days, KubeCon
- **Certifications**: Red Hat Certified Engineer (RHCE)
- **Mentorship**: Ansible community mentorship programs
- **Open Source**: Contributing to Ansible projects

---

**Ready to advance your Ansible expertise? This intermediate level will challenge you with real-world scenarios and prepare you for enterprise automation responsibilities. Focus on building robust, scalable, and maintainable automation solutions!**