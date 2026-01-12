# 📋 Repository Management - Interview Questions & Comprehensive Quiz

This comprehensive assessment covers all repository technologies and enterprise scenarios. Designed for DevOps Engineers with 20+ years of experience expectations.

---

## 🎯 Quiz Structure

- **Total Questions**: 50
- **Passing Score**: 85% (43/50)
- **Time Limit**: 90 minutes
- **Question Types**: Multiple choice, scenario-based, troubleshooting

---

## 📚 Section 1: Git & GitHub Fundamentals (10 Questions)

### Q1. What is the main difference between `git reset --hard` and `git revert`?
- A) `reset --hard` is safer for shared repositories
- B) `revert` creates a new commit to undo changes, `reset --hard` moves HEAD pointer
- C) They perform identical operations
- D) `reset --hard` only works on local repositories

**Answer: B**
**Explanation**: `git revert` creates a new commit that undoes previous changes, preserving history. `git reset --hard` moves the HEAD pointer and can rewrite history, making it dangerous for shared repositories.

### Q2. In a GitHub Actions workflow, which event trigger would you use for pull request validation?
- A) `on: push`
- B) `on: pull_request`
- C) `on: workflow_dispatch`
- D) `on: schedule`

**Answer: B**
**Explanation**: `on: pull_request` triggers the workflow when pull requests are opened, synchronized, or reopened, making it ideal for validation.

### Q3. What is the purpose of Git's staging area (index)?
- A) Store committed changes
- B) Prepare exactly what will go into the next commit
- C) Resolve merge conflicts
- D) Store remote repository information

**Answer: B**
**Explanation**: The staging area allows developers to selectively choose which changes to include in the next commit, providing fine-grained control over commit content.

### Q4. Which Git command shows the commit history in a graphical format?
- A) `git log --oneline`
- B) `git log --graph`
- C) `git show --graph`
- D) `git branch --graph`

**Answer: B**
**Explanation**: `git log --graph` displays the commit history with ASCII art showing branch and merge relationships.

### Q5. What is the recommended approach for handling secrets in GitHub repositories?
- A) Store them in environment variables in the code
- B) Use GitHub Secrets and reference them in workflows
- C) Commit them encrypted to the repository
- D) Store them in configuration files

**Answer: B**
**Explanation**: GitHub Secrets provide a secure way to store sensitive information that can be accessed in workflows without exposing them in code.

### Q6. Which branching strategy is best suited for continuous deployment?
- A) Git Flow
- B) GitHub Flow
- C) GitLab Flow
- D) Feature branching

**Answer: B**
**Explanation**: GitHub Flow's simple main-branch-focused approach with feature branches is ideal for continuous deployment scenarios.

### Q7. What does `git stash` do?
- A) Permanently saves changes to a branch
- B) Temporarily saves uncommitted changes
- C) Creates a new branch
- D) Merges changes from another branch

**Answer: B**
**Explanation**: `git stash` temporarily saves uncommitted changes, allowing you to switch contexts and return to them later.

### Q8. In GitHub, what is the purpose of branch protection rules?
- A) Prevent unauthorized repository access
- B) Enforce code quality and review requirements
- C) Automatically merge pull requests
- D) Create backup copies of branches

**Answer: B**
**Explanation**: Branch protection rules enforce policies like required reviews, status checks, and restrictions on who can push to protected branches.

### Q9. Which command would you use to see the differences between two commits?
- A) `git diff commit1 commit2`
- B) `git compare commit1 commit2`
- C) `git show commit1..commit2`
- D) `git log commit1..commit2`

**Answer: A**
**Explanation**: `git diff commit1 commit2` shows the differences between two specific commits.

### Q10. What is the purpose of `.gitignore` files?
- A) Ignore merge conflicts
- B) Specify files that Git should not track
- C) Configure Git settings
- D) Store commit messages

**Answer: B**
**Explanation**: `.gitignore` files specify which files and directories Git should not track or include in commits.

---

## 🦊 Section 2: GitLab Enterprise (8 Questions)

