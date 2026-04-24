# Amazon DynamoDB Getting Started - Hands-On Guide

## Introduction

This hands-on guide walks you through creating your first Amazon DynamoDB table. You'll learn how to create a table, insert items, perform queries, and clean up your resources.

## What You'll Build

A **Music Library** table where you can store and query songs by Artist and Song Title.

```
Table Name: Music
Partition Key: Artist (String)
Sort Key: SongTitle (String)
```

## Prerequisites

- AWS Account
- AWS CLI installed and configured
- Minimal cost (Free Tier eligible)

---

## Step 1: Create a Table

### Option 1: Using AWS Console

1.  Navigate to **DynamoDB** in the AWS Console.
2.  Click **Create table**.
3.  **Table details**:
    - Table name: `Music`
    - Partition key: `Artist` (String)
    - Sort key: `SongTitle` (String)
4.  **Table settings**:
    - Select **Customize settings**.
    - Capacity mode: **On-demand** (Best for learning).
5.  Click **Create table**.

### Option 2: Using AWS CLI

```bash
aws dynamodb create-table \
    --table-name Music \
    --attribute-definitions \
        AttributeName=Artist,AttributeType=S \
        AttributeName=SongTitle,AttributeType=S \
    --key-schema \
        AttributeName=Artist,KeyType=HASH \
        AttributeName=SongTitle,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST
```

---

## Step 2: Add Items (Write)

Let's add some songs to our library.

### Using AWS CLI

```bash
# Add Song 1
aws dynamodb put-item \
    --table-name Music \
    --item \
        '{"Artist": {"S": "The Beatles"}, "SongTitle": {"S": "Hey Jude"}, "Album": {"S": "The Beatles"}, "Year": {"N": "1968"}}'

# Add Song 2
aws dynamodb put-item \
    --table-name Music \
    --item \
        '{"Artist": {"S": "The Beatles"}, "SongTitle": {"S": "Let It Be"}, "Album": {"S": "Let It Be"}, "Year": {"N": "1970"}}'

# Add Song 3 (Different Artist)
aws dynamodb put-item \
    --table-name Music \
    --item \
        '{"Artist": {"S": "Queen"}, "SongTitle": {"S": "Bohemian Rhapsody"}, "Album": {"S": "A Night at the Opera"}, "Year": {"N": "1975"}}'
```

---

## Step 3: Read Data

### 1. Get a Single Item (GetItem)
Retrieve a specific song. You must provide BOTH the Partition Key and Sort Key.

```bash
aws dynamodb get-item \
    --table-name Music \
    --key \
        '{"Artist": {"S": "The Beatles"}, "SongTitle": {"S": "Hey Jude"}}'
```

### 2. Query Items (Query)
Find all songs by "The Beatles". This is efficient because it uses the Partition Key.

```bash
aws dynamodb query \
    --table-name Music \
    --key-condition-expression "Artist = :a" \
    --expression-attribute-values '{":a": {"S": "The Beatles"}}'
```

### 3. Scan All Items (Scan)
Retrieve EVERYTHING in the table. Use carefully!

```bash
aws dynamodb scan --table-name Music
```

---

## Step 4: Cleanup (Important!)

Delete the table to avoid accumulating resources, although On-Demand tables with no data/storage cost very little.

```bash
aws dynamodb delete-table --table-name Music
```

---
<br>

# 🌟 Real-World Scenarios

### Scenario 1: The "Hot" Partition
**Situation**: You designed a Voting App where users vote for their favorite candidate. You used `CandidateName` as the Partition Key.
**Problem**: One candidate is extremely popular, receiving 90% of the votes. That partition becomes "hot" and throttles, while other partitions are idle.
**Solution**:
1.  **Write Sharding**: Append a random suffix (1-10) to the Partition Key (e.g., `CandidateA_1`, `CandidateA_2`).
2.  **Reads**: You must query all 10 shards (`CandidateA_1`...`10`) and aggregate the results to get the total count.
3.  **Result**: Writes are distributed evenly across 10 partitions, eliminating the bottleneck.

### Scenario 2: Expiring OTP Codes
**Situation**: You are sending One-Time Passwords (OTPs) via SMS. You store them in DynamoDB.
**Requirement**: The OTP must be invalid after 5 minutes.
**Solution**:
1.  **TTL**: Add an attribute `ExpirationTime` (Current Time + 300 seconds).
2.  **Enable TTL**: Configure the table to use `ExpirationTime` as the TTL attribute.
3.  **Result**: DynamoDB automatically deletes the expired OTPs without you running a cleanup script.

---

# 🧠 Knowledge Quiz

<b>1. Which command retrieves items based on the Primary Key?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - `get-item` retrieves a single item using its full primary key. `query` retrieves a collection of items sharing the same Partition Key.
</details>




<b>2. You want to store a JSON object in a DynamoDB attribute. Which data type should you use?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - The Map (M) data type allows nesting of JSON-like sub-documents.
</details>




<b>3. What happens if you try to `PutItem` with the same Primary Key as an existing item?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - By default, `PutItem` replaces the entire item. You can use `ConditionExpression` to prevent this if needed.
</details>




<b>4. Which API operation is the most expensive in terms of Read Capacity Units?</b>
<details>
<summary>Show Answer</summary>
Answer: C** - `Scan` reads every item in the table, consuming capacity for the entire dataset size.
</details>




<b>5. How are On-Demand write costs calculated?</b>
<details>
<summary>Show Answer</summary>
Answer: B** - You pay for every write request (1 KB chunk).
</details>



