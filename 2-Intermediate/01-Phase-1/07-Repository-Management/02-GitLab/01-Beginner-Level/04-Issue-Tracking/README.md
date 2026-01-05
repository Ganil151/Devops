# Issue Tracking and Project Management

## Introduction to GitLab Issues

GitLab Issues provide a powerful way to track bugs, feature requests, tasks, and other work items within your projects.

### Key Features
- Issue creation and management
- Labels and milestones
- Assignees and due dates
- Issue boards and workflows
- Time tracking
- Issue templates
- Related issues and merge requests

## Creating and Managing Issues

### 1. Basic Issue Creation
```markdown
# Issue Template Example
**Issue Type:** Bug Report / Feature Request / Task

**Description:**
Brief description of the issue or request

**Steps to Reproduce:** (for bugs)
1. Step one
2. Step two
3. Step three

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Environment:**
- OS: Ubuntu 20.04
- Browser: Chrome 95
- GitLab Version: 14.5

**Additional Context:**
Any other relevant information
```

### 2. Issue Configuration
```yaml
# Issue settings
Title: Clear, descriptive title
Description: Detailed explanation with context
Assignee: Team member responsible
Labels: bug, feature, priority::high
Milestone: v1.2.0
Due Date: 2024-01-15
Weight: 3 (complexity estimate)
Epic: Parent epic (EE feature)
```

### 3. Issue Templates
Create `.gitlab/issue_templates/Bug.md`:
```markdown
## Bug Report

**Summary:**
Brief description of the bug

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Result:**
What should happen

**Actual Result:**
What actually happens

**Environment:**
- OS: 
- Browser: 
- Version: 

**Screenshots:**
If applicable, add screenshots

**Additional Notes:**
Any other relevant information

/label ~bug ~needs-investigation
/assign @maintainer
```

## Labels and Organization

### 1. Label Categories
```yaml
# Type labels
~bug          # Bug reports
~feature      # New features
~enhancement  # Improvements
~documentation # Documentation updates
~security     # Security issues

# Priority labels
~priority::critical  # Critical issues
~priority::high     # High priority
~priority::medium   # Medium priority
~priority::low      # Low priority

# Status labels
~status::todo       # Not started
~status::doing      # In progress
~status::review     # Under review
~status::done       # Completed

# Team labels
~team::frontend     # Frontend team
~team::backend      # Backend team
~team::devops       # DevOps team
~team::qa          # QA team
```

### 2. Scoped Labels (EE Feature)
```yaml
# Scoped labels (only one per scope)
priority::high      # Only one priority can be set
status::doing       # Only one status can be set
team::backend       # Only one team can be assigned
```

### 3. Label Management
```bash
# Create labels via API
curl --request POST \
  --header "PRIVATE-TOKEN: your-token" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "priority::high",
    "color": "#FF0000",
    "description": "High priority issues"
  }' \
  "https://gitlab.example.com/api/v4/projects/1/labels"
```

## Milestones and Planning

### 1. Milestone Creation
```yaml
Milestone Configuration:
  Title: "Version 1.2.0"
  Description: "Major feature release with user authentication"
  Start Date: 2024-01-01
  Due Date: 2024-02-15
  
Associated Issues:
  - User login system
  - Password reset functionality
  - User profile management
  - Security improvements
```

### 2. Milestone Planning
```markdown
# Milestone Planning Template

## Milestone: v1.2.0
**Duration:** 6 weeks
**Team Size:** 5 developers

### Goals
- Implement user authentication
- Improve application security
- Enhance user experience

### Deliverables
- [ ] User registration system
- [ ] Login/logout functionality
- [ ] Password reset feature
- [ ] User profile management
- [ ] Security audit

### Success Criteria
- All authentication tests pass
- Security scan shows no critical issues
- User acceptance testing completed
- Documentation updated
```

## Issue Boards and Workflows

### 1. Basic Issue Board Setup
```yaml
Board Configuration:
  Name: "Development Workflow"
  
Lists:
  - Open (default)
  - To Do (~status::todo)
  - In Progress (~status::doing)
  - Review (~status::review)
  - Done (Closed issues)

Workflow:
  Open → To Do → In Progress → Review → Done
```