### Q11. What is the main advantage of GitLab's integrated DevOps platform?
- A) Lower cost than competitors
- B) Single application for entire DevOps lifecycle
- C) Better Git performance
- D) More storage space

**Answer: B**
**Explanation**: GitLab provides source code management, CI/CD, security scanning, monitoring, and more in a single integrated platform.

### Q12. In GitLab CI/CD, what file defines the pipeline configuration?
- A) `.gitlab-ci.yml`
- B) `pipeline.yml`
- C) `.ci-config.yml`
- D) `gitlab-pipeline.yml`

**Answer: A**
**Explanation**: `.gitlab-ci.yml` is the standard file that defines GitLab CI/CD pipeline configuration.

### Q13. Which GitLab feature allows you to manage container images?
- A) GitLab Pages
- B) GitLab Registry
- C) GitLab Packages
- D) GitLab Deploy Keys

**Answer: B**
**Explanation**: GitLab Registry (Container Registry) allows you to store and manage Docker container images.

### Q14. What is the difference between GitLab.com and GitLab Self-Managed?
- A) GitLab.com is free, Self-Managed is paid
- B) GitLab.com is cloud-hosted, Self-Managed is on-premises
- C) GitLab.com uses Git, Self-Managed uses SVN
- D) No significant differences

**Answer: B**
**Explanation**: GitLab.com is the SaaS offering hosted by GitLab, while Self-Managed allows organizations to host GitLab on their own infrastructure.

### Q15. In GitLab, what are merge request approvals used for?
- A) Automatically merge code
- B) Require specific people to review code before merging
- C) Create backup copies
- D) Generate documentation

**Answer: B**
**Explanation**: Merge request approvals ensure that designated reviewers must approve changes before they can be merged.

### Q16. Which GitLab tier includes advanced security scanning features?
- A) Free
- B) Premium
- C) Ultimate
- D) All tiers

**Answer: C**
**Explanation**: GitLab Ultimate includes advanced security features like SAST, DAST, dependency scanning, and container scanning.

### Q17. What is GitLab Runner?
- A) A Git client application
- B) An application that processes CI/CD jobs
- C) A database management tool
- D) A code editor plugin

**Answer: B**
**Explanation**: GitLab Runner is an application that processes CI/CD jobs defined in GitLab pipelines.

### Q18. How does GitLab handle issue tracking integration?
- A) Through external tools only
- B) Built-in issue tracking with Git integration
- C) No issue tracking capabilities
- D) Only through Jira integration

**Answer: B**
**Explanation**: GitLab has built-in issue tracking that integrates seamlessly with Git commits and merge requests.

---

## 🪣 Section 3: Bitbucket & Atlassian Ecosystem (8 Questions)

### Q19. What is Bitbucket's main integration advantage?
- A) Better Git performance
- B) Seamless integration with Atlassian tools (Jira, Confluence)
- C) Lower cost
- D) More storage space

**Answer: B**
**Explanation**: Bitbucket's tight integration with Jira, Confluence, and other Atlassian tools is its primary competitive advantage.

### Q20. Which file configures Bitbucket Pipelines?
- A) `.bitbucket-ci.yml`
- B) `bitbucket-pipelines.yml`
- C) `pipeline.yml`
- D) `.pipeline.yml`

**Answer: B**
**Explanation**: `bitbucket-pipelines.yml` is the configuration file for Bitbucket Pipelines CI/CD.

### Q21. What are smart commits in Bitbucket?
- A) Automatically generated commit messages
- B) Commits that automatically transition Jira issues
- C) Commits with AI-generated code
- D) Commits that fix bugs automatically

**Answer: B**
**Explanation**: Smart commits allow developers to transition Jira issues, add comments, and log time through commit messages.

### Q22. What is the maximum number of free users in Bitbucket Cloud?
- A) 3 users
- B) 5 users
- C) 10 users
- D) Unlimited

**Answer: B**
**Explanation**: Bitbucket Cloud offers free accounts for teams up to 5 users.

