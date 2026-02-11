# 📊 Images Directory

## Overview

This directory contains all visual assets for the Career & Persona Mastery module, including diagrams, screenshots, infographics, and visual guides.

---

## 📁 Current Structure

```
images/
├── readme.md                  This file
└── pricing-comparison.png     Pricing strategy infographic (796 KB)
```

---

## 🎨 Image Guidelines

### File Naming Convention
- **Lowercase with hyphens**: `career-progression-diagram.png`
- **Be descriptive**: `resume-ats-flow-chart.png`
- **Include version if needed**: `skills-matrix-v2.png`

### Recommended Formats
- **Diagrams**: PNG or SVG (for scalability)
- **Screenshots**: PNG (for clarity with text)
- **Infographics**: PNG or JPG
- **Icons/Logos**: SVG or PNG with transparency

### Image Optimization
- Compress before adding: [TinyPNG](https://tinypng.com) or [ImageOptim](https://imageoptim.com)
- **Maximum width**: 1200px for diagrams
- **Target file size**: Under 500KB when possible
- **Retina/HD**: 2x resolution for important diagrams

---

## 🔗 Referencing Images in Documentation

### From Module READMEs (e.g., from `/01-devops-persona/readme.md`)
```markdown
![Career Progression Diagram](../images/career-progression-diagram.png)
```

### From Main README (`/readme.md`)
```markdown
![Skills Matrix](./images/skills-matrix.png)
```

### From Submodules (e.g., from `/08-interview-mastery/01-technical-deep-dives/kubernetes.md`)
```markdown
![K8s Architecture](../../images/kubernetes-architecture.png)
```

---

## 📝 Planned Images (To Be Created)

### Career Progression
- [ ] `career-ladder-diagram.png` - Junior → Mid → Senior → Staff progression
- [ ] `skills-matrix.png` - T-shaped engineer visual
- [ ] `90-day-learning-roadmap.png` - Sample learning path

### Resume & Job Search
- [ ] `ats-parsing-flow.png` - How ATS systems work
- [ ] `resume-x-y-z-formula.png` - Google's accomplishment formula
- [ ] `linkedin-profile-sections.png` - Optimized profile layout

### Interview Prep
- [ ] `star-method-diagram.png` - STAR framework visualization
- [ ] `interview-funnel.png` - Application → Offer pipeline

### Salary Negotiation
- [ ] `total-compensation-breakdown.png` - Base + Equity + Bonus + Benefits
- [ ] `market-percentiles.png` - 25th/50th/75th percentile visualization

---

## 🛠️ Recommended Tools for Creating Diagrams

| Tool | Best For | Cost |
|------|----------|------|
| [Excalidraw](https://excalidraw.com) | Quick sketches, hand-drawn style | Free |
| [Draw.io](https://app.diagrams.net) | Professional diagrams | Free |
| [Figma](https://figma.com) | UI mockups, high-fidelity designs | Free tier |
| [Mermaid](https://mermaid.js.org) | Code-based diagrams (can embed in markdown) | Free |
| [Lucidchart](https://lucidchart.com) | Enterprise flowcharts | Paid |
| [Canva](https://canva.com) | Infographics, social media graphics | Free tier |

---

## 💡 Design Tips

### For Diagrams
- **Keep it simple**: One concept per diagram
- **Use consistent colors**: Stick to 3-4 colors max
- **Label clearly**: All boxes and arrows should have labels
- **Include legend**: If using symbols or colors with specific meaning

### For Infographics
- **Visual hierarchy**: Most important info first
- **White space**: Don't overcrowd
- **Font size**: Minimum 14pt for readability
- **Contrast**: Ensure text is readable on background

### For Screenshots
- **Crop tightly**: Show only relevant UI
- **Highlight important areas**: Use arrows or boxes
- **Redact sensitive info**: Remove API keys, emails, etc.
- **Consistent window size**: Same resolution for series of screenshots

---

## 📊 Current Inventory

| File | Size | Used In | Description |
|------|------|---------|-------------|
| pricing-comparison.png | 796 KB | (Reference) | Pricing strategy comparison chart |
| career-acceleration-loop.png | 71 KB | (Readme) | Career acceleration loop diagram |

---

## 🚀 How to Add New Images

### Step 1: Create or Source Image
- Use one of the recommended tools above
- Follow naming convention
- Optimize file size

### Step 2: Add to This Directory
```bash
# From your local machine
cp /path/to/image.png /home/gsmash/Documents/Devops/00-career-mastery/images/

# Verify it's there
ls -lh /home/gsmash/Documents/Devops/00-career-mastery/images/
```

### Step 3: Reference in Markdown
```markdown
![Alt Text Description](../images/your-image.png)
```

### Step 4: Update This README
Add the image to the "Current Inventory" table above.

---

## ⚠️ Important Notes

- **Alt Text is Required**: Always include descriptive alt text for accessibility
- **Copyright**: Only use images you have rights to use
- **Source Files**: Keep editable source files (`.excalidraw`, `.drawio`, `.fig`) in a local backup
- **Version Control**: Git tracks binary files poorly; consider external storage for large PSDs/Sketch files
- **Accessibility**: Ensure diagrams work in both light and dark themes if possible

---

## 📈 Image Usage Statistics

Images enhance documentation by:
- **+65% comprehension** for complex concepts
- **+40% retention** rate for visual learners
- **+50% engagement** on social media shares
- **-30% support questions** when using annotated screenshots

**Use visuals strategically** where they add clarity, not decoration.

---

**Last Updated:** 2026-02-11  
**Total Images:** 1  
**Total Size:** ~796 KB

---

**Need help creating a specific diagram?** Check the "Recommended Tools" section or request assistance in the main repository.
