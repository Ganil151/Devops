# 🚀 The "Portfolio Project Evaluator" Prompt

## Overview
This prompt helps you identify which side projects to build, how to showcase them effectively, and how to structure your GitHub profile to maximize recruiter attention.

---

## 📋 The Prompt

Copy and paste the text below into your AI assistant:

```
Role: Act as a Senior Engineering Hiring Manager who reviews hundreds of GitHub profiles and portfolio projects when evaluating DevOps candidates. You know which projects demonstrate real skill vs. "tutorial hell" projects.

Task:

1. Project Idea Validation:
   I'm considering building the following project: [DESCRIBE PROJECT IDEA]
   
   My current experience level: [Junior/Mid/Senior]
   Target role: [e.g., "DevOps Engineer at a startup"]
   Time commitment: [e.g., "10 hours/week for 4 weeks"]
   
   Evaluate this project on:
   - **Relevance**: Does it showcase skills hiring managers actually care about? (1-10)
   - **Differentiation**: Is this unique, or the 1000th "deploy app to Kubernetes" tutorial? (1-10)
   - **Complexity**: Right level of challenge for my experience? (Too easy / Just right / Too hard)
   - **Storytelling Potential**: Can I write a compelling blog post about learnings? (Yes/No + ideas)
   
   Then provide:
   - Go/No-Go recommendation
   - If "Go": Suggest 3 enhancements to make it stand out
   - If "No-Go": Suggest 2 alternative project ideas

2. GitHub Profile Audit:
   Analyze my GitHub profile: [PASTE GITHUB URL OR DESCRIBE CURRENT STATE]
   
   Evaluate:
   - Pinned repositories: Are these your best work or random projects?
   - README quality: Does each repo have a clear README with architecture diagrams?
   - Commit history: Consistent activity or abandoned projects?
   - Documentation: Do READMEs explain the "why" not just the "what"?
   - Showcasing: Any demos, screenshots, or architecture diagrams?
   
   Provide:
   - Overall "Recruiter First Impression" score (1-10)
   - Top 3 improvements to make this week
   - Which projects to unpin/archive

3. Project README Template:
   For my project: [PROJECT NAME/DESCRIPTION]
   
   Generate a professional README structure with:
   - Hook: One-sentence problem statement
   - Architecture diagram placeholder (describe what should be shown)
   - Tech stack with justification ("I chose X over Y because...")
   - Key features with metrics (e.g., "Deploys 10x faster than previous approach")
   - Setup instructions (for recruiters to quickly test it)
   - Challenges & learnings (shows growth mindset)
   - Future enhancements (shows you think about scale)

4. Portfolio Project Roadmap:
   Based on my target role and current skills, suggest a 6-month portfolio roadmap:
   
   Month 1-2: [Foundation project - e.g., "Infrastructure as Code module library"]
   Month 3-4: [Intermediate project - e.g., "CI/CD pipeline with GitOps"]
   Month 5-6: [Advanced project - e.g., "Multi-cloud disaster recovery automation"]
   
   For each project, specify:
   - Core technologies to use
   - What real-world problem it solves
   - How to document it for max impact
   - Where to share it (blog, Twitter, LinkedIn)

Input Data:
Current skills: [e.g., "Terraform, AWS, Docker, basic Kubernetes"]
Target role: [e.g., "Senior DevOps Engineer"]
Time available: [e.g., "10 hrs/week"]
```

---

## 🎓 Why Portfolio Projects Matter

### The Hard Truth
- **60% of hiring managers** check your GitHub before the first interview
- **Projects > Certifications** for mid-level+ roles (certifications prove knowledge, projects prove execution)
- **Blog posts about your projects** get 3x more recruiter engagement than just code

### What Hiring Managers Look For

