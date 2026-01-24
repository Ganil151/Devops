# 🛠️ Data Processing Challenges

## Challenge 1: Log Aggregation Report
**Objective**: Parse regex logs into a DataFrame.
1.  Read access logs.
2.  Extract `IP`, `Status`, `Bytes`.
3.  Create DataFrame `pd.DataFrame(data)`.
4.  Calculate Total Bytes transferred per IP.
5.  Export to Excel `to_excel()`.

## Challenge 2: Cloud Cost Analysis
**Objective**: Analyze a Billing CSV.
1.  CSV: `Service, Region, Cost`.
2.  Filter for `Region == 'us-east-1'`.
3.  GroupBy `Service` and Sum `Cost`.
4.  Sort by Cost descending.
5.  Print the Top 3 most expensive services.
