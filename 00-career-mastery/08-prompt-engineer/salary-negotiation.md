# 💰 The "Salary Negotiation Strategist" Prompt

## Overview
This prompt helps you prepare a data-driven negotiation strategy, identify your market value, and craft negotiation scripts that maximize your compensation package without damaging relationships.

---

## 📋 The Prompt

Copy and paste the text below into your AI assistant:

```
Role: Act as a Compensation Consultant specializing in DevOps/Platform Engineering roles at high-growth tech startups and FAANG companies. You understand total compensation packages (base, equity, bonuses, benefits) and how to negotiate from a position of strength without burning bridges.

Task:

1. Market Value Analysis:
   Based on the following data, calculate my realistic market value range:
   - Job Title: [e.g., "Senior DevOps Engineer"]
   - Years of Experience: [e.g., "5 years"]
   - Location: [e.g., "Austin, TX" or "Remote"]
   - Company Stage: [e.g., "Series B startup" or "FAANG" or "Mid-size SaaS (500-2000 employees)"]
   - Technical Stack: [e.g., "Kubernetes, AWS, Terraform, Python"]
   
   Provide:
   - Base salary range (25th, 50th, 75th percentile)
   - Equity expectations (% for startups, RSUs for public companies)
   - Total comp range
   - Data sources to verify (Levels.fyi, Blind, Glassdoor)

2. Current Offer Analysis:
   Their offer:
   - Base salary: $[X]
   - Equity: [Y shares/RSUs or Z%]
   - Bonus: [Performance bonus %]
   - Other: [Sign-on, relocation, etc.]
   
   Your current compensation: $[A] total comp
   
   Questions to answer:
   - Is this offer above/below market median?
   - What's the equity actually worth? (Use current valuation or strike price)
   - Are there red flags? (Below 50th percentile, low equity, no bonus structure?)

3. Negotiation Strategy:
   Based on my leverage:
   - Do I have competing offers? [Yes/No + details]
   - Did I interview well? [Describe final round reception]
   - Is this role hard to fill? [Niche skills or generic?]
   
   Provide:
   - Recommended counter-offer (be specific: "Ask for $X base + Y RSUs")
   - Negotiation script for the recruiter call
   - 3 alternative asks if base is "locked" (more equity, sign-on bonus, remote flexibility)
   - Red lines: When to walk away

4. Total Comp Breakdown:
   Create a "4-Year Earnings" table comparing:
   - Their initial offer
   - Your counter-offer
   - Your current job (if employed)
   
   Account for:
   - Equity vesting schedule
   - Tax implications (ISO vs NSO vs RSUs)
   - 401k match and benefits value

5. The Email Template:
   Draft a professional counter-offer email that:
   - Expresses enthusiasm for the role
   - Anchors with market data (not emotions)
   - Proposes specific numbers
   - Leaves room for dialogue
   - Maintains positive tone

Input Data:
[PASTE YOUR OFFER LETTER OR DETAILS]
[PASTE YOUR CURRENT COMP IF EMPLOYED]
```

---

## 🎓 Why This Works

### The Psychology of Negotiation

**Key Principle:** Companies expect you to negotiate. NOT negotiating signals:
- Lack of confidence
- Unfamiliarity with your market value
- Desperation

**Data:**
- **84% of employers** leave room in the initial offer expecting negotiation
- **76% of people** who negotiate get more money
- Average negotiation gain: **$5,000-$15,000** in base salary

---

## 📊 Expected Output

### Example: Market Value Analysis

**Input:**
- Title: Senior DevOps Engineer
- Experience: 5 years
- Location: Remote (US)
- Company: Series B startup (50-200 employees)
- Stack: Kubernetes, AWS, Terraform, Python

**AI Output:**
```
Market Value Range (2026 Data):

Base Salary:
• 25th percentile: $145,000
• 50th percentile: $165,000
• 75th percentile: $185,000

Equity (Series B):
• Typical grant: 0.10% - 0.25% of company
• 4-year vest with 1-year cliff

Total Comp (4-year average):
• Conservative: $170k (base) + $30k/yr (equity) = $200k
• Median: $165k + $50k/yr = $215k
• Strong: $185k + $80k/yr = $265k

Data Sources:
- Levels.fyi (1,200+ DevOps data points)
- Blind Salary Comparisons
- Carta Equity Benchmark (startup equity data)
```

---

### Example: Negotiation Email Template

**Scenario:** Offer is $150k base + 0.10% equity. Market median is $165k + 0.15%.

**AI-Generated Email:**

