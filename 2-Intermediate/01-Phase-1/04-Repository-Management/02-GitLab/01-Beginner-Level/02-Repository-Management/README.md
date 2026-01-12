# Repository Management in GitLab

## Creating Repositories

### 1. Create New Project via Web Interface

1. **Navigate to Projects**
   - Click "New project" button
   - Choose creation method:
     - Create blank project
     - Create from template
     - Import project
     - Run CI/CD for external repository

2. **Project Configuration**
   ```
   Project name: my-awesome-project
   Project slug: my-awesome-project (auto-generated)
   Project description: Brief description of the project
   Visibility Level: Private/Internal/Public
   Initialize repository with README: ✓
   ```

### 2. Create Project via API
```bash
curl --request POST \
  --url "https://gitlab.example.com/api/v4/projects" \
  --header "Private-Token: your-access-token" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "my-project",
    "description": "Project description",
    "visibility": "private",
    "initialize_with_readme": true
  }'
```

## Git Integration and Workflows

### 1. Clone Repository
```bash
# HTTPS clone
git clone https://gitlab.example.com/username/project.git

# SSH clone (recommended)
git clone git@gitlab.example.com:username/project.git

# Navigate to project
cd project
```

### 2. Basic Git Operations
```bash
# Check status
git status

# Add files
git add .
git add specific-file.txt

# Commit changes
git commit -m "Add new feature"

# Push to remote
git push origin main

# Pull latest changes
git pull origin main
```

### 3. Working with Remotes
```bash
# View remotes
git remote -v

# Add remote
git remote add upstream https://gitlab.example.com/original/project.git

# Fetch from remote
git fetch upstream

# Push to specific remote
git push origin feature-branch
```

## Branching Strategies

### 1. Git Flow
```bash
# Main branches
main/master    # Production-ready code
develop        # Integration branch

# Supporting branches
feature/*      # New features
release/*      # Release preparation
hotfix/*       # Critical fixes
```

### 2. GitHub Flow (Simplified)
```bash
# Create feature branch
git checkout -b feature/user-authentication
git push -u origin feature/user-authentication

# Work on feature
git add .
git commit -m "Implement user login"
git push origin feature/user-authentication

# Create merge request when ready
```

### 3. GitLab Flow
```bash
# Environment branches
main           # Production
pre-production # Staging
development    # Development

# Feature development
git checkout -b feature/new-dashboard
# ... work on feature ...
git push origin feature/new-dashboard
# Create merge request to development
```

## Merge Requests and Code Review

### 1. Creating Merge Requests

#### Via Web Interface
1. Navigate to project
2. Click "Merge Requests" → "New merge request"
3. Select source and target branches
4. Fill merge request details:
   ```
   Title: Add user authentication system
   Description: 
   - Implements login/logout functionality
   - Adds password reset feature
   - Includes unit tests
   
   Assignee: @reviewer
   Milestone: v1.2.0
   Labels: feature, authentication
   ```

#### Via Git Push Options
```bash
# Create merge request while pushing
git push -o merge_request.create \
  -o merge_request.target=main \
  -o merge_request.title="Add user authentication" \
  origin feature/user-auth
```

### 2. Merge Request Templates
Create `.gitlab/merge_request_templates/Default.md`:
```markdown
## Description
Brief description of changes

## Changes Made
- [ ] Feature implementation
- [ ] Tests added
- [ ] Documentation updated

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Breaking changes documented
```

### 3. Code Review Process
```bash
# Reviewer workflow
1. Review code changes
2. Add comments and suggestions
3. Approve or request changes
4. Merge when approved

# Author workflow
1. Address review comments
2. Push additional commits
3. Resolve discussions
4. Request re-review
```

## Repository Settings and Permissions

### 1. General Settings
```yaml
Project Settings:
  - Project name and description
  - Project avatar
  - Visibility level
  - Project features (issues, wiki, etc.)
  - Merge request settings
  - Tag protection
```

### 2. Repository Settings
```yaml
Repository:
  - Default branch
  - Push rules
  - Mirror repositories
  - Deploy keys
  - Deploy tokens
  - Webhooks
```