### Q23. Which Bitbucket feature enforces code quality requirements?
- A) Smart commits
- B) Branch permissions
- C) Repository hooks
- D) All of the above

**Answer: D**
**Explanation**: All these features can be used to enforce code quality: branch permissions restrict access, hooks can run quality checks, and smart commits can integrate with issue tracking.

### Q24. What is Bitbucket Data Center?
- A) A cloud storage service
- B) High-availability, clustered Bitbucket deployment
- C) A data backup solution
- D) A database management tool

**Answer: B**
**Explanation**: Bitbucket Data Center provides high-availability, clustered deployments for enterprise environments.

### Q25. How does Bitbucket handle large file storage?
- A) Built-in large file support
- B) Git LFS integration
- C) External storage only
- D) No large file support

**Answer: B**
**Explanation**: Bitbucket supports Git LFS (Large File Storage) for handling large binary files efficiently.

### Q26. What is the primary difference between Bitbucket Cloud and Server?
- A) Cloud uses Git, Server uses Mercurial
- B) Cloud is hosted by Atlassian, Server is self-hosted
- C) Cloud is free, Server is paid
- D) No significant differences

**Answer: B**
**Explanation**: Bitbucket Cloud is Atlassian's hosted service, while Bitbucket Server is deployed on-premises by organizations.

---

## 🔷 Section 4: Azure DevOps Repos (8 Questions)

### Q27. What is the main advantage of Azure DevOps Repos in enterprise environments?
- A) Lower cost than competitors
- B) Integration with Microsoft ecosystem and Active Directory
- C) Better Git performance
- D) More storage space

**Answer: B**
**Explanation**: Azure DevOps Repos integrates seamlessly with Microsoft's enterprise ecosystem, including Active Directory, Azure services, and Office 365.

### Q28. Which authentication method is recommended for enterprise Azure DevOps deployments?
- A) Basic authentication
- B) Personal Access Tokens (PAT)
- C) Azure Active Directory integration
- D) SSH keys only

**Answer: C**
**Explanation**: Azure Active Directory integration provides enterprise-grade authentication with SSO and conditional access policies.

### Q29. What is the difference between Azure DevOps Services and Azure DevOps Server?
- A) Services uses Git, Server uses TFVC
- B) Services is cloud-hosted, Server is on-premises
- C) Services is free, Server requires licenses
- D) No significant differences

**Answer: B**
**Explanation**: Azure DevOps Services is Microsoft's cloud offering, while Azure DevOps Server (formerly TFS) is the on-premises version.

### Q30. Which Azure DevOps component handles work item tracking?
- A) Azure Repos
- B) Azure Boards
- C) Azure Pipelines
- D) Azure Artifacts

**Answer: B**
**Explanation**: Azure Boards provides work item tracking, including user stories, bugs, tasks, and features.

### Q31. What is the maximum file size supported in Azure Repos?
- A) 100 MB
- B) 250 MB
- C) 5 GB
- D) No limit

**Answer: B**
**Explanation**: Azure Repos supports files up to 250 MB in size.

### Q32. How does Azure DevOps handle package management?
- A) Through external tools only
- B) Azure Artifacts for package feeds
- C) No package management
- D) Only NuGet packages

**Answer: B**
**Explanation**: Azure Artifacts provides package management for NuGet, npm, Maven, Python, and Universal packages.

### Q33. What is the purpose of branch policies in Azure Repos?
- A) Create automatic backups
- B) Enforce code quality and review requirements
- C) Manage repository permissions
- D) Configure build triggers

**Answer: B**
**Explanation**: Branch policies enforce requirements like pull request reviews, build validation, and work item linking.

### Q34. Which tool is used for migrating from TFS to Azure DevOps Services?
- A) Azure DevOps Migration Tool
- B) TFS Migration Tool
- C) Git Migration Tool
- D) Azure Migrate

**Answer: A**
**Explanation**: The Azure DevOps Migration Tool helps migrate team projects from TFS to Azure DevOps Services.

---