### 2. Advanced Board Configuration
```yaml
# Multiple boards for different workflows
Development Board:
  - Backlog (~status::backlog)
  - Ready (~status::ready)
  - In Progress (~status::doing)
  - Code Review (~status::review)
  - Testing (~status::testing)
  - Done (Closed)

Bug Triage Board:
  - New Bugs (~bug ~status::new)
  - Investigating (~bug ~status::investigating)
  - Confirmed (~bug ~status::confirmed)
  - In Progress (~bug ~status::fixing)
  - Fixed (~bug ~status::fixed)
```

### 3. Swimlanes (EE Feature)
```yaml
Swimlane Configuration:
  - Epic: User Authentication Epic
  - Epic: Performance Improvements Epic
  - Epic: UI/UX Enhancements Epic
  
Benefits:
  - Visual organization by epic
  - Better progress tracking
  - Clearer team focus
```

## Time Tracking

### 1. Time Tracking Commands
```markdown
# In issue or merge request comments
/estimate 2h 30m    # Set time estimate
/spend 1h 15m       # Log time spent
/remove_estimate    # Remove estimate
/remove_time_spent  # Remove logged time

# Time tracking in descriptions
Time estimate: 4 hours
Time spent: 2 hours 30 minutes
Remaining: 1 hour 30 minutes
```

### 2. Time Tracking Reports
```bash
# Get time tracking data via API
curl --header "PRIVATE-TOKEN: your-token" \
  "https://gitlab.example.com/api/v4/projects/1/issues/1/time_stats"

# Response example
{
  "time_estimate": 14400,  # 4 hours in seconds
  "total_time_spent": 9000, # 2.5 hours in seconds
  "human_time_estimate": "4h",
  "human_total_time_spent": "2h 30m"
}
```

## Issue Relationships

### 1. Related Issues
```markdown
# Link related issues
Related to #123
Closes #456
Blocks #789
Blocked by #101

# In issue descriptions or comments
This issue is related to #123 and #456
Implementing this will close #789
```

### 2. Issue Dependencies
```markdown
# Dependency management
Depends on:
- #123 Database schema update
- #456 API endpoint creation

Blocks:
- #789 Frontend implementation
- #101 Integration testing
```

## Advanced Issue Features

### 1. Issue Templates
Create `.gitlab/issue_templates/Feature.md`:
```markdown
## Feature Request

**Feature Description:**
Clear description of the requested feature

**Use Case:**
Who will use this feature and why?

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Design Considerations:**
Any design or technical considerations

**Additional Context:**
Screenshots, mockups, or references

/label ~feature ~needs-discussion
/milestone %"Next Release"
```

### 2. Quick Actions
```markdown
# Available quick actions in issues
/assign @username           # Assign to user
/unassign @username        # Unassign user
/milestone %milestone      # Set milestone
/remove_milestone          # Remove milestone
/label ~label             # Add label
/unlabel ~label           # Remove label
/close                    # Close issue
/reopen                   # Reopen issue
/duplicate #issue         # Mark as duplicate
/move project_path        # Move to another project
/confidential             # Make confidential
/lock                     # Lock discussion
/unlock                   # Unlock discussion
```

### 3. Issue Analytics
```bash
# Issue metrics and analytics
Issues Created: 150 this month
Issues Closed: 120 this month
Average Resolution Time: 3.2 days
Open Issues: 45
Overdue Issues: 8

# Burndown charts (EE feature)
- Sprint progress tracking
- Milestone completion rates
- Team velocity metrics
```

## Integration with Development Workflow

### 1. Issue-Branch Workflow
```bash
# Create branch from issue
git checkout -b feature/123-user-authentication

# Commit messages linking to issues
git commit -m "Implement login form

Addresses #123"

# Merge request linking
Title: "Resolve #123: Implement user authentication"
Description: "Closes #123"
```

### 2. Automated Issue Management
```yaml
# .gitlab-ci.yml - Automated issue updates
update-issues:
  stage: deploy
  script:
    - |
      # Close issues mentioned in commit messages
      git log --pretty=format:"%s" $CI_COMMIT_BEFORE_SHA..$CI_COMMIT_SHA | \
      grep -o "Closes #[0-9]*" | \
      while read line; do
        ISSUE_ID=$(echo $line | grep -o "[0-9]*")
        curl --request PUT \
          --header "PRIVATE-TOKEN: $API_TOKEN" \
          --data "state_event=close" \
          "$CI_API_V4_URL/projects/$CI_PROJECT_ID/issues/$ISSUE_ID"
      done
  only:
    - main
```

## Best Practices

