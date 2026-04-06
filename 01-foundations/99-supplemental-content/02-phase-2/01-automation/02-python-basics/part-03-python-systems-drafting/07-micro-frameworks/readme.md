# ⚡ Micro-Frameworks: The Service Provider

> **"In DevOps, you don't always need a massive enterprise server. Sometimes you just need a 10-line Webhook receiver that can handle 10,000 requests a second without breaking a sweat."**

![FastAPI vs Flask](../05-working-with-the-web/web-api-demo.py)

---

## 🧠 The Mental Model: The Listener

**The Junior Struggle**: "I have a script that automates deployment. How do I make it run when someone pushes to GitHub?"

**The Engineer Solution**: Wrap your script in a **Micro-Framework**.
This turns your "Offline Script" into an "Online Service" (API) that listens for incoming signals (Webhooks) from the outside world.

### 🏗️ The Infrastructure Analogy

| Concept | Python Script | Microservice (API) |
|:--------|:--------------|:-------------------|
| **Trigger** | You typing `python run.py` | GitHub sending a `POST` request |
| **Input** | CLI Arguments | JSON Payload |
| **Output** | Printed text on screen | JSON Response (Status 200) |
| **Availability** | Only when you are at keyboard | 24/7/365 |

**The Key Insight**: A Micro-Framework is just a "translation layer" that turns HTTP requests into Python function calls.

---

## 📚 Why This Module Matters for Juniors

**Before this module**, you might think:
- "Building a web server takes weeks"
- "I need Django or Rails"
- "I can't parse JSON from a request"

**After this module**, you'll understand:
- **FastAPI** creates production-ready APIs in 5 lines of code.
- **Webhooks** are the glue of modern DevOps.
- **Async** allows your script to handle thousands of requests.
- **Swagger UI** (Automatic Documentation) documents your tool for free.

**The Difference**: Your tools become accessible to your entire team (and other robots).

---

## 🎯 Learning Objectives

By the end of this module, you will:

- ✅ **Master FastAPI**: The modern standard for Python APIs.
- ✅ **Build a Webhook Receiver**: Trigger actions from GitHub/Slack.
- ✅ **Validate Data**: Use Pydantic models to reject bad inputs.
- ✅ **Understand Async**: Handle concurrency efficiently.
- ✅ **Deploy**: Run your API with `uvicorn`.

---

## 🏗️ Part 1: The Modern Standard (FastAPI)

### 🧠 The Mental Model: Heavy Lifting, Light Code

**The Shift**: We used to use Flask. Now we use **FastAPI**.
Why? Speed, Auto-Validation, and Auto-Documentation.

### 🔧 The "Hello World" API

```python
# pip install fastapi uvicorn
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "Online", "service": "DevOps-Bot"}

@app.get("/health")
def health_check():
    return {"cpu": "Low", "memory": "Ok"}

# Run with: uvicorn main:app --reload
```

---

## 🚀 Part 2: The Webhook Receiver (POST)

### 🧠 The Mental Model: The Guarded Gate

**The Use Case**: GitHub sends a notification (JSON) whenever code is pushed. You want to receive it and trigger a test suite.

**The Problem**: The internet is dangerous. You need to validate that the data is correct before acting.

### 🔧 Pydantic Models for Validation

```python
from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel

app = FastAPI()

# 1. Define the Expected Data Shape
class DeploymentRequest(BaseModel):
    service_name: str
    image_tag: str
    replicas: int = 1  # Default value

# 2. Build the Endpoint
@app.post("/deploy")
async def trigger_deployment(
    payload: DeploymentRequest, 
    x_token: str = Header(None) # Read Custom Header
):
    # Security Check
    if x_token != "Secret-Deploy-Key-123":
        raise HTTPException(status_code=401, detail="Invalid Token")

    # Business Logic
    print(f"🚀 Deploying {payload.service_name}:{payload.image_tag}")
    
    return {
        "status": "Deployment Started", 
        "target": payload.service_name
    }
```

**What just happened?**
1. FastAPI automatically validated that `replicas` is an `int`. If the user constructs a bad request, they get a detailed error message automatically.
2. It checked the `x_token` header for security.
3. It returned a structured JSON response.

---

## ⚡ Part 3: Asynchronous Performance

### 🧠 The Mental Model: The Short Order Cook

**Synchronous (Flask)**: One waiter. Takes order, walks to kitchen, waits for food, returns. Line builds up.
**Asynchronous (FastAPI)**: One waiter. Takes order, sends to kitchen, immediately takes *next* order. Kitchen notifies waiter when done.

### 🔧 Async Endpoints

```python
import asyncio

@app.post("/long-task")
async def run_audit():
    # 💡 "await" pauses THIS function, but lets the server handle other users!
    await asyncio.sleep(5) 
    return {"result": "Audit Complete"}
```

**Why it matters**: In DevOps, tasks are slow (waiting for AWS, waiting for Db). Async lets your single server handle 10,000 requests while waiting for those slow tasks.

---

## 🏆 Real-World DevOps Story: The 10-Minute Disaster Recovery

**The Scenario**: A major outage required running a specific "Restart Sequence" (15 commands) on the database cluster. The documentation was a wiki page.