## 🐍 Section 5: Mercurial & SVN Legacy Systems (8 Questions)

### Q35. What is the main architectural difference between Mercurial and Git?
- A) Mercurial is centralized, Git is distributed
- B) Mercurial uses revision numbers, Git uses SHA hashes
- C) Mercurial stores complete snapshots, Git stores deltas
- D) Both B and C are correct

**Answer: D**
**Explanation**: Mercurial uses sequential revision numbers and stores complete snapshots, while Git uses SHA hashes and stores deltas between commits.

### Q36. Which command creates a branch in Mercurial?
- A) `hg branch feature-name`
- B) `hg checkout -b feature-name`
- C) `hg create-branch feature-name`
- D) `hg new-branch feature-name`

**Answer: A**
**Explanation**: `hg branch feature-name` creates a new named branch in Mercurial.

### Q37. What is the main difference between SVN and distributed version control systems?
- A) SVN is faster
- B) SVN requires constant server connection for most operations
- C) SVN has better branching
- D) SVN is more secure

**Answer: B**
**Explanation**: SVN is centralized, requiring server connectivity for most operations, while distributed systems allow full offline work.

### Q38. Which SVN command creates a branch?
- A) `svn branch`
- B) `svn copy trunk branches/feature-name`
- C) `svn checkout -b`
- D) `svn create-branch`

**Answer: B**
**Explanation**: SVN uses `svn copy` to create branches by copying from trunk to the branches directory.

### Q39. What is the purpose of SVN revision numbers?
- A) Identify individual files
- B) Global repository state identifiers
- C) User identifiers
- D) Branch identifiers

**Answer: B**
**Explanation**: SVN revision numbers represent the global state of the entire repository at a specific point in time.

### Q40. Which version control system is best for handling large binary files?
- A) Git
- B) Mercurial
- C) SVN
- D) All are equal

**Answer: C**
**Explanation**: SVN handles large binary files more efficiently than distributed systems like Git and Mercurial.

### Q41. What is the Mercurial equivalent of Git's `git stash`?
- A) `hg stash`
- B) `hg shelve`
- C) `hg save`
- D) `hg backup`

**Answer: B**
**Explanation**: `hg shelve` in Mercurial provides similar functionality to `git stash` for temporarily saving uncommitted changes.

### Q42. In SVN, what is the purpose of hook scripts?
- A) Automate repository backups
- B) Enforce policies and trigger actions on repository events
- C) Improve performance
- D) Manage user authentication

**Answer: B**
**Explanation**: SVN hook scripts allow administrators to enforce policies and trigger automated actions on repository events like commits.

---

## 🏢 Section 6: Enterprise Scenarios & Troubleshooting (8 Questions)

### Q43. **Scenario**: Your organization has 500 developers across 20 time zones using Git. Developers complain about slow clone times for a 10GB repository. What's the best solution?
- A) Switch to SVN
- B) Implement Git LFS and partial clones
- C) Use multiple smaller repositories
- D) Increase server bandwidth

**Answer: B**
**Explanation**: Git LFS handles large files efficiently, and partial clones allow developers to work with subsets of the repository, reducing clone times.

### Q44. **Scenario**: A financial services company needs to implement strict audit trails for all code changes. Which approach is most comprehensive?
- A) Use Git with signed commits only
- B) Implement comprehensive logging across all repository platforms with immutable audit logs
- C) Use SVN with hook scripts
- D) Rely on GitHub's built-in audit logs

**Answer: B**
**Explanation**: Comprehensive audit trails require logging at multiple levels with immutable storage to meet financial services compliance requirements.

### Q45. **Scenario**: Your team needs to migrate a 15-year-old SVN repository with 50,000 commits to Git while preserving all history and branches. What's the best approach?
- A) Use `git svn clone` with full history
- B) Export recent commits only
- C) Use specialized migration tools like svn2git with author mapping
- D) Start fresh with Git

**Answer: C**
**Explanation**: Specialized migration tools like svn2git provide better handling of SVN-specific features and proper author mapping for enterprise migrations.

