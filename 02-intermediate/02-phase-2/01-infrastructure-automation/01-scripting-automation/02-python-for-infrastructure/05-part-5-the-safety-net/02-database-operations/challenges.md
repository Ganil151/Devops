# 🛠️ Database Challenges

## Challenge 1: The Migration Script
**Objective**: Parse a CSV and insert into DB.
1.  CSV: `hostname,ip,role`.
2.  Table: `id, hostname, ip, role`.
3.  Read CSV using `csv` module.
4.  Insert into SQLite using `executemany` (Performance optimization).

## Challenge 2: Query Exporter
**Objective**: Dump a table to JSON.
1.  Connect to DB.
2.  `SELECT * FROM inventory`.
3.  Convert rows to list of Dicts.
4.  Dump to `export.json`.

## Challenge 3: State Reconciler
**Objective**: Delete old records.
1.  Accept a list of "Active Hostnames" from API.
2.  SELECT all hostnames from DB.
3.  Find hostnames in DB that are NOT in the Active list.
4.  DELETE them.
