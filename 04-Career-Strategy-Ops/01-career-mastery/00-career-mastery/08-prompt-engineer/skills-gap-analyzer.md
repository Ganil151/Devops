# 🎯 The "Skills Gap Analyzer" Prompt

## Overview
This prompt identifies critical skill gaps between your current abilities and your target role, then generates a personalized 90-day learning roadmap with specific resources and measurable outcomes.

---

## 📋 The Prompt

Copy and paste the text below into your AI assistant:

```
Role: Act as a DevOps Career Coach and Technical Learning Strategist. You understand the complete skill landscape for DevOps/SRE/Platform Engineering roles across different seniority levels (Junior → Senior → Staff) and can design accelerated learning paths.

Task:

1. Skills Inventory Analysis:
   
   My current skills with proficiency levels:
   [List your skills with self-rated proficiency 1-5, Example:]
   - Linux: 4/5
   - Docker: 3/5
   - Kubernetes: 2/5
   - Terraform: 3/5
   - AWS: 3/5
   - Python: 2/5
   - CI/CD (GitHub Actions): 4/5
   
   Target role: [e.g., "Senior DevOps Engineer at a Series B SaaS company"]
   Target timeline: [e.g., "6 months"]
   Time available: [e.g., "10 hours/week"]

2. Gap Analysis:
   
   Based on the target role, identify:
   - **Critical Gaps** (blocking you from getting the role) - Rate impact 1-10
   - **Nice-to-Have Gaps** (would strengthen application but not mandatory)
   - **Overinvested Skills** (skills you have that aren't needed for this role)
   
   For each critical gap, answer:
   - Why is this skill important for the target role?
   - What's the minimum proficiency needed? (e.g., "3/5 - can build basic pipelines")
   - How long to get there? (e.g., "30-40 hours")

3. 90-Day Learning Roadmap:
   
   Create a week-by-week plan structured as:
   
   **Month 1: Foundation Building**
   - Week 1-2: [Skill A] - [Specific resource] - [Measurable outcome]
   - Week 3-4: [Skill B] - [Specific resource] - [Measurable outcome]
   
   **Month 2: Hands-On Practice**
   - Week 5-6: [Project integrating Skills A+B]
   - Week 7-8: [Real-world scenario practice]
   
   **Month 3: Portfolio & Validation**
   - Week 9-10: [Build portfolio project showcasing new skills]
   - Week 11-12: [Certification OR blog post OR contribution to open source]
   
   For each skill, provide:
   - Best learning resources (free > paid when both are quality)
   - Measurable checkpoint (e.g., "Deploy 3-tier app to K8s by Week 4")
   - Common pitfalls to avoid

4. Study Strategy Optimization:
   
   Based on my time constraints, recommend:
   - Study schedule template (which days/times work best)
   - Learning modality mix (70% hands-on, 20% video, 10% reading)
   - Accountability mechanisms (learning in public, study groups, etc.)
   - Progress tracking method

5. Resume Integration:
   
   As I complete each milestone, suggest:
   - How to add this to my resume (X-Y-Z formula)
   - Which portfolio project to build to showcase the skill
   - How to get "proof" (certification, GitHub project, blog post)

Input Data:
[Paste a job description for your target role - optional but helpful]
```

---

## 🎓 Why This Works

### The Pareto Principle: 80/20 for Skill Development

**Core Insight:** 20% of skills get 80% of interview questions and 80% of day-to-day usage.

**Example for DevOps:**
- **Top 20% (must-have):** Docker, Kubernetes, Terraform/IaC, CI/CD, AWS/Cloud, Linux, Git
- **Next 30% (important):** Python/Bash scripting, Monitoring/Observability, Security basics
- **Remaining 50% (nice-to-have):** Specific tools like Istio, ArgoCD, Vault, etc.

This prompt helps you focus on the 20% that matters most for YOUR target role.

---

## 📊 Expected Output

### Example: Skills Gap Analysis

**Input:**
- Current Skills: Docker (3/5), AWS (2/5), Python (2/5), Jenkins (4/5)
- Target Role: Senior DevOps Engineer at a cloud-native startup
- Timeline: 6 months
- Time Available: 10 hrs/week

**AI Output:**