**The Problem**: During an outage, engineers were stressed and made typos. The recovery took 30 minutes.

**The Solution**: A Senior Engineer bundled the 15 commands into a Python function and exposed it via **FastAPI** on an internal server.
`POST /emergency/restart-db`

**The Outcome**: During the next outage, the On-Call Engineer just clicked a button in their dashboard that hit this endpoint. Recovery time dropped from 30 minutes to **45 seconds**. Typos were impossible.

---

## ❓ Interview Preparation (APIs)

### 🎯 Core Concepts

1. **Q: Flask vs FastAPI?**
   - *A: Flask is mature and simple but slower and lacks built-in validation. FastAPI is modern, very fast (based on Starlette/Pydantic), supports Async native, and generates automatic Swagger docs.*

2. **Q: What is a Webhook?**
   - *A: A "Reverse API". Instead of you polling a server ("Do you have data?"), the server calls YOU ("Here is new data") via a POST request.*

3. **Q: Why use Pydantic models?**
   - *A: They ensure data integrity. If an API client sends a string "three" instead of integer `3`, Pydantic catches it immediately, preventing your code from crashing later.*

4. **Q: What is Swagger/OpenAPI?**
   - *A: A standard specification for describing APIs. FastAPI generates an interactive UI (`/docs`) automatically, letting developers test endpoints in the browser.*

5. **Q: How do you serve a FastAPI app?**
   - *A: Use an ASGI server like `uvicorn` or `hypercorn`. (e.g., `uvicorn main:app`).*

### 🚀 Advanced Questions

6. **Q: What does `async def` do?**
   - *A: Defines a coroutine. It allows the use of `await` to yield control back to the event loop, enabling non-blocking concurrency.*

7. **Q: How do you handle CORS (Cross-Origin Resource Sharing)?**
   - *A: Use `FastAPI.middleware.cors`. Essential if your API is called from a frontend hosted on a different domain.*

8. **Q: Status Code 201 vs 200?**
   - *A: 200 is generic "OK". 201 is "Created" (result of a successful POST).*

9. **Q: What is Dependency Injection in FastAPI?**
   - *A: A system to declare things your endpoints need (like Database sessions or User objects). FastAPI provides them automatically (`Depends()`).*

10. **Q: How do you test a FastAPI app?**
    - *A: Use `TestClient` from `fastapi.testclient` (wraps `httpx`) inside standard `pytest` functions.*

---

## 📝 Knowledge Check

### 🧠 Beginner Level

1. **Which HTTP method is used for Webhooks?**
   - [ ] a) GET
   - [x] b) POST
   - [ ] c) DELETE

2. **What url triggers automatic documentation?**
   - [ ] a) `/help`
   - [x] b) `/docs`
   - [ ] c) `/schema`

3. **What creates a data validation model?**
   - [ ] a) `class Model(object):`
   - [ ] b) `@dataclass`
   - [x] c) `class Model(pydantic.BaseModel):`

### 🚀 Intermediate Level

4. **How do you read a Query Parameter `?limit=10`?**
   - [x] a) Define it as a function argument: `def list(limit: int = 10):`
   - [ ] b) `request.args.get('limit')`
   - [ ] c) `sys.argv`

5. **What waits for an async operation?**
   - [ ] a) `wait`
   - [ ] b) `yield`
   - [x] c) `await`

6. **What is `uvicorn`?**
   - [ ] a) A database
   - [x] b) An ASGI Web Server
   - [ ] c) A linter

### 🏆 Advanced Level

7. **How do you access a Header named `X-Token`?**
   - [x] a) Argument `x_token: str = Header(...)`
   - [ ] b) `request.header['X-Token']`
   - [ ] c) It's impossible

8. **What happens if a required field is missing in the JSON payload?**
   - [x] a) FastAPI returns 422 Unprocessable Entity
   - [ ] b) Python raises KeyError
   - [ ] c) The values are None

---

## 🎯 Key Takeaways for Juniors

### 🧠 Mental Models Over Syntax

1. **Listener**: The script waits for the world to talk to it.
2. **Validator**: Trust nothing. Validate everything (Pydantic).
3. **Async**: Do many things at once.

### 🛡️ Safety Patterns

1. **Always authenticate webhooks** (Shared Secret).
2. **Validate types** strictly.
3. **Bind to 0.0.0.0** only inside Docker containers.

### 🚀 Production Rules

1. **Use FastAPI** for new projects.
2. **Use Uvicorn** for running.
3. **Use Docker** to package it.

---

## 🔗 Next Steps

You have mastered the language, the architecture, and the systems. Now, it is time to build your Masterpiece.

**Proceed to**: [Capstone: The Operations Hub →](../08-capstone-script/readme.md)

---

## 📚 Additional Resources

- [FastAPI Documentation (Excellent)](https://fastapi.tiangolo.com/)
- [Uvicorn](https://www.uvicorn.org/)
- [Pydantic](https://pdocs.pydantic.dev/)

---

**🎓 Remember**: A newbie writes a script. An engineer writes an API. A senior engineer writes a **Self-Documenting, Validated, Asynchronous API**.
