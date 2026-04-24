# 🛠️ Maturity Model Challenges

## Challenge 1: The Audit
**Objective**: Take a legacy script (or write a quick one that just deletes files) and audit it using the `maturity_scorecard.txt`.
1.  Identify what level it is currently.
2.  List 3 specific things you would need to add to reach Level 4.

## Challenge 2: The Level 3 Transition
**Objective**: Hardcoding Removal.
1.  Write a script that creates a file in `/tmp/mydata`.
2.  Instead of hardcoding `/tmp/mydata`, modify the script to take the directory path as a command line argument.
3.  Add a check: `if not os.path.isabs(path): fail`.
4.  This moves your script from Level 2 to Level 3.
