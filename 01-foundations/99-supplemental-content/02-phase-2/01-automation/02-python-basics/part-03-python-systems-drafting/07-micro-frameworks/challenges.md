# 🎯 Micro-Frameworks - Challenges

> **"Turning a script into a service is the final step in the maturity of an automation tool. These challenges test your ability to build the 'Front Door' for your logic."**

---

## 🏆 Challenge 1: The Health Check API
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 15 minutes

### Objective
Create a simple FastAPI app that reports the status of your local machine.

### Requirements
- Create a `GET /health` endpoint.
- Return a JSON object: `{"status": "OK", "uptime": "Up"}`.
- Create a `GET /version` endpoint that returns a hardcoded version string.
- Run the server using `uvicorn`.

### Hints
- Use `@app.get("/")`.
- Return a standard dictionary.

---

## 🏆 Challenge 2: The Webhook Receiver
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 35 minutes

### Objective
Build a POST endpoint that receives a payload and prints a specific field.

### Requirements
- Create a Pydantic model `Alert` with fields: `service`, `severity`, and `message`.
- Create a `POST /webhook` endpoint that accepts an `Alert`.
- Print a formatted message to the console: `[CRITICAL] alert from Service: DB_SERVER`.
- Return `{"message": "Alert received"}` with a 201 status code.

### Hints
- Use `from pydantic import BaseModel`.
- Use `status_code=201` in the decorator.

---

## 🏆 Challenge 3: The Guarded Script
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 50 minutes

### Objective
Build an API that triggers a local "Deployment" (simulated) only if a secret token is provided.

### Requirements
- Define a secret token in an Environment Variable `API_SECRET`.
- Create a `POST /deploy` endpoint.
- Require an `X-Auth-Token` in the headers.
- If the token matches `API_SECRET`, print "🚀 DEPLOYING..." and return success.
- If the token is missing or wrong, return a **401 Unauthorized** error.

### Hints
- Use `Header(None)` in the path function arguments.
- Use `from fastapi import HTTPException`.

---

## 🎓 Bonus Challenge: The Async Auditor
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 40 minutes

### Objective
Create an endpoint that performs a "Long running task" without blocking other users.

### Requirements
- Create an `async def` endpoint `POST /audit`.
- Use `await asyncio.sleep(5)` to simulate a slow scan.
- While the audit is running, ensure you can still hit the `/health` endpoint and get an immediate response.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Health Check API
- [ ] Challenge 2: Webhook Receiver
- [ ] Challenge 3: Guarded Script
- [ ] Bonus: Async Auditor