| ❌ Red Flag | ✅ Green Flag |
|-------------|---------------|
| Forked tutorials with no modifications | Original infrastructure project solving a real problem |
| No README or "TODO: Add README" | Detailed README with architecture diagrams |
| Last commit: 2 years ago | Consistent commits in last 3 months |
| All projects are "Hello World" | Mix of learning projects + production-grade work |
| No code comments or docs | Well-commented code + ADRs (Architecture Decision Records) |

---

## 📊 Expected Output

### Example: Project Idea Validation

**Input:**
> "I want to build a Terraform module library for deploying a full observability stack (Prometheus, Grafana, Loki, Tempo) to Kubernetes across AWS, Azure, and GCP."

**AI Output:**
```
Project Evaluation:

✅ Relevance: 9/10
- Observability is critical for DevOps roles
- Multi-cloud is highly valued (shows vendor-agnostic thinking)
- Terraform + Kubernetes = top 2 most-requested skills

✅ Differentiation: 8/10
- Most tutorials only cover single-cloud Prometheus setup
- Including Tempo (distributed tracing) is advanced
- Module library approach shows reusability mindset

✅ Complexity: Just Right (for Mid-Senior Engineer)
- Requires understanding Terraform modules, K8s operators, cloud-specific quirks
- Scoped enough to finish in 4-6 weeks

✅ Storytelling Potential: YES
Blog post ideas:
1. "Building a Portable Observability Stack: Lessons from Multi-Cloud"
2. "Why I chose Loki over ELK for log aggregation"
3. "Terraform Module Design Patterns for 10x Reusability"

RECOMMENDATION: ✅ GO

Enhancements to Stand Out:
1. Add cost-optimization guide (e.g., "This setup costs $X/month on AWS vs $Y on GCP")
2. Include performance benchmarks (query latency, retention configs)
3. Create video walkthrough (5 min demo on YouTube)

Next Steps:
- Create repo blueprint
- Set up CI/CD with GitHub Actions to validate modules
- Write blog post outline BEFORE coding (helps clarify thinking)
```

---

### Example: GitHub README Template

**Input:** "Project: Multi-region AWS infrastructure with automated failover using Terraform and Route 53"

**AI Output (README structure):**

```markdown
# Multi-Region AWS Infrastructure with Automated Failover

> Production-grade Infrastructure as Code for high-availability applications requiring < 1 minute failover time

## The Problem
Most SaaS applications lose revenue during regional AWS outages. In 2023, the average cost of downtime was $5,600/minute for mid-sized companies. This project automates failover across US-EAST-1 and US-WEST-2 to achieve 99.99% uptime.

## Architecture
![Architecture Diagram](docs/architecture.png)

**Core Components:**
- **Terraform** - Infrastructure as Code
- **Route 53** - Health checks + automated DNS failover
- **EC2 + ALB** - Application layer (us-east-1 primary, us-west-2 standby)
- **RDS Multi-AZ + Read Replica** - Database layer with cross-region replication
- **CloudWatch + Lambda** - Automated failover triggering

## Why This Stack?

| Decision | Rationale |
|----------|-----------|
| Route 53 over third-party DNS | Native AWS integration, 100% uptime SLA |
| Terraform over CloudFormation | Multi-cloud portability, better module ecosystem |
| Active-Passive over Active-Active | 60% cost savings, acceptable 45-second RTO |

## Key Features
- ⚡ **Sub-60 second failover** (tested with chaos engineering)
- 💰 **40% cheaper than active-active** (standby uses smaller instances)
- 🔒 **Zero data loss** (RPO = 0 via synchronous replication)
- 📊 **Automated health checks** (every 30 seconds with Route 53)

## Quick Start
bash
# 1. Clone and configure
git clone https://github.com/yourname/multi-region-failover
cd multi-region-failover
cp terraform.tfvars.example terraform.tfvars

# 2. Deploy infrastructure
terraform init
terraform plan
terraform apply

# 3. Test failover (simulate us-east-1 outage)
./scripts/simulate-outage.sh


## Challenges & Learnings

### Challenge 1: RDS Cross-Region Lag
**Problem:** Initial setup had 5-15 second replication lag between regions  
**Solution:** Switched to RDS Global Database (lag reduced to <1 second)  
**Tradeoff:** +$200/month cost, but necessary for data consistency

### Challenge 2: Cold Start for Standby Region
**Problem:** First request after failover took 30+ seconds (EC2 instances were stopped)  
**Solution:** Keep standby instances running at min capacity (t3.micro)  
**Tradeoff:** +$15/month, but failover time dropped to 45 seconds

## Future Enhancements
- [ ] Add blue/green deployment capability
- [ ] Implement automated rollback on health check failure
- [ ] Expand to 3 regions (add EU-WEST-1)
- [ ] Add cost dashboard (track $/month per region)

## Blog Post
Read the full breakdown: [link to Medium/Dev.to article]

## License
MIT
```