```
Subject: Re: Offer for Senior DevOps Engineer Role

Hi [Recruiter Name],

Thank you so much for extending the offer for the Senior DevOps Engineer position. 
I'm genuinely excited about the opportunity to work with [Team/Tech Stack/Mission] 
and I think there's a great fit here.

After reviewing the offer details and doing market research, I wanted to discuss 
the compensation structure to ensure alignment with my experience and the current 
market landscape.

Based on recent data from Levels.fyi and discussions with peers in similar roles 
at Series B companies, the market range for Senior DevOps Engineers with 5+ years 
of experience (especially with Kubernetes and AWS expertise) is typically:

• Base: $160,000 - $180,000
• Equity: 0.15% - 0.25%

Given my background in [specific relevant experience: e.g., "scaling infrastructure 
at a previous startup from 100k to 5M users"], I'd like to propose:

• Base salary: $170,000
• Equity: 0.18%

I'm also open to discussing alternative structures if base salary has constraints 
(e.g., a sign-on bonus or accelerated equity vesting).

I'm confident we can find a structure that works for both sides. Let me know your 
thoughts, and I'm happy to jump on a call to discuss further.

Looking forward to hearing from you!

Best,
[Your Name]
```

**Why this works:**
- ✅ Expresses enthusiasm first
- ✅ Anchors with market data (not "I need this to pay rent")
- ✅ Proposes specific numbers
- ✅ Offers flexibility
- ✅ Invites dialogue

---

## 🛠️ Advanced Negotiation Tactics

### Tactic #1: The "Multiple Offers" Leverage

**If you have competing offers:**

```
"I'm currently evaluating offers from [Company A] and [Company B]. Your role is 
my top choice because of [specific reason], but I need to ensure the compensation 
is competitive. Company A's offer is $X base with Y equity. Can you match or 
exceed this?"
```

**Important:** Don't bluff. Only mention real offers.

---

### Tactic #2: The "Equity Deep Dive"

Startups often lowball equity because candidates don't understand it. Ask:

1. **"What's the current 409A valuation?"**
   - This determines the strike price for options
   
2. **"How many shares outstanding?"**
   - Let's you calculate your actual ownership %
   
3. **"What was the last round valuation and how much runway do you have?"**
   - Assesses risk of dilution and down-rounds

**Example Calculation:**
- Grant: 50,000 options
- Strike price: $1.00 (from 409A)
- Current preferred price: $5.00 (last funding round)
- Total shares outstanding: 50,000,000

Your ownership: 50,000 / 50,000,000 = **0.10%**  
Current paper value: 50,000 × ($5 - $1) = **$200,000**  
Annual equity value (4-year vest): $200,000 / 4 = **$50k/year**

---

### Tactic #3: The "Total Comp Framework"

If they say "base is locked," negotiate other components:

| Component | Negotiable? | Typical Ask |
|-----------|-------------|-------------|
| Base salary | Sometimes | $10k-$20k above offer |
| Equity | Usually | 25%-50% more shares |
| Sign-on bonus | Often | $10k-$30k (one-time) |
| Performance bonus | Sometimes | 10%-20% of base |
| Remote work | Very | 1-2 days WFH → Full remote |
| PTO | Sometimes | +5 days/year |
| L&D budget | Often | $2k-$5k/year |

**Example Script:**
```
"I understand base is constrained at $150k. Would you be open to a $20k sign-on 
bonus and increasing the equity grant to 0.18% to bring the total comp to market median?"
```

---

### Tactic #4: The "Future Review" Clause

If they can't meet your number now, negotiate a performance review:

```
"I understand the budget constraints for this level. Would you be open to a 
6-month performance review with the possibility of a promotion to Staff DevOps 
Engineer if I deliver [specific milestones]? I'd like this documented in writing."
```

**Why this works:**
- Shows you're willing to prove yourself
- Creates a clear path to higher comp
- Gets commitment in writing

---

## ⚠️ Common Negotiation Mistakes

### Mistake #1: Negotiating Too Early
❌ Asking about salary in the first recruiter screen  
✅ Wait until you have an offer in hand

**Why:** You have zero leverage before they've decided they want you.

---

### Mistake #2: Giving a Number First
**Recruiter:** "What are your salary expectations?"

❌ "I'm looking for $160k"  
✅ "I'm focused on finding the right fit first. Can you share the budgeted range for this role?"

**Why:** Whoever states a number first loses. Make them anchor.

---

### Mistake #3: Accepting Immediately
**Recruiter:** "We'd like to offer you the position at $X."

❌ "Amazing! I accept!"  
✅ "Thank you! I'm excited. Can I have 48 hours to review the details?"

**Why:** Enthusiasm kills negotiation leverage. Always take time.

---

