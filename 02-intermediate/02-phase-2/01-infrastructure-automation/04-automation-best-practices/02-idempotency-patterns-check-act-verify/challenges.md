# 🛠️ Idempotency Challenges

## Challenge 1: The Safe Folder Creator
**Objective**: Build a script that creates a complex directory structure once.
1.  Target: `project/logs`, `project/config`, `project/bin`.
2.  Use `os.path.exists`.
3.  If a directory exists, print "SKIPPING: {name}".
4.  If not, create it and print "CREATED: {name}".
5.  **Test**: Run it three times. Only the first run should show "CREATED".

## Challenge 2: The Symlink Shifter
**Objective**: Ensure a symlink points to the correct target.
1.  Local file: `v1.txt`.
2.  Symlink: `current`.
3.  Task: If `current` points to `v1.txt`, do nothing. If it points elsewhere (or doesn't exist), update it.
4.  Use `os.readlink()` and `os.symlink()`.

## Challenge 3: JSON Config Patcher
**Objective**: Update a key in a JSON file without duplicating it.
1.  `config.json`: `{"version": "1.0", "status": "dev"}`.
2.  Goal: Ensure `"status": "prod"`.
3.  Logic: Read JSON -> Check if "status" is already "prod" -> If not, update and save.