```
🚨 CRITICAL GAPS (Learn these first)

1. Kubernetes: Currently 0/5 → Target 4/5
   WHY: 80% of DevOps roles at cloud-native startups require K8s
   MINIMUM PROFICIENCY: Must be able to write Deployments, Services, debug pod issues, understand RBAC
   TIME INVESTMENT: 60 hours (6 weeks @ 10 hrs/week)
   
2. Terraform: Currently 0/5 → Target 3/5
   WHY: Infrastructure as Code is expected for senior roles
   MINIMUM PROFICIENCY: Can write modules, understand state management, use workspaces
   TIME INVESTMENT: 40 hours (4 weeks @ 10 hrs/week)

3. Observability: Currently 1/5 → Target 3/5
   WHY: Senior engineers own system reliability
   MINIMUM PROFICIENCY: Set up Prometheus + Grafana, create alerts, understand SLIs/SLOs
   TIME INVESTMENT: 30 hours (3 weeks @ 10 hrs/week)

⚡ NICE-TO-HAVE GAPS

4. GitOps (ArgoCD/Flux): Currently 0/5 → Target 2/5
   WHY: Modern CD pattern, shows you're current with trends
   TIME INVESTMENT: 20 hours (2 weeks @ 10 hrs/week)

5. Service Mesh (Istio): Currently 0/5 → Target 1/5
   WHY: Emerging pattern for microservices
   TIME INVESTMENT: 15 hours (1.5 weeks @ 10 hrs/week)

✅ OVERINVESTED SKILLS

- Jenkins (4/5): Many startups use GitHub Actions or GitLab CI instead
  RECOMMENDATION: Maintain current level, pivot to GitHub Actions (20 hours)
```

---

### Example: 90-Day Learning Roadmap

**AI Output (abbreviated):**

```
🗓️ 90-DAY TRANSFORMATION PLAN (10 hrs/week = 120 total hours)

════════════════════════════════════════════
MONTH 1: KUBERNETES MASTERY (40 hours)
════════════════════════════════════════════

Week 1-2: K8s Fundamentals (20 hours)
📚 Resource: "Kubernetes Documentation" + "KillerCoda Interactive Labs"
🎯 Outcome: Deploy a 3-tier app (frontend, backend, database) to Minikube
✅ Checkpoint: Can explain Pods, Deployments, Services, ConfigMaps

Week 3-4: K8s Deep Dive (20 hours)
📚 Resource: "CKAD Curriculum" (CKA too advanced for now)
🎯 Outcome: Set up Ingress, implement RBAC, configure resource limits
✅ Checkpoint: Pass 3 practice exams on Killer.sh
💡 Avoid: Don't get distracted by service meshes yet

════════════════════════════════════════════
MONTH 2: TERRAFORM + OBSERVABILITY (40 hours)
════════════════════════════════════════════

Week 5-6: Terraform Foundations (20 hours)
📚 Resource: "HashiCorp Learn" + "Terraform Up & Running" (book)
🎯 Outcome: Create reusable modules for AWS VPC, EC2, RDS
✅ Checkpoint: Build IaC for a full staging environment
💡 Avoid: Don't overcomplicate with workspaces early on

Week 7-8: Observability Stack (20 hours)
📚 Resource: Prometheus Docs + Grafana Tutorials + "The USE Method"
🎯 Outcome: Deploy Prometheus + Grafana to K8s, create 5 key dashboards
✅ Checkpoint: Set up alerts for CPU/Memory/Disk on K8s cluster
💡 Avoid: Don't try to monitor everything - focus on Golden Signals

════════════════════════════════════════════
MONTH 3: PORTFOLIO + PROOF (40 hours)
════════════════════════════════════════════

Week 9-10: Capstone Project (25 hours)
🎯 Build: "Multi-Environment K8s + Terraform + GitOps Pipeline"
  - Use Terraform to create EKS cluster
  - Deploy sample app with ArgoCD (GitOps)
  - Add Prometheus monitoring + Grafana dashboards
  - Document in detailed README with architecture diagram
📝 Blog Post: "Building a Production-Grade K8s Platform in 2 Weeks"

Week 11-12: Certification + Polish (15 hours)
🎯 Option A: CKAD Certification ($395 but strong signal)
🎯 Option B: Write 2 technical blog posts + contribute to 1 open-source K8s project
✅ Update: Resume, LinkedIn, GitHub with new skills + portfolio link
```

