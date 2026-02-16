# 🎯 Pathlib: Modern Navigation Challenges

> **"If you are still using os.path, you are driving with a paper map. These challenges test your ability to use GPS (Pathlib) for high-speed file system automation."**

---

## 🏆 Challenge 1: The Log Cleanup
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Delete all `.tmp` files in a given directory that are older than 7 days.

### Requirements
- Ask the user for a directory path.
- Loop through all `.tmp` files using `glob`.
- Check the modification time.
- Print "Deleting: <filename>" for each match.

### Hints
- Use `path.glob("*.tmp")`.
- Use `f.stat().st_mtime`.

---

## 🏆 Challenge 2: The Project Manifest
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 30 minutes

### Objective
Create a script that lists every Python file in a project and calculates the total line count.

### Requirements
- **Recursively** find all `.py` files inside the current work directory.
- Exclude files in `.venv` or `__pycache__` folders.
- Open each file, count lines, and keep a running total.
- Print a summary: `Found 42 files | Total Lines: 12,450`.

### Hints
- Use `path.rglob("*.py")`.
- Use `path.parts` or `str(path)` to check for excluded folders.

---

## 🏆 Challenge 3: The Safe Backup (Atomic Pattern)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 45 minutes

### Objective
Move all files from a `source/` folder to a `backup/` folder, ensuring no data is overwritten by naming collisions.

### Requirements
- If `backup/file.txt` already exists, rename the new one to `file.txt.backup_1`.
- If `_1` exists, increments to `_2`, etc.
- Use `path.exists()` and `path.rename()`.
- Ensure the `backup/` directory is created if it doesn't exist.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Log Cleanup
- [ ] Challenge 2: Project Manifest
- [ ] Challenge 3: Safe Backup