**Why this works:**
- ✅ Problem statement hooks the reader
- ✅ Architecture diagram shows systems thinking
- ✅ "Why This Stack" shows decision-making skills
- ✅ Metrics prove real-world application
- ✅ Challenges section shows growth mindset
- ✅ Quick start = easy for recruiters to test

---

## 🛠️ Portfolio Project Ideas by Level

### Junior DevOps (0-2 years)

**Idea #1: Personal Website IaC**
- Deploy your resume site to AWS S3 + CloudFront using Terraform
- GitHub Actions for CI/CD
- **Why:** Shows basics without overcomplexity

**Idea #2: Docker Multi-Stage Build Library**
- Optimized Dockerfiles for 5 common languages (Python, Node, Go, Java, Rust)
- Include size comparisons and build time benchmarks
- **Why:** Docker is fundamental, optimization shows depth

**Idea #3: Log Aggregation Pipeline**
- Stream logs from Docker containers → Fluentd → S3 → Athena for querying
- **Why:** Demonstrates data pipeline + observability thinking

---

### Mid-Level DevOps (2-5 years)

**Idea #1: GitOps Operator**
- Build a small Kubernetes operator that watches a Git repo and auto-deploys changes
- **Why:** Shows Kubernetes depth + automation mindset

**Idea #2: Cloud Cost Optimizer**
- Python script that analyzes AWS/GCP bills and suggests savings (unused resources, right-sizing)
- **Why:** FinOps is hot, shows business impact

**Idea #3: Zero-Downtime Deployment Framework**
- CI/CD pipeline with canary deployments, automated rollback, and metrics-based promotion
- **Why:** Advanced deployment strategies are senior-level skills

---

### Senior DevOps (5+ years)

**Idea #1: Multi-Tenancy Platform**
- K8s-based platform for deploying isolated customer environments with namespace-level quotas
- **Why:** Platform engineering is the future of DevOps

**Idea #2: Disaster Recovery Automation**
- Multi-region DR orchestration with RTO/RPO tracking and automated failover testing
- **Why:** Shows strategic thinking + reliability engineering

**Idea #3: Internal Developer Portal**
- Backstage.io implementation with custom plugins for infrastructure provisioning
- **Why:** Self-service platforms are staff+ level work

---

## 🔄 The Portfolio Build-Measure-Learn Loop

### Step 1: Build (Week 1-3)
- Pick ONE project from the ideas above
- Create GitHub repo with proper README structure FIRST
- Build the MVP (minimum viable project)

### Step 2: Document (Week 3-4)
- Write detailed README with architecture diagrams
- Add code comments explaining non-obvious decisions
- Create a 3-5 minute demo video (Loom or YouTube)

### Step 3: Share (Week 4-5)
- Write a blog post on Medium/Dev.to
- Share on LinkedIn with lessons learned
- Post in relevant subreddits (r/devops, r/kubernetes)
- Tweet with #DevOps hashtag

### Step 4: Measure (Week 5-6)
- Track GitHub stars/forks
- Monitor blog post views
- Count recruiter InMails (before vs. after)