### 3. Branch Protection
```bash
# Protect main branch
Settings → Repository → Protected Branches

Configuration:
- Branch: main
- Allowed to merge: Maintainers
- Allowed to push: No one
- Force push: Disabled
- Code owner approval required: Enabled
```

### 4. Push Rules (EE Feature)
```yaml
Push Rules:
  - Deny deleting a tag
  - Check whether author is a GitLab user
  - GitLab will reject unsigned commits
  - Restrict commits by author (email)
  - Prohibited file names
  - Maximum file size (MB)
```

## File Management

### 1. Web IDE
```bash
# Access Web IDE
Project → Repository → Web IDE

Features:
- File editing
- Terminal access
- Git operations
- Live preview
- Extensions support
```

### 2. File Operations via Web
```bash
# Create new file
Repository → Files → New file

# Upload files
Repository → Files → Upload file

# Edit existing file
Click on file → Edit

# Delete file
Click on file → Delete
```

### 3. Large File Storage (LFS)
```bash
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.psd"
git lfs track "*.zip"

# Add .gitattributes
git add .gitattributes

# Add and commit large files
git add large-file.zip
git commit -m "Add large file"
git push origin main
```

## Repository Templates

### 1. Project Templates
```bash
# Available templates
- Ruby on Rails
- Spring Boot
- Node.js Express
- Python Django
- React
- Vue.js
- Angular
```

### 2. Custom Templates
```yaml
# Create custom template
1. Create template project
2. Add to group/instance templates
3. Configure template settings

Template Structure:
├── .gitlab-ci.yml
├── README.md
├── .gitignore
├── LICENSE
└── src/
    └── main/
```

## Repository Mirroring

### 1. Pull Mirroring
```bash
# Mirror external repository
Settings → Repository → Mirroring repositories

Configuration:
- Git repository URL: https://github.com/user/repo.git
- Mirror direction: Pull
- Authentication method: Password/SSH key
- Update frequency: Every hour
```

### 2. Push Mirroring (EE Feature)
```bash
# Mirror to external repository
Configuration:
- Git repository URL: https://github.com/user/repo.git
- Mirror direction: Push
- Authentication: Deploy key/Password
- Keep divergent refs: Enabled
```

## Repository Analytics

### 1. Repository Analytics
```bash
# Access analytics
Project → Analytics → Repository

Metrics:
- Commits per day/month
- Contributors activity
- Programming languages
- File changes over time
```

### 2. Contribution Analytics
```bash
# View contributions
Project → Repository → Contributors

Information:
- Commit count per contributor
- Lines added/removed
- Contribution timeline
- File modifications
```

## Best Practices

### 1. Repository Organization
```bash
# Clear structure
├── docs/           # Documentation
├── src/            # Source code
├── tests/          # Test files
├── scripts/        # Build/deployment scripts
├── .gitlab-ci.yml  # CI/CD configuration
├── README.md       # Project overview
├── CHANGELOG.md    # Version history
└── LICENSE         # License information
```

### 2. Commit Guidelines
```bash
# Conventional commits
feat: add user authentication system
fix: resolve login redirect issue
docs: update API documentation
style: format code according to style guide
refactor: restructure user service
test: add unit tests for auth module
chore: update dependencies
```

### 3. Branch Naming
```bash
# Consistent naming convention
feature/user-authentication
bugfix/login-redirect-issue
hotfix/security-vulnerability
release/v1.2.0
```

## Troubleshooting

### 1. Common Git Issues
```bash
# Large repository clone
git clone --depth 1 https://gitlab.example.com/user/repo.git

# Reset to remote state
git fetch origin
git reset --hard origin/main

# Resolve merge conflicts
git status
# Edit conflicted files
git add .
git commit -m "Resolve merge conflicts"
```

### 2. Permission Issues
```bash
# Check project access
Project → Members → View permissions

# SSH key issues
ssh -T git@gitlab.example.com

# HTTPS authentication
git config --global credential.helper store
```

## Next Steps

After mastering repository management:
1. Learn basic CI/CD pipeline creation
2. Explore issue tracking and project management
3. Understand advanced Git workflows
4. Practice collaborative development

---
*Effective repository management is fundamental to successful GitLab usage.*