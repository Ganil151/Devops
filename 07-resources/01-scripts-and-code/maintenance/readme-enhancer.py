#!/usr/bin/env python3
"""
README Enhancement Automation Script
=====================================
Helps automate the enhancement of README files for Junior DevOps content.

This script:
1. Analyzes existing README files
2. Identifies gaps based on enhancement guide
3. Generates enhancement templates
4. Validates enhanced content

Author: DevOps Team
Version: 1.0.0
"""

import sys
import logging
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass
import re

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)


@dataclass
class ReadmeAnalysis:
    """Analysis results for a README file."""
    path: Path
    current_lines: int
    has_toc: bool
    has_diagrams: bool
    has_scenarios: bool
    has_exercises: bool
    has_interview_prep: bool
    has_knowledge_check: bool
    scenario_count: int
    exercise_count: int
    question_count: int
    estimated_enhancement: int


class ReadmeEnhancer:
    """Analyzes and enhances README files."""
    
    REQUIRED_SECTIONS = [
        "Table of Contents",
        "Real-World",
        "Scenario",
        "Exercise",
        "Hands-On",
        "Interview",
        "Knowledge Check",
        "Self-Assessment"
    ]
    
    def __init__(self, readme_path: Path):
        """Initialize enhancer with README path."""
        self.path = readme_path
        self.content = ""
        self.analysis: Optional[ReadmeAnalysis] = None
        
        if not self.path.exists():
            raise FileNotFoundError(f"README not found: {self.path}")
        
        self.content = self.path.read_text()
    
    def analyze(self) -> ReadmeAnalysis:
        """Analyze README and identify enhancement opportunities."""
        logger.info(f"📊 Analyzing: {self.path.name}")
        
        lines = self.content.splitlines()
        
        # Count patterns
        scenario_count = len(re.findall(r'scenario|incident|failure', self.content, re.I))
        exercise_count = len(re.findall(r'exercise|hands-on|practice', self.content, re.I))
        question_count = len(re.findall(r'^\d+\.\s+\*\*".*"\*\*', self.content, re.M))
        
        # Check sections
        has_toc = 'table of contents' in self.content.lower()
        has_diagrams = '```mermaid' in self.content
        has_scenarios = scenario_count >= 3
        has_exercises = exercise_count >= 3
        has_interview = 'interview' in self.content.lower() and question_count >= 5
        has_knowledge_check = 'knowledge check' in self.content.lower()
        
        # Estimate enhancement size
        current_lines = len(lines)
        target_lines = 1200  # Target for comprehensive README
        estimated_enhancement = max(0, target_lines - current_lines)
        
        self.analysis = ReadmeAnalysis(
            path=self.path,
            current_lines=current_lines,
            has_toc=has_toc,
            has_diagrams=has_diagrams,
            has_scenarios=has_scenarios,
            has_exercises=has_exercises,
            has_interview_prep=has_interview,
            has_knowledge_check=has_knowledge_check,
            scenario_count=scenario_count,
            exercise_count=exercise_count,
            question_count=question_count,
            estimated_enhancement=estimated_enhancement
        )
        
        return self.analysis
    
    def print_analysis(self):
        """Print analysis results."""
        if not self.analysis:
            self.analyze()
        
        a = self.analysis
        
        print(f"\n{'='*70}")
        print(f"📄 README: {a.path.name}")
        print(f"{'='*70}")
        print(f"Current Size: {a.current_lines} lines")
        print(f"Target Size:  1200 lines (comprehensive)")
        print(f"Gap:          {a.estimated_enhancement} lines needed")
        print(f"\n✓ = Present | ✗ = Missing")
        print(f"{'─'*70}")
        print(f"{'✓' if a.has_toc else '✗'} Table of Contents")
        print(f"{'✓' if a.has_diagrams else '✗'} Mermaid Diagrams")
        print(f"{'✓' if a.has_scenarios else '✗'} Real-World Scenarios ({a.scenario_count} found, need 3+)")
        print(f"{'✓' if a.has_exercises else '✗'} Hands-On Exercises ({a.exercise_count} found, need 3+)")  
        print(f"{'✓' if a.has_interview_prep else '✗'} Interview Preparation ({a.question_count} found, need 8+)")
        print(f"{'✓' if a.has_knowledge_check else '✗'} Knowledge Check & Assessment")
        
        # Priority score
        missing = sum([
            not a.has_toc,
            not a.has_diagrams,
            not a.has_scenarios,
            not a.has_exercises,
            not a.has_interview_prep,
            not a.has_knowledge_check
        ])
        
        priority = "🔴 HIGH" if missing >= 4 else "🟡 MEDIUM" if missing >= 2 else "🟢 LOW"
        print(f"\nPriority: {priority} ({missing}/6 sections missing)")
        print(f"{'='*70}\n")
    
    def generate_template(self, output_path: Optional[Path] = None) -> str:
        """Generate enhancement template based on analysis."""
        if not self.analysis:
            self.analyze()
        
        module_name = self.path.parent.name.replace('-', ' ').title()
        
        template = f"""# 🔧 {module_name}

> **"[INSERT IMPACTFUL QUOTE ABOUT THIS TOPIC]"**

[2-3 paragraph introduction explaining the module]

**Why This Matters for Junior DevOps Engineers:**
- 🚨 **[Impact Category]**: [Specific fact]
- 💰 **[Impact Category]**: [Specific fact]
- 🎯 **[Impact Category]**: [Specific fact]
- 🔧 **[Impact Category]**: [Specific fact]

---

## 📚 Table of Contents

1. [Core Concepts](#-core-concepts)
2. [Technical Deep-Dive](#-technical-deep-dive)
3. [Real-World Scenarios](#-real-world-scenarios)
4. [Security Best Practices](#-security-best-practices)
5. [Common Pitfalls](#-common-pitfalls--solutions)
6. [Hands-On Exercises](#-hands-on-exercises)
7. [Interview Preparation](#-interview-preparation)
8. [Knowledge Check](#-knowledge-check)

---

## 🏗️ Core Concepts

[ADD LIFECYCLE DIAGRAM]

```mermaid
graph TD
    A[Stage 1] --> B{{Decision}}
    B -- Success --> C[Stage 2]
    B -- Failure --> D[Error]
```

### 🔍 Concept Breakdown

**Stage 1: [Name]**
- **What**: [Description]
- **Why**: [Reason]
- **How**: [Method]

---

## 💻 Technical Deep-Dive

### [Feature 1]

**The Old Way**:
```python
# ❌ BAD - [Why bad]
[old code]
```

**The Modern Way**:
```python
# ✅ GOOD - [Why good]
[new code]
```

---

## 🎭 Real-World Scenarios

### 🛡️ Scenario 1: The "[Name]" Incident

**The Incident:** [What happened]

**The Failure:** [What broke]

**The Impact:**
- ❌ [Impact 1]
- ❌ [Impact 2]
- ❌ [Cost/time]

**The Fix:**
```python
# ✅ SOLUTION
[fixed code]
```

**Lessons Learned:**
1. [Lesson]
2. [Lesson]

---

## 🔒 Security Best Practices

### 1. [Vulnerability]

**The Risk**: [Description]

**Mitigation**:
```python
# ✅ SECURE
[safe code]
```

---

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: [Name]

```python
# ❌ BAD
[wrong code]

# ✅ GOOD
[correct code]
```

---

## 🎯 Hands-On Exercises

### Exercise 1: [Name]

**Objective**: [Goal]

**Requirements**:
- [Requirement 1]
- [Requirement 2]

**Starter Code**:
```python
# TODO: Complete this
```

---

## 🎙️ Interview Preparation

**1. "[Question]"**

**Answer**: [Detailed explanation]

```python
# Example
```

---

## 🧠 Knowledge Check

**1. [Question]**
- [ ] Option A
- [x] Option B  
- [ ] Option C

**Explanation**: [Why B is correct]

---

## 🎓 Self-Assessment Checklist

Before moving to the next module, ensure you can:

- [ ] [Skill 1]
- [ ] [Skill 2]
- [ ] [Skill 3]
- [ ] [Skill 4]
- [ ] [Skill 5]

**Score yourself**: 4+/5 = Ready | 3/5 = Review | <3/5 = Practice

---

[⬅️ Previous Module](...) | [Next Module](...) ➡️
"""

        if output_path:
            output_path.write_text(template)
            logger.info(f"✅ Template saved to: {output_path}")
        
        return template


