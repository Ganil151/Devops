import os
import re

file_path = r"C:\Users\Ganil\Documents\Devops\1-Beginner\02-Phase-2\01-Automation\02-Python-Basics\PYTHON_AUTOMATION_MASTER_INDEX.md"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix the Part-X/Module-X structure
# Pattern: \.\/Part-[0-9]-.*?\/([0-9]{2}-.*?\/README\.md)
# Replacement: ./Part-\1
new_content = re.sub(r'\.\/Part-[0-9]-.*?\/([0-9]{2}-.*?\/README\.md)', r'./Part-\1', content)

# 2. Fix the Professional Standards Topical Extras
# Case: [Working with the Web](./Part-4-Professional-Standards/99-Topical-Extras/01-Working-with-the-Web.md)
# Should become [Working with the Web](./Part-18-Working-with-the-Web/README.md)
new_content = new_content.replace("./Part-4-Professional-Standards/99-Topical-Extras/01-Working-with-the-Web.md", "./Part-18-Working-with-the-Web/README.md")
new_content = new_content.replace("./Part-4-Professional-Standards/99-Topical-Extras/02-Web-Automation.md", "./Part-19-Web-Automation/README.md")
new_content = new_content.replace("./Part-4-Professional-Standards/99-Topical-Extras/03-Micro-Frameworks-and-Async.md", "./Part-20-Micro-Frameworks-and-Async/README.md")

# 3. Fix the path typo
new_content = new_content.replace("02-Phase-2/02-Automation/02-Python-Basics", "02-Phase-2/01-Automation/02-Python-Basics")

if content != new_content:
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Updated: {file_path}")
