# 🛠️ JQ Challenges

## Challenge 1: The User Filter
You have a JSON file `users.json`:
```json
[
  { "username": "alice", "roles": ["admin", "dev"], "active": true },
  { "username": "bob", "roles": ["dev"], "active": false },
  { "username": "charlie", "roles": ["viewer"], "active": true }
]
```

**Task**: Write a `jq` command to find all **active** users who have the **admin** role.
*Hint*: Use `select(.active == true)` and `select(.roles | contains(["admin"]))`.

## Challenge 2: CSV Converter
Convert the `users.json` above into a CSV format: `username,role_count`.
*Output example*:
```csv
alice,2
bob,1
charlie,1
```
