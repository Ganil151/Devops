# Data Processing with Pandas

DevOps generates HUGE status reports. Pandas is the Excel of Python. It allows you to process millions of rows of CSV/JSON data in seconds.

## 📚 Module Structure
- **[Boilerplates](./Boilerplates/)**: `report_gen.py` (GroupBy and Sum).
- **[CHALLENGES](./CHALLENGES.md)**: Cost Analysis, Log Aggregations.

---

## 🔑 Key Concepts

| Concept | Description |
| :--- | :--- |
| **DataFrame** | A table of data (Rows and Columns). |
| **Series** | A single column. |
| **read_csv** | Easiest way to load data. |
| **GroupBy** | "Split-Apply-Combine" logic (Pivot tables). |

---

## 🏗️ Robust Patterns

### 1. Vectorization
Don't loop over rows! It's slow.

```python
# SLOW
for index, row in df.iterrows():
    df.at[index, 'cost'] = row['cost'] * 1.2

# FAST (Vectorized)
df['cost'] = df['cost'] * 1.2
```

---

## 📖 Real-World Story: The "Excel Killer"

**Problem**: The Finance team spent 3 days/month manually merging CSVs from AWS, Azure, and GCP to calculate total spend.
**Solution**: A Python script using Pandas read all 50 CSVs, normalized the column names, and output a single "Global_Spend.xlsx".
**Result**: Process time reduced from 3 days to 10 seconds.

---

## ❓ Interview Questions

1.  **Why Pandas instead of `csv` module?**
    - *Answer*: Pandas handles types (int, float) automatically, supports missing data (NaN), and allows SQL-like operations (Join, GroupBy) which are hard to write in pure Python.
2.  **How do you handle missing data?**
    - *Answer*: `df.fillna(0)` or `df.dropna()`.
3.  **Can Pandas read directly from SQL?**
    - *Answer*: Yes, `pd.read_sql(query, connection)`.

---

[Next: Capstone Project](../14-Capstone-Project-S3-Auditor/README.md)