### Mistake #4: Negotiating on Emotion
❌ "I have student loans and need at least $X"  
✅ "Based on market data for Senior DevOps roles with Kubernetes expertise, the median is $165k"

**Why:** Companies don't care about your personal finances. They care about market rates.

---

### Mistake #5: Not Getting It in Writing
❌ Verbal promises: "We'll do a review in 6 months"  
✅ "Can we add that to the offer letter?"

**Why:** Verbal promises disappear when your hiring manager leaves or gets fired.

---

## 🔄 The Negotiation Timeline

### Week 1: Offer Received
- [ ] Thank them for the offer
- [ ] Ask for 48-72 hours to review
- [ ] DO NOT accept immediately

### Week 1-2: Research Phase
- [ ] Check Levels.fyi for comparable roles
- [ ] Post anonymously on Blind for feedback
- [ ] Calculate equity value using their 409A
- [ ] Determine your walk-away number

### Week 2: Counter-Offer
- [ ] Send your counter-offer email (or call)
- [ ] Anchor with market data
- [ ] Propose 15-20% above their offer (they'll meet you in the middle)

### Week 2-3: Negotiation
- [ ] Expect 2-3 rounds of back-and-forth
- [ ] Be willing to compromise on some components
- [ ] Keep the tone collaborative, not adversarial

### Week 3: Acceptance
- [ ] Get final offer in writing
- [ ] Review offer letter for any discrepancies
- [ ] Sign and celebrate! 🎉

---

## 🎯 Negotiation Scenarios by Experience Level

### Junior DevOps (0-2 years)
**Leverage:** Low  
**Strategy:** Focus on learning opportunities, not comp  
**Ask:** "Is there a mentorship program? What's the path to mid-level?"

### Mid-Level DevOps (2-5 years)
**Leverage:** Medium  
**Strategy:** Highlight specific technical wins  
**Ask:** $10k-$15k above initial offer + more equity

### Senior DevOps (5-8 years)
**Leverage:** High  
**Strategy:** Emphasize leadership and architecture experience  
**Ask:** $15k-$25k above initial offer + title bump if lowballed

### Staff/Principal (8+ years)
**Leverage:** Very High  
**Strategy:** Negotiate strategic impact and autonomy  
**Ask:** Custom comp package + equity refresh schedule

---

## 📈 Maximizing Equity Value

### Understanding Vesting Schedules

**Standard:** 4-year vest, 1-year cliff
- **Cliff:** 0% vests for first 12 months, then 25% vests on day 366
- **Monthly vesting:** Remaining 75% vests monthly over next 36 months

**Negotiation opportunity:**
```
"Would you consider a 3-year vest instead of 4-year? I plan to be here long-term, 
but a shorter vest aligns better with my financial planning."
```

---

### Equity Refresh Grants

At big tech companies (FAANG), negotiate refresh grants:

**Example:**
- Initial grant: 100,000 RSUs over 4 years
- Year 2 refresh: +25,000 RSUs (if high performer)
- Year 3 refresh: +30,000 RSUs

**Ask during negotiation:**
```
"What's the equity refresh policy for high performers? Is this documented?"
```

---

## 🔗 Next Steps

After successful negotiation:

1. **Update your spreadsheet** - Track accepted offer vs. your initial target
2. **Send thank-you note** - To hiring manager and recruiter
3. **Plan your onboarding** - Review what you promised to deliver (so you can renegotiate in 12 months)
4. **Update Levels.fyi** - Contribute your data anonymously to help others

---

## 📚 Additional Resources

### Salary Data Platforms
- **Levels.fyi** - Most accurate for tech (500k+ data points)
- **Blind** - Real-time peer comparisons
- **Carta** - Startup equity benchmarks
- **H1B Salary Database** - Public data on what companies pay

### Books
- *"Never Split the Difference"* by Chris Voss (FBI negotiation tactics)
- *"Negotiating Your Salary"* by Jack Chapman
- *"Getting to Yes"* by Roger Fisher

### Podcasts
- **Equity Mates** - Understanding startup equity
- **The Salary Negotiation Podcast** - Interview scenarios

---

## 💡 Pro Tips

### Tip #1: Track Your Wins
Keep a "brag doc" of your achievements every month. This makes negotiation easier 12 months later when you ask for a raise.

### Tip #2: Negotiate in Person (or Video)
Email is for confirming. The real negotiation happens in real-time conversation where you can read reactions.

### Tip #3: Practice Out Loud
Role-play the negotiation call with a friend. Saying "I'm looking for $170,000" out loud feels different than typing it.

---

**Remember:** The worst they can say is "no," and you're back to the original offer. Companies rarely rescind offers because you negotiated professionally.
