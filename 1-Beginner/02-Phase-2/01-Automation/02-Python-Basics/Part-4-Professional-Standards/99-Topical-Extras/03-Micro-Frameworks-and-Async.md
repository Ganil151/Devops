# Micro-Frameworks & Async Operations
*Building lightweight internal tools and high-performance services with Python*

In DevOps, you often need a simple interface to trigger a script or a robust service to handle events from many sources. Python provides micro-frameworks like **Bottle** and asynchronous tools like **Tornado** for these needs.

---

## 🍾 1. Rapid Tooling with Bottle
`Bottle` is a WSGI micro web-framework. It is distributed as a single file, making it perfect for portable internal tools.

### **Building a Task Manager Dash**
```python
from bottle import route, run, response, request
import json

tasks = {
    "tasks": [
        {"id": 1, "task": "Rotate Certificates", "status": "OPEN"},
        {"id": 2, "task": "Cleanup /tmp", "status": "COMPLETE"}
    ]
}

@route('/tasks')
def list_tasks():
    response.content_type = 'application/json'
    return json.dumps(tasks)

@route('/tasks', method='POST')
def add_task():
    new_task = request.json
    tasks["tasks"].append(new_task)
    return {"status": "success"}

run(host='localhost', port=8080)
```

---

## 🌪️ 2. High-Performance Async with Tornado
For systems that need to scale or handle long-lived connections (like long-running automation tasks), **Tornado** uses a non-blocking network I/O.

### **Asynchronous HTTP Handler**
```python
import tornado.ioloop
import tornado.web

class MainHandler(tornado.web.RequestHandler):
    async def get(self):
        # Non-blocking async logic
        self.write("DevOps Automation Hub v1.0")

def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
```

---

## 🔄 3. CRUD in Automation Services
DevOps tools should follow the CRUD lifecycle:
1. **Create**: Triggering a new deployment or task.
2. **Read**: Monitoring the status of a run.
3. **Update**: Changing parameters or scaling resources.
4. **Delete**: Cleaning up environments or logs.

---

## 🏛️ Micro-Service Architecture
![Micro-Service Architecture Flow](../../assets/microservice_architecture.svg)

---

## 📖 Stories from the Field: The Webhook Receiver
**Scenario**: A team needed to trigger a server maintenance script every time a developer pushed a specific tag to Git.
**Solution**: A tiny `Bottle` app was created to act as a **Webhook Receiver**. Git pushed to the Bottle app, which verified the tag and spawned the cleanup subprocess.
**Outcome**: Removed manual intervention from the maintenance cycle completely.

---

## ❓ Interview Questions
1. **What makes Bottle a "Micro" framework?**
2. **Explain the benefits of an Asynchronous Event Loop in Tornado.**
3. **How do you handle security (Auth) for internal DevOps micro-services?**

---
**Next Step**: Return to **[Module Overview](./README.md)**.
