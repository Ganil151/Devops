# 📊 Data Manipulation: Transforming Chaos into Logic

> **"Data in DevOps is rarely clean. It is a stream of unstructured logs, nested JSONS, and messy CSVs. Your job is to normalize it."**

This reference covers the tools for parsing, extracting, and aggregating data.

---

## 📄 1. Structured Data (JSON / YAML)

The lingua franca of Cloud Configurations.

| Keyword | Library | Use Case | Example |
| :--- | :--- | :--- | :--- |
| `json.load()` | `json` | Read file object. | `data = json.load(f)` |
| `json.loads()` | `json` | Read string. | `data = json.loads(api_response)` |
| `json.dump()` | `json` | Write to file. | `json.dump(data, f, indent=2)` |
| `yaml.safe_load()` | `PyYAML` | Read YAML safely. | `data = yaml.safe_load(f)` |

**Staff Pattern (Safe Modification)**:
```python
import json
# Modify a nested value safely
with open("config.json", "r+") as f:
    data = json.load(f)
    data["database"]["port"] = 5432
    f.seek(0)
    json.dump(data, f, indent=4)
    f.truncate()
```

---

## 🐼 2. High-Performance Analysis (Pandas)

For datasets > 10MB or complex aggregations (FinOps).

| Method | Description | Staff Tip |
| :--- | :--- | :--- |
| `pd.read_csv()` | Load CSV to DataFrame. | Use `chunksize=1000` for huge files. |
| `df.groupby()` | Split-Apply-Combine. | `df.groupby('Service')['Cost'].sum()` |
| `df.fillna()` | Handle missing data. | `df.fillna(0)` prevents math errors. |
| `pd.to_datetime()`| Intelligent date parsing. | Essential for Time Series analysis. |
| `df.to_parquet()` | Binary export. | 10x faster/smaller than CSV. |

**Staff Pattern (Vectorization)**:
```python
# BAD: Loop
for i in df.index:
    df.at[i, 'total'] = df.at[i, 'a'] + df.at[i, 'b']

# GOOD: Vectorized Operation (C-Speed)
df['total'] = df['a'] + df['b']
```

---

## 🔍 3. Text Extraction (Regex `re`)

When data is unstructured (Logs, Config files).

| Flag / Pattern | Meaning | Example |
| :--- | :--- | :--- |
| `re.search()` | Find first match anywhere. | `re.search(r'Error: \d+', log)` |
| `re.findall()` | Find all matches as list. | `re.findall(r'\d{1,3}\.\d+', log)` |
| `(?P<name>...)` | Named Group. | `r'(?P<ip>\d+\.)'` |
| `re.VERBOSE` | Allow comments in pattern. | Makes complex regex readable. |

**Staff Pattern (Compiled & Named)**:
```python
import re

# Compile once, use many times
LOG_PATTERN = re.compile(r"""
    ^\[(?P<level>INFO|ERROR)\]  # Capture Level
    \s
    (?P<msg>.*)$                # Capture Message
""", re.VERBOSE)

match = LOG_PATTERN.search("[ERROR] DB Down")
if match:
    print(match.group('level')) # 'ERROR'
```

---

## 🔢 4. Collections (`collections`)

Built-in high-performance containers.

- **`Counter`**: Instant frequency counting.
    ```python
    from collections import Counter
    ips = ["1.1.1.1", "1.1.1.1", "8.8.8.8"]
    print(Counter(ips)) # {'1.1.1.1': 2, ...}
    ```
- **`defaultdict`**: No more `KeyError`.
    ```python
    from collections import defaultdict
    groups = defaultdict(list)
    groups['web'].append('server-1') # Auto-initializes list
    ```

---

[⬅️ Back to Reference Hub](./README.md)