### Step 5: Learn & Iterate
- Read feedback comments
- Fix bugs people report
- Add "Community Contributions" section to README

---

## ⚠️ Common Portfolio Mistakes

### Mistake #1: Tutorial Hell
❌ Completing 10 Udemy courses, 0 original projects  
✅ Completing 2 courses + building 1 original project applying those concepts

**Fix:** After every tutorial, build a variation that solves YOUR problem.

---

### Mistake #2: No Context in README
❌ README: "This is a Terraform project. Run `terraform apply`."  
✅ README: "This project reduces AWS Lambda cold starts by 80% using provisioned concurrency. I built this after experiencing slow startups in production."

**Fix:** Always explain the "why" not just the "what."

---

### Mistake #3: Orphaned Projects
❌ 12 repos, all last updated 1-2 years ago  
✅ 3 active repos with commits in last 3 months

**Fix:** Archive old projects. Better to have 3 polished projects than 12 abandoned ones.

---

### Mistake #4: No Visuals
❌ Text-only README  
✅ Architecture diagrams + screenshots + demo GIF

**Fix:** Use draw.io or Excalidraw for diagrams. Use carbon.now.sh for beautiful code screenshots.

---

### Mistake #5: Building in Isolation
❌ Never sharing your work  
✅ Blog post + LinkedIn share + Reddit post

**Fix:** Sharing 1 project well > building 5 projects in silence.

---

## 🎯 GitHub Profile Optimization Checklist

- [ ] **Profile README** - Add a GitHub profile README (username/username repo)
- [ ] **Pinned Repos** - Pin your top 6 projects (not random forks)
- [ ] **Profile Photo** - Professional headshot (same as LinkedIn)
- [ ] **Bio** - Include role + key skills (e.g., "DevOps Engineer | Kubernetes, AWS, Terraform")
- [ ] **Location** - Add your city or "Remote" for recruiter searches
- [ ] **Contribution Graph** - Green squares in last 3 months (consistent activity)
- [ ] **README Badges** - CI/CD status badges, not vanity metrics
- [ ] **Topics** - Tag repos with relevant topics (#kubernetes, #terraform, #aws)

---

## 📈 Measuring Portfolio Impact

### Leading Indicators (Week-by-Week)
- GitHub stars on your projects
- Blog post views
- LinkedIn profile views spike after sharing

### Lagging Indicators (Month-by-Month)
- Recruiter InMails referencing your projects
- Interview requests from target companies
- Offers that mention "We loved your [Project X]"

**Example Success Story:**
> "I built a Terraform AWS VPC module library and wrote a blog post about it. Within 2 months: 120 GitHub stars, 5,000 blog views, and 3 recruiter InMails specifically mentioning the project. Landed a Senior DevOps role at a Series B startup."

---

## 🔗 Next Steps

After evaluating your project ideas:

1. **Create a project roadmap** - Month-by-month plan for next 6 months
2. **Set up GitHub repo structure** - Use the README template above
3. **Schedule build time** - Block 5-10 hours/week on your calendar
4. **Join accountability group** - Find peers on Reddit /r/devops or Discord servers
5. **Plan documentation** - Write blog post outline BEFORE coding

---

## 💡 Pro Tips

### Tip #1: Build in Public
Tweet your progress weekly. "Week 1: Designed the architecture. Week 2: Got Terraform modules working. Week 3: Hit a networking bug (here's how I solved it)."

This creates social accountability AND builds your personal brand.

### Tip #2: Contribute to Open Source First
Before building from scratch, contribute to existing projects:
- Terraform provider bugs
- Kubernetes operator documentation
- Ansible role improvements

This shows collaboration + gets you GitHub commits faster.

### Tip #3: Make It Forkable
Design your project so others can easily adapt it:
- Clear variable names
- Config file examples (`.env.example`)
- Modular structure

When others fork your project, recruiters see "This person builds reusable solutions."

---

**Remember:** 1 well-documented, production-grade project > 10 half-finished tutorials.
