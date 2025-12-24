# Flask - Python Micro-Framework

Flask is a **micro-framework** for Python. It is called "micro" because it doesn't require particular tools or libraries, keeping the core extensible.

## Why Flask for DevOps?
- **Lightweight**: Perfect for small internal tools and microservices.
- **Fast Prototyping**: Go from zero to a running API in minutes.
- **Native Python**: Leverages the power of Python's ecosystem.

> [!IMPORTANT]
> Always use a **[Virtual Environment](../Environment-Setup.md)** before installing Flask.

---

## 1. Core Concepts

### Basic Application
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
```

### Routing & Request Handling
Flask uses decorators to map URLs to Python functions.
```python
@app.route('/user/<username>')
def show_user_profile(username):
    return f'User {username}'

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        return do_the_login()
    else:
        return show_the_login_form()
```

---

## 2. DevOps & Production Setup

In development, Flask's built-in server is fine. In **production**, you MUST use a WSGI server like **Gunicorn**.

### Project Structure
```text
myapp/
├── app/
│   ├── main.py
│   └── templates/
├── requirements.txt
└── Dockerfile
```

### Dockerizing Flask
```dockerfile
# Use official lightweight Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Run Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.main:app"]
```

---

## 3. Quiz: Flask Knowledge

1. What is Flask specifically known as?
   - a) Full-stack framework
   - b) Micro-framework
   - c) Database engine
   - d) Static site generator

2. Which library is commonly used as a Production WSGI server for Flask?
   - a) Apache
   - b) Django
   - c) Gunicorn
   - d) Nginx

3. Which decorator is used to define a route in Flask?
   - a) `@route`
   - b) `@app.route`
   - c) `@flask.path`
   - d) `@url`

*(Answers: 1:b, 2:c, 3:b)*

---

**[← Back to Web Design](../README.md)**
