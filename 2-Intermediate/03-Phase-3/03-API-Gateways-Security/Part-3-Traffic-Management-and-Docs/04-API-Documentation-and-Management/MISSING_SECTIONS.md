# 📝 API Documentation & Lifecycle: The Developer's Gateway

In microservices, the API documentation is your "Product Manual." If it's bad, developers won't use your service. If it's missing, they'll build their own and create technical debt.

---

## 🏗️ 1. API Versioning Strategies

How you handle changes determines how much your clients hate (or love) you.

### Path-based Versioning (`/v1/users`)
*   **Pros**: Explicit, easy to route at the Gateway or Load Balancer.
*   **Cons**: Requires updating the URL in all client code for every major change.

### Header-based Versioning (`Accept: application/vnd.myapi.v1+json`)
*   **Pros**: Keeps the URL "clean" and semantically correct.
*   **Cons**: Harder to test in a browser; less obvious visibility.

---

## 🔄 2. The Mocking & Socializing Phase

One of the biggest bottlenecks in DevOps is Frontend/Mobile teams waiting for the Backend team to finish an API.

*   **Mock Servers**: Using an OpenAPI spec, you can spin up a "prism" or "postman" mock server. It returns real-looking JSON data immediately.
*   **DX (Developer Experience)**: Good documentation includes code snippets in multiple languages (Curl, Python, JavaScript) so developers can copy-paste and start building in seconds.

---

## 📖 Real-World DevOps Story: "The Breaking Change Incident"

**The Scenario:** A high-fidelity logging service decided to rename a field `userId` to `account_id` in their API response to be more consistent with their database. They pushed the change to production.

**The Incident:** Every mobile app and 3rd party integration immediately crashed. The logs showed "field 'userId' not found." The company lost $50k in revenue during the 2-hour rollback.

**The Fix:** 
1.  Reverted to the old API.
2.  Implemented a **Deprecation Policy**.
3.  Released `/v2/` with the new field name.
4.  Included a `Warning` header in `/v1/` responses telling clients they have 6 months to migrate.

**The Lesson:** Never change an existing API response. If you must change it, create a new version and migrate users slowly.

---

## 👔 Interview Preparation

1. **Q: What is the benefit of the OpenAPI Specification (OAS)?**
   *   *A: It provides a "single source of truth" that is machine-readable. From a single OAS file, you can generate: 1) Interactive Documentation (Swagger UI), 2) Client SDKs in many languages, 3) Mock Servers for frontend development, and 4) Automated API tests.*

2. **Q: How do you handle a "Breaking Change" in a production API?**
   *   *A: You NEVER change the existing endpoint. Instead, you release a new version (e.g., `/v2/`). You then keep `/v1/` running and inform users that it is "Deprecated" and will be shut down on a specific date in the future.*

3. **Q: What is the difference between Swagger and OpenAPI?**
   *   *A: **OpenAPI** is the name of the specification (the rules of the language). **Swagger** is the set of tools (UI, Editor, Codegen) that process that specification. It's like the difference between HTML (the standard) and Chrome ( the browser).*

---

## 🧠 Knowledge Check

1. Which tool is used to render OpenAPI specs into a "Try it out" interactive web page? (Swagger UI)
2. In path-based versioning, where does the version number typically sit? (In the URL path, e.g., `/v1/`)
3. True or False: OpenAPI can be used to document non-RESTful APIs like gRPC or GraphQL. (False—it is specifically for RESTful APIs, though AsyncAPI exists for others).

---

## 🔗 Internal Navigation
- [Next: Mastery and Resources Overview](../../Part-4-Mastery-and-Resources/README.md)
- [Back: Traffic Management Hub](../README.md)