---

## 🛠️ Learning Resources by Skill

### Kubernetes

**Free:**
- [x] Kubernetes.io Official Docs (Interactive Tutorial)
- [x] KillerCoda Scenarios (hands-on labs in browser)
- [x] KodeKloud Free K8s Course

**Paid (if budget allows):**
- [x] CKAD Certification ($395) - Best ROI for K8s credibility
- [x] "Kubernetes in Action" by Marko Lukša (book, $40)

**Portfolio Project Ideas:**
- Deploy a microservices app (e.g., Sock Shop) with monitoring
- Build a K8s Operator for automating backups

---

### Terraform

**Free:**
- [x] HashiCorp Learn (Official, high quality)
- [x] Terraform Registry for module examples
- [x] FreeCodeCamp Terraform Course (YouTube, 2 hours)

**Paid:**
- [x] "Terraform: Up & Running" by Yevgeniy Brikman ($50) - Best practical guide
- [x] HashiCorp Certified: Terraform Associate ($70) - Entry-level certification

**Portfolio Project Ideas:**
- Multi-environment AWS infrastructure (dev/staging/prod)
- Terraform module library for common patterns

---

### Python for DevOps

**Free:**
- [x] Real Python (website with DevOps-focused tutorials)
- [x] Automate the Boring Stuff (online book)
- [x] Python for DevOps (O'Reilly - check if your library has it)

**Paid:**
- [x] "Python for DevOps" by Noah Gift ($40)

**Portfolio Project Ideas:**
- AWS cost optimizer script (boto3)
- Log parser for Kubernetes events
- Slack bot for deployment notifications

---

### CI/CD (GitHub Actions)

**Free:**
- [x] GitHub Actions Documentation (excellent)
- [x] GitHub Learning Lab (interactive)
- [x] TechWorld with Nana (YouTube channel)

**Portfolio Project Ideas:**
- Multi-stage pipeline: Build → Test → Security Scan → Deploy to K8s
- Reusable GitHub Actions workflow library

---

### Observability (Prometheus + Grafana)

**Free:**
- [x] Prometheus Docs + PromQL Tutorial
- [x] Grafana Tutorials + Public Dashboards for inspiration
- [x] "The USE Method" by Brendan Gregg (blog post)

**Paid:**
- [x] "Prometheus: Up & Running" ($40)

**Portfolio Project Ideas:**
- Full observability stack for K8s cluster
- Custom Grafana dashboard for application SLIs (latency, errors, saturation)

---

## 🔄 Learning Strategies

### Strategy #1: The "Build to Learn" Approach

**Traditional (slow):**
1. Watch 20 hours of tutorials
2. Take notes
3. Maybe build something at the end

**Build to Learn (faster):**
1. Watch 2-hour crash course
2. Immediately start building a project
3. Google/ChatGPT specific issues as you encounter them
4. Watch deep-dives only for concepts you struggled with

**Why it works:** Active learning (building) has 3x retention vs. passive (watching).

---

### Strategy #2: The "Public Learning" Method

**Every week, share:**
- What you learned
- What you built
- What confused you

**Where to share:**
- Twitter (use #100DaysOfDevOps hashtag)
- LinkedIn (technical post format)
- Dev.to or Medium (weekly blog posts)

**Benefits:**
- Forces you to clarify your thinking (teaching = deep learning)
- Builds your personal brand
- Creates accountability

---

### Strategy #3: The "Deliberate Practice" Framework

Not all practice is equal. Use this structure:

1. **Set micro-goals:** "Today I'll deploy a StatefulSet to K8s" (not "Learn Kubernetes")
2. **Time-box:** 90-minute focused sessions (Pomodoro: 25 min work, 5 min break)
3. **Immediate feedback:** Run the code/command immediately, don't save it for later
4. **Reflect:** Spend 10 minutes at the end writing "Today I learned..." notes

---

## ⚠️ Common Learning Mistakes

### Mistake #1: Tutorial Hell
❌ Completing course after course without building anything original  
✅ Complete ONE course → Build ONE project applying it → Move to next skill

**Fix:** After each course, build a variation project (not just the tutorial code).

---

### Mistake #2: Learning Too Broad, Too Fast
❌ Trying to learn Kubernetes + Terraform + Python + AWS all at once  
✅ Master ONE skill at a time in sequence (see 90-day roadmap)

**Fix:** Focus on 1-2 skills per month maximum.

---

### Mistake #3: No Measurable Goals
❌ "I want to learn Kubernetes"  
✅ "By March 1st, I'll deploy a 5-service microservices app to K8s with monitoring"

**Fix:** Use SMART goals (Specific, Measurable, Achievable, Relevant, Time-bound).

---

### Mistake #4: Skipping Fundamentals
❌ Jumping straight to Istio without understanding K8s Services  
✅ Master the basics first, then layer on advanced topics

**Fix:** Use the roadmap sequence - it's designed to build on previous knowledge.

---

### Mistake #5: Not Tracking Progress
❌ Vague sense of "I've been learning for 3 months"  
✅ Spreadsheet tracking hours invested + projects completed per skill

**Fix:** Use Notion/Google Sheets to log daily study time and outcomes.

---

## 🎯 Progress Tracking Template

Create a spreadsheet with these columns:

| Date | Skill | Hours | Activity | Outcome | Evidence |
|------|-------|-------|----------|---------|----------|
| 2/11 | K8s | 2 | Deployed 3-tier app | Successfully running in Minikube | GitHub commit |
| 2/12 | K8s | 1.5 | Debugged CrashLoopBackOff | Learned about liveness probes | Notes doc |
| 2/13 | Terraform | 3 | Built VPC module | Reusable module with variables | GitHub repo |

**Weekly Review:** Every Sunday, review the week and answer:
- Did I hit my 10-hour target?
- What was my biggest win?
- What do I need to focus on next week?

---

## 📈 Measuring Skill Improvement

### Self-Assessment Rubric (1-5 Scale)

**Level 1: Awareness**
- "I've heard of this tool and can explain what it does at a high level"
- Can't use it yet

**Level 2: Beginner**
- "I can follow a tutorial and get basic examples working"
- Can deploy hello-world apps

**Level 3: Competent**
- "I can build production-ready solutions with this tool"
- Can debug common issues
- Can explain trade-offs to others

**Level 4: Proficient**
- "I can architect complex systems and optimize for scale"
- Can teach others
- Know advanced features and edge cases

**Level 5: Expert**
- "I contribute to the tool's ecosystem (docs, PRs, blogs)"
- Recognized as a thought leader

**Target for most DevOps skills:** Level 3-4 (expert is overkill for most roles)

---

## 🔗 Next Steps

After creating your learning roadmap:

1. **Block calendar time** - Schedule your 10 hrs/week study time NOW
2. **Set up accountability** - Find a study buddy or join /r/devops Discord
3. **Create your tracking spreadsheet** - Start logging from Day 1
4. **Pick Month 1 resources** - Download/bookmark everything you need for the first 4 weeks
5. **Announce your goal** - Tweet or LinkedIn post: "Starting my 90-day DevOps skill transformation focusing on [X, Y, Z]"

---

## 💡 Pro Tips

### Tip #1: The "Adjacent Skills" Shortcut
Don't learn skills in isolation. If you're learning Kubernetes, pair it with:
- Helm (package management)
- Prometheus (monitoring K8s)
- GitHub Actions (CI/CD to K8s)

This creates a "skill cluster" that's more valuable than standalone knowledge.

---

### Tip #2: Use AI Assistants as Tutors
When stuck:
1. Paste your error into ChatGPT/Claude
2. Ask: "Explain this like I'm familiar with Docker but new to Kubernetes"
3. Ask follow-ups: "What are the tradeoffs of Solution A vs B?"

This is like having a senior engineer available 24/7.

---

### Tip #3: The "Feynman Technique"
After learning a concept:
1. Try to explain it to a 10-year-old (or rubber duck)
2. Identify gaps in your explanation
3. Go back and re-learn those specific gaps

If you can't explain it simply, you don't understand it yet.

---

**Remember:** 90 days of focused, deliberate practice beats 2 years of passive tutorial watching.
