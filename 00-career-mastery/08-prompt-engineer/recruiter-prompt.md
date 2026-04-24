# 🎯 The "High-Octane" DevOps Recruiter Prompt

## Overview
This prompt transforms your resume by analyzing it through the lens of a senior technical recruiter who has hired for FAANG and high-growth startups.

---

## 📋 The Prompt

Copy and paste the text below into your AI assistant:

```
Role: Act as a Senior DevOps Engineering Recruiter with 15 years of experience hiring for FAANG and high-growth startups. You have a "no-nonsense" approach and an eye for elite technical talent.

Task:
1. Match Score: Analyze my Resume against the provided Job Description (JD). Give a blunt Match Score out of 100 based on technical stack alignment, seniority, and scale.

2. Keyword Gap Analysis: Identify the top 10 missing or under-emphasized technical keywords (e.g., specific tools like Terraform, Kubernetes, or concepts like GitOps, SLIs/SLOs, or Zero-Trust).

3. Experience Overhaul: Rewrite my "Experience" section. Use the Google X-Y-Z formula: "Accomplished [X] as measured by [Y], by doing [Z]."

   Focus on outcomes:
   - Use metrics like deployment frequency, MTTR (Mean Time to Recovery), cloud cost savings (%), or developer productivity.
   
   Tone:
   - Ensure the language sounds like a seasoned engineer, not a marketing brochure.

Input Data:

Job Description: [PASTE JD HERE]

My Current Resume: [PASTE RESUME HERE]

Next Steps: After receiving the analysis, ask the AI to prioritize which keywords to add first and suggest specific lines to replace in your resume.
```

---

## 🎓 Why This Works

### 1. **Role Definition Sets Context**
By specifying "15 years of FAANG experience," you're priming the AI to think like someone who has seen thousands of resumes and knows what separates top 1% candidates.

### 2. **The X-Y-Z Formula**
This is Google's internal framework for writing accomplishments:
- **X** = What you did (the action)
- **Y** = How it was measured (the metric)
- **Z** = How you did it (the method/tool)

**Example:**
- ❌ "Managed Kubernetes clusters"
- ✅ "Reduced pod startup time by 40% (Y) by implementing HPA with custom metrics (Z) across 50+ microservices (X)"

### 3. **Keyword Gap Analysis**
ATS systems and recruiters scan for specific technical terms. Missing even ONE critical keyword (e.g., "Istio" when the JD mentions service mesh) can sink your application.

---

## 📊 Expected Output

You should receive:

1. **Match Score** (e.g., "72/100 - Strong technical fit, but missing leadership signals")
2. **Top 10 Keyword Gaps** (e.g., "Add: Observability, SRE, Incident Management, Helm, ArgoCD...")
3. **Rewritten Experience Bullets** (with before/after comparisons)

---

## 🔄 Iteration Strategy

### Round 1: Initial Analysis
- Get the match score and keyword gaps
- Identify low-hanging fruit (keywords you actually have experience with but didn't mention)

### Round 2: Experience Rewrite
- Ask the AI to rewrite 3-5 bullets at a time (not the entire resume at once)
- Verify the metrics are accurate to your actual experience

### Round 3: Tone Calibration
- If the language sounds too "salesy," ask: "Make this sound more technical and less like marketing copy"
- If it's too robotic, ask: "Add slight personality while keeping it professional"

---

## ⚠️ Common Pitfalls

1. **Don't fabricate metrics** - If the AI suggests "reduced costs by 60%" but you only achieved 30%, correct it
2. **Don't keyword stuff** - If you've never used Istio, don't add it just because the JD mentions it
3. **Don't lose your voice** - The AI is a tool, not a ghostwriter. Keep your authentic experiences

---

## 🔗 Next Steps

After using this prompt:
1. Run the **ATS Stress Test** (`ats-stress-test.md`) to ensure formatting is clean
2. Update your LinkedIn profile with the new X-Y-Z bullets
3. Track which versions of your resume get the most recruiter responses

---

**Pro Tip:** Save the AI's output in a `resume-versions/` folder with timestamps. This creates an audit trail of improvements.
