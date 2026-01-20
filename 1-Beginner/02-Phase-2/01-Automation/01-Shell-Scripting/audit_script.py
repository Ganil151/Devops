import os

target_dir = r"C:\Users\Ganil\Documents\Devops\1-Beginner\02-Phase-2\01-Automation\01-Shell-Scripting"
required_sections = [
    "## 📚 Overview",
    "## 🎓 Learning Objectives",
    "## 🚀 Professional Patterns for Automation",
    "## 🏆 Real-World DevOps Story",
    "## ❓ Interview Preparation",
    "## 📝 Knowledge Check"
]

report = []

print(f"Auditing directories in: {target_dir}")
print("-" * 60)

for item in os.listdir(target_dir):
    item_path = os.path.join(target_dir, item)
    if os.path.isdir(item_path) and item[0].isdigit(): # Only check numbered folders 01-18
        readme_path = os.path.join(item_path, "README.md")
        
        if not os.path.exists(readme_path):
            report.append(f"❌ {item}: MISSING README.md")
            continue

        with open(readme_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        missing = []
        for section in required_sections:
            if section not in content:
                missing.append(section.replace("## ", "").strip())
        
        if not missing:
            report.append(f"✅ {item}: Meets Standard")
        else:
            report.append(f"⚠️  {item}: Missing Sections -> {', '.join(missing)}")

with open("audit_report_final.md", "w", encoding="utf-8") as f:
    f.write("# Audit Report\n\n")
    for line in report:
        f.write(line + "\n")
        print(line)