### 1. Issue Writing Guidelines
```markdown
# Good issue title examples
✅ "Login button not working on mobile Safari"
✅ "Add user profile picture upload feature"
✅ "Database migration fails on PostgreSQL 13"

# Poor issue title examples
❌ "Bug"
❌ "Feature request"
❌ "Something is broken"

# Issue description best practices
- Use clear, descriptive language
- Include steps to reproduce (for bugs)
- Add screenshots or mockups when helpful
- Specify acceptance criteria
- Link to related issues or documentation
```

### 2. Label Strategy
```yaml
# Consistent labeling strategy
Type Labels: (required)
  - ~bug, ~feature, ~enhancement, ~documentation

Priority Labels: (required for bugs)
  - ~priority::critical, ~priority::high, ~priority::medium, ~priority::low

Status Labels: (workflow tracking)
  - ~status::todo, ~status::doing, ~status::review, ~status::done

Team Labels: (assignment)
  - ~team::frontend, ~team::backend, ~team::devops, ~team::qa
```

### 3. Workflow Optimization
```markdown
# Efficient issue workflow
1. Triage new issues daily
2. Assign appropriate labels and milestones
3. Break down large issues into smaller tasks
4. Use issue boards for visual management
5. Regular milestone reviews and planning
6. Close completed issues promptly
7. Document lessons learned
```

## Automation and Integration

### 1. Issue Automation Scripts
```python
#!/usr/bin/env python3
import requests
import json

class GitLabIssueManager:
    def __init__(self, gitlab_url, token):
        self.gitlab_url = gitlab_url
        self.headers = {'PRIVATE-TOKEN': token}
    
    def auto_triage_issues(self, project_id):
        """Automatically triage new issues"""
        # Get new issues
        response = requests.get(
            f"{self.gitlab_url}/api/v4/projects/{project_id}/issues",
            headers=self.headers,
            params={'state': 'opened', 'labels': 'needs-triage'}
        )
        
        for issue in response.json():
            # Auto-assign based on keywords
            if 'frontend' in issue['title'].lower():
                self.add_label(project_id, issue['iid'], 'team::frontend')
            elif 'backend' in issue['title'].lower():
                self.add_label(project_id, issue['iid'], 'team::backend')
            
            # Remove triage label
            self.remove_label(project_id, issue['iid'], 'needs-triage')
    
    def add_label(self, project_id, issue_iid, label):
        """Add label to issue"""
        requests.put(
            f"{self.gitlab_url}/api/v4/projects/{project_id}/issues/{issue_iid}",
            headers=self.headers,
            json={'add_labels': label}
        )
```

### 2. Webhook Integration
```python
# Flask webhook handler for issue events
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/webhook/issues', methods=['POST'])
def handle_issue_webhook():
    data = request.json
    
    if data['object_kind'] == 'issue':
        issue = data['object_attributes']
        
        # Auto-assign based on labels
        if 'bug' in [label['title'] for label in issue.get('labels', [])]:
            # Notify bug triage team
            notify_team('bug-triage', issue)
        
        # Update external systems
        update_jira_ticket(issue)
        
    return jsonify({'status': 'processed'})

def notify_team(team, issue):
    """Send notification to team"""
    # Slack, email, or other notification
    pass

def update_jira_ticket(issue):
    """Sync with external issue tracker"""
    # JIRA API integration
    pass
```

## Troubleshooting Common Issues

### 1. Performance Issues
```bash
# Large number of issues causing slowdown
# Optimize with proper indexing and filtering

# Close old, inactive issues
gitlab-rails runner "
  Issue.where('updated_at < ?', 6.months.ago)
       .where(state: 'opened')
       .find_each { |issue| issue.close! }
"

# Archive completed milestones
gitlab-rails runner "
  Milestone.where('due_date < ?', 3.months.ago)
           .where(state: 'closed')
           .find_each { |milestone| milestone.update(state: 'archived') }
"
```

### 2. Permission Issues
```bash
# Check issue permissions
# Project → Settings → General → Visibility, project features, permissions

# Issue visibility levels:
- Private: Only project members
- Internal: All logged-in users  
- Public: Everyone

# Feature permissions:
- Disabled: Feature not available
- Only project members: Members only
- Everyone with access: Based on project visibility
```

## Next Steps

After mastering issue tracking:
1. Learn user management and permissions
2. Explore basic security features
3. Practice with real project scenarios
4. Study advanced project management features

---
*Effective issue tracking is essential for organized project management and team collaboration.*