def scan_directory(base_dir: Path) -> List[ReadmeAnalysis]:
    """Scan directory for README files and analyze them."""
    logger.info(f"🔍 Scanning: {base_dir}")
    
    readme_files = list(base_dir.rglob('README.md'))
    analyses = []
    
    for readme_path in readme_files:
        try:
            enhancer = ReadmeEnhancer(readme_path)
            analysis = enhancer.analyze()
            analyses.append(analysis)
        except Exception as e:
            logger.error(f"Failed to analyze {readme_path}: {e}")
    
    return analyses


def generate_priority_report(analyses: List[ReadmeAnalysis]) -> str:
    """Generate priority report for enhancement."""
    # Sort by missing sections (most missing first)
    def priority_score(a: ReadmeAnalysis) -> int:
        missing = sum([
            not a.has_toc,
            not a.has_diagrams,
            not a.has_scenarios,
            not a.has_exercises,
            not a.has_interview_prep,
            not a.has_knowledge_check
        ])
        return (missing * 1000) + a.estimated_enhancement
    
    sorted_analyses = sorted(analyses, key=priority_score, reverse=True)
    
    report = []
    report.append("\n" + "="*80)
    report.append("📊 README ENHANCEMENT PRIORITY REPORT")
    report.append("="*80)
    report.append(f"\nTotal READMEs Found: {len(analyses)}\n")
    
    for i, a in enumerate(sorted_analyses[:20], 1):  # Top 20
        missing = sum([
            not a.has_toc,
            not a.has_diagrams,
            not a.has_scenarios,
            not a.has_exercises,
            not a.has_interview_prep,
            not a.has_knowledge_check
        ])
        
        priority = "🔴" if missing >= 4 else "🟡" if missing >= 2 else "🟢"
        
        report.append(f"{i:2d}. {priority} {a.path.parent.name}/{a.path.name}")
        report.append(f"    Lines: {a.current_lines} | Missing: {missing}/6 sections | Gap: +{a.estimated_enhancement} lines")
    
    report.append("\n" + "="*80)
    return "\n".join(report)


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='README Enhancement Automation Tool'
    )
    
    parser.add_argument(
        'path',
        type=Path,
        help='Path to README file or directory to scan'
    )
    
    parser.add_argument(
        '--analyze',
        action='store_true',
        help='Analyze README(s) and show gaps'
    )
    
    parser.add_argument(
        '--template',
        action='store_true',
        help='Generate enhancement template'
    )
    
    parser.add_argument(
        '--scan',
        action='store_true',
        help='Scan directory and generate priority report'
    )
    
    parser.add_argument(
        '--output',
        type=Path,
        help='Output path for template'
    )
    
    args = parser.parse_args()
    
    try:
        if args.scan:
            # Scan directory
            analyses = scan_directory(args.path)
            report = generate_priority_report(analyses)
            print(report)
            
            # Save report
            report_path = args.path / 'ENHANCEMENT_PRIORITY_REPORT.txt'
            report_path.write_text(report)
            logger.info(f"✅ Report saved to: {report_path}")
            
        elif args.path.is_file():
            # Single file operations
            enhancer = ReadmeEnhancer(args.path)
            
            if args.analyze:
                enhancer.print_analysis()
            
            if args.template:
                output = args.output or args.path.parent / f"{args.path.stem}_TEMPLATE{args.path.suffix}"
                enhancer.generate_template(output)
        
        else:
            logger.error(f"Path must be a README file or use --scan for directories")
            sys.exit(1)
        
    except Exception as e:
        logger.error(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
