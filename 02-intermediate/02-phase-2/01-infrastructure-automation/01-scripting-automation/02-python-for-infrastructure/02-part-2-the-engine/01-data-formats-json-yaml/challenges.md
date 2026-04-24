# 🛠️ Data Wrangling Challenges

## Challenge 1: JSON Validator
**Objective**: Validate a list of user objects.
1.  Sample Data: `[{"user": "alice", "age": 30}, {"user": "bob"}]` (Bob is missing age).
2.  Iterate through the list.
3.  Check if required keys (`user`, `age`) exist.
4.  If missing, print `Warning: User {name} matches incomplete schema`.
5.  Print the count of valid users.

## Challenge 2: YAML to JSON Converter
**Objective**: Build a CLI tool `yaml2json.py`.
1.  Accept a filename as an argument.
2.  Detect if it is `.yaml` or `.yml`.
3.  Load it using `PyYAML`.
4.  Dump it as JSON to `stdout` with `indent=2`.
5.  Handle errors (file not found, invalid syntax).

## Challenge 3: Inventory Diff
**Objective**: Compare two server lists (Sets).
1.  `dev_servers = {"web-01", "web-02", "db-01"}`
2.  `prod_servers = {"web-01", "web-02", "db-02"}`
3.  Find servers present in Dev but not Prod.
4.  Find servers present in both (Intersection).
