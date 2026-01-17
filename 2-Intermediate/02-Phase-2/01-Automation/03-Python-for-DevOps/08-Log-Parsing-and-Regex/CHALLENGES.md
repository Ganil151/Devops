# 🛠️ Regex Challenges

## Challenge 1: Log Analyzer
**Objective**: Parse a real Access Log.
1.  Read a file line by line.
2.  Use Regex `r'(\d{1,3}\.){3}\d{1,3}'` to find IPs.
3.  Count the requests per IP.
4.  Identify IPs with > 5 requests.
5.  Print them as "Suspicious: {ip}".

## Challenge 2: Email Extractor
**Objective**: Scrape a text block for emails.
1.  Text: "Contact support@example.com or sales@test.co.uk for help."
2.  Pattern: `r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'`.
3.  Use `re.findall()`.
4.  Return a unique list (Set) of emails found.

## Challenge 3: Error Grouper
**Objective**: Group errors by type.
1.  Log: `Error: [Database] Timeout`, `Error: [Network] Reset`, `Error: [Database] Connection Refused`.
2.  Pattern: `r'\[(.*?)\]'`.
3.  Count occurrences of "Database" vs "Network".
