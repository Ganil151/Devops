# 🛠️ Data Processing Challenges

## Challenge 1: The Config Parser
You have a set of environments: `DEV`, `QA`, `PROD`.
1.  Use an **Associative Array** to map each environment to a mock DB connection string.
    - DEV -> `db_dev_user:pass`
    - QA  -> `db_qa_user:pass`
    - PROD -> `db_prod_secure:SECRET`
2.  Also create a standard array of environments to loop through.
3.  Loop through the standard array, look up the connection string in the Associative Array, and print it.

## Challenge 2: Unique Counter
Read a list of names from a file (generate one with duplicates).
Using an associative array, count the occurrences of each name.
Output formatted as: `Name: Count`.
(Hint: Use the name as the key and increment the value).
