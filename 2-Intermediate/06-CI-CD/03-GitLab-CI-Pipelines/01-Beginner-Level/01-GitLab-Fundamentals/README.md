# GitLab Fundamentals

## What is GitLab?

GitLab is a complete DevOps platform delivered as a single application that provides:
- Source code management (Git repository hosting)
- Continuous Integration/Continuous Deployment (CI/CD)
- Issue tracking and project management
- Security and compliance tools
- Monitoring and analytics

## GitLab Architecture

### Core Components

1. **GitLab Rails Application**
   - Web interface and API
   - User authentication and authorization
   - Project and repository management

2. **GitLab Workhorse**
   - Handles file uploads and downloads
   - Git HTTP requests
   - WebSocket connections

3. **GitLab Shell**
   - Handles Git SSH operations
   - Repository access control
   - Git hooks management

4. **GitLab Runner**
   - Executes CI/CD jobs
   - Can be installed on separate machines
   - Supports multiple executors (Docker, Shell, Kubernetes)

5. **Database (PostgreSQL)**
   - Stores application data
   - User information, projects, issues, etc.

6. **Redis**
   - Caching and session storage
   - Background job queue
   - Real-time features

## GitLab Editions

### GitLab Community Edition (CE)
- Free and open-source
- Core Git repository management
- Basic CI/CD functionality
- Issue tracking
- Wiki and snippets

### GitLab Enterprise Edition (EE)
- Premium features for enterprises
- Advanced security scanning
- Compliance management
- Advanced user management
- Priority support

## Installation Options

### 1. GitLab.com (SaaS)
```bash
# No installation required
# Simply sign up at https://gitlab.com
```

### 2. Omnibus Package Installation
```bash
# Ubuntu/Debian
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce

# CentOS/RHEL
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install gitlab-ce

# Configure and start
sudo gitlab-ctl reconfigure
```

### 3. Docker Installation
```bash
# Pull GitLab image
docker pull gitlab/gitlab-ce:latest

# Run GitLab container
docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

## Initial Configuration

### 1. Access GitLab
```bash
# Default URL: http://your-server-ip
# First login: root user
# Get initial password:
sudo cat /etc/gitlab/initial_root_password
```

### 2. Basic Configuration File
```ruby
# /etc/gitlab/gitlab.rb

# External URL
external_url 'https://gitlab.example.com'

# Email settings
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "your-email@gmail.com"
gitlab_rails['smtp_password'] = "your-password"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true

# Backup settings
gitlab_rails['backup_keep_time'] = 604800  # 7 days
```

### 3. Apply Configuration
```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
```

## GitLab Interface Navigation

### Main Navigation Areas

1. **Dashboard**
   - Project overview
   - Activity feed
   - Assigned issues and merge requests

2. **Projects**
   - Repository browser
   - File editor
   - Commit history

3. **Groups**
   - Organization structure
   - Shared projects
   - Group-level settings

<b>4. Admin Area</b>
<details>
<summary>Show Answer</summary>
Answer: Admin users only
</details>

   - System settings
   - User management
   - System monitoring

### Project Structure

```
Project Root
├── Repository (Code)
├── Issues
├── Merge Requests
├── CI/CD
│   ├── Pipelines
│   ├── Jobs
│   └── Schedules
├── Security & Compliance
├── Deployments
├── Packages & Registries
├── Analytics
├── Wiki
└── Settings
```

## Key Concepts

### 1. Projects
- Container for repositories and related features
- Can be public, internal, or private
- Includes issues, merge requests, CI/CD, etc.

### 2. Groups
- Collection of projects and users
- Hierarchical organization
- Shared settings and permissions

### 3. Namespaces
- Unique identifier for users and groups
- URL structure: gitlab.com/namespace/project

### 4. Visibility Levels
- **Private**: Only project members can access
- **Internal**: Logged-in users can access
- **Public**: Anyone can access

## Best Practices for Beginners

1. **Start Small**
   - Begin with simple projects
   - Learn one feature at a time
   - Practice with test repositories

2. **Security First**
   - Use strong passwords
   - Enable two-factor authentication
   - Regularly review access permissions

3. **Organization**
   - Use meaningful project names
   - Organize projects in groups
   - Maintain clear documentation

4. **Collaboration**
   - Use descriptive commit messages
   - Create detailed merge requests
   - Utilize issue tracking effectively

## Common GitLab URLs and Endpoints

```bash
# Main GitLab interface
https://gitlab.example.com

# API endpoint
https://gitlab.example.com/api/v4/

# Git clone URLs
https://gitlab.example.com/namespace/project.git
git@gitlab.example.com:namespace/project.git

# Container registry
gitlab.example.com:5050/namespace/project
```

## Troubleshooting Common Issues

### 1. Cannot Access GitLab
```bash
# Check GitLab status
sudo gitlab-ctl status

# Check logs
sudo gitlab-ctl tail

# Restart services
sudo gitlab-ctl restart
```

### 2. Git Operations Fail
```bash
# Check SSH key configuration
ssh -T git@gitlab.example.com

# Verify remote URL
git remote -v

# Update remote URL if needed
git remote set-url origin git@gitlab.example.com:namespace/project.git
```

### 3. Performance Issues
```bash
# Check system resources
sudo gitlab-ctl status
htop

# Optimize GitLab configuration
sudo gitlab-ctl reconfigure
```

## Next Steps

After mastering GitLab fundamentals:
1. Learn repository management and Git workflows
2. Explore basic CI/CD pipeline creation
3. Practice issue tracking and project management
4. Understand user management and permissions

---
*Understanding these fundamentals is crucial for effective GitLab usage.*