### Q46. **Scenario**: A development team reports that their Git repository has become corrupted after a failed merge. What's the first troubleshooting step?
- A) Delete and re-clone the repository
- B) Run `git fsck` to check repository integrity
- C) Force push from a backup
- D) Switch to a different VCS

**Answer: B**
**Explanation**: `git fsck` (file system check) is the first step to diagnose repository corruption and identify specific issues.

### Q47. **Scenario**: Your organization uses multiple repository platforms (GitHub, GitLab, Bitbucket). How would you implement consistent security policies across all platforms?
- A) Use each platform's native security features independently
- B) Implement a centralized policy management system with API integration
- C) Standardize on a single platform
- D) Use external security scanning tools only

**Answer: B**
**Explanation**: A centralized policy management system using APIs can enforce consistent security policies across multiple repository platforms.

### Q48. **Scenario**: A large enterprise needs to implement disaster recovery for their critical repositories. What's the most comprehensive approach?
- A) Daily backups to cloud storage
- B) Multi-region repository replication with automated failover
- C) Weekly exports to external media
- D) Rely on the hosting provider's backups

**Answer: B**
**Explanation**: Multi-region replication with automated failover provides the highest availability and fastest recovery for critical enterprise repositories.

### Q49. **Scenario**: Your team is experiencing frequent merge conflicts in a large codebase. What's the most effective long-term solution?
- A) Use feature flags and trunk-based development
- B) Create more branches
- C) Implement stricter code review processes
- D) Switch to a centralized VCS

**Answer: A**
**Explanation**: Feature flags with trunk-based development reduces the likelihood of conflicts by keeping changes small and integrated frequently.

### Q50. **Scenario**: A government agency requires air-gapped development environments with periodic synchronization to external repositories. What's the best architecture?
- A) Use VPN connections for real-time sync
- B) Implement bundle-based synchronization with security scanning
- C) Use removable media for transfers
- D) Maintain completely separate repositories

**Answer: B**
**Explanation**: Bundle-based synchronization allows secure, controlled transfer of repository data between air-gapped and external environments with security validation.

---

## 🎯 Answer Key Summary

| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|----|--------|
| 1  | B      | 11 | B      | 21 | B      | 31 | B      | 41 | B      |
| 2  | B      | 12 | A      | 22 | B      | 32 | B      | 42 | B      |
| 3  | B      | 13 | B      | 23 | D      | 33 | B      | 43 | B      |
| 4  | B      | 14 | B      | 24 | B      | 34 | A      | 44 | B      |
| 5  | B      | 15 | B      | 25 | B      | 35 | D      | 45 | C      |
| 6  | B      | 16 | C      | 26 | B      | 36 | A      | 46 | B      |
| 7  | B      | 17 | B      | 27 | B      | 37 | B      | 47 | B      |
| 8  | B      | 18 | B      | 28 | C      | 38 | B      | 48 | B      |
| 9  | A      | 19 | B      | 29 | B      | 39 | B      | 49 | A      |
| 10 | B      | 20 | B      | 30 | B      | 40 | C      | 50 | B      |

---

## 📊 Scoring Guide

- **45-50 correct (90-100%)**: Expert Level - Ready for senior repository architecture roles
- **43-44 correct (86-88%)**: Advanced Level - Strong repository management skills
- **40-42 correct (80-84%)**: Intermediate Level - Good foundation, some areas need improvement
- **35-39 correct (70-78%)**: Beginner Level - Requires additional study and practice
- **Below 35 (< 70%)**: Foundational gaps - Recommend reviewing all modules

---

## 🎓 Certification Alignment

This quiz prepares you for:
- **GitHub Foundations Certification**
- **GitLab Certified Associate**
- **Atlassian Certified Professional**
- **Microsoft Azure DevOps Engineer Expert (AZ-400)**

---

**"Repository mastery isn't just about knowing commands - it's about architecting collaborative development at enterprise scale."**

*Complete this assessment to validate your repository management expertise across all major platforms.*