# ☁️ Cloud & Networking: Scripting the Infrastructure

> **"The Network is the computer. In DevOps, your script is rarely local. It's calling an API in Virginia, SSHing to a server in Frankfurt, and pushing data to a bucket in Tokyo."**

This reference covers the libraries for Remote Execution and API Interaction.

---

## 🐍 1. AWS SDK (`boto3`)

The standard for AWS Automation.

### Client vs Resource
- **Client**: Low-level, maps 1:1 to API. returns Dicts. Fast.
- **Resource**: OO abstraction. returns Objects. Slower.
- **Staff Choice**: Use **Clients** for scripts (speed/completeness). Use **Resources** for simple logic.

### Paginators (Handling > 1000 items)
AWS APIs truncate lists at 1000.
```python
client = boto3.client('s3')
paginator = client.get_paginator('list_objects_v2')

for page in paginator.paginate(Bucket='my-bucket'):
    for obj in page['Contents']:
        print(obj['Key'])
```

### Waiters (Blocking for State)
Don't write `time.sleep()`. Let Boto3 poll for you.
```python
ec2 = boto3.client('ec2')
instance = ec2.run_instances(...)['Instances'][0]

waiter = ec2.get_waiter('instance_running')
waiter.wait(InstanceIds=[instance['InstanceId']]) # Blocks until Running
```

---

## 🌐 2. HTTP Requests (`requests`)

The "Human" HTTP library.

### Session Objects (Performance)
Reuses TCP connections (Keep-Alive) -> 2x Speed boost.
```python
s = requests.Session()
s.headers.update({'Authorization': 'Bearer token'})

# Both calls reuse the same socket
s.get('https://api.com/v1/users')
s.get('https://api.com/v1/posts')
```

### Retry Logic (Resilience)
Handle hiccups automatically.
```python
from requests.adapters import HTTPAdapter

adapter = HTTPAdapter(max_retries=3)
s = requests.Session()
s.mount('https://', adapter) # Auto-retry on 500/502/Network Error
```

---

## 🔑 3. SSH Automation (`paramiko` & `asyncssh`)

### Paramiko (Standard)
```python
import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.RejectPolicy()) # Security

client.connect('10.0.0.1', username='admin', key_filename='key.pem')
stdin, stdout, stderr = client.exec_command('uptime')
print(stdout.read().decode())
```

### AsyncSSH (High Scale)
Run 100 SSH connections in parallel using Python `asyncio`.
```python
import asyncssh, asyncio

async def run_cmd(host):
    async with asyncssh.connect(host) as conn:
        await conn.run('sudo reboot')

asyncio.run(asyncio.gather(run_cmd('h1'), run_cmd('h2')))
```

---

## 🕸️ 4. Web Scraping (`playwright`)

For monitoring sites without APIs (SPAs/React).

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("http://site.internal")
    page.click("#login-button")
    page.screenshot(path="evidence.png")
```

---

[⬅️ Back to Reference Hub](./README.md)
