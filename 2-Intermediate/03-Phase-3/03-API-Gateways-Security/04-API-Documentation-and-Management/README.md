# 04: API Documentation and Management

API management isn't just about routing; it's about the entire lifecycle—from design and documentation to retirement.

## 📝 OpenAPI Specification (formerly Swagger)

The **OpenAPI Specification (OAS)** is a standard, language-agnostic interface for RESTful APIs. It allows humans and computers to discover and understand the capabilities of a service without access to source code.

### Key Sections:
- `info`: Title, version, description.
- `paths`: Available endpoints (GET /users, POST /login).
- `components`: Reusable schemas (User object, Error object).
- `security`: Security schemes (Bearer JWT, API Key).

---

## 🛠️ Management Tools

### 1. Swagger UI
- Generates a visual, interactive documentation page from your OAS file.
- Allows developers to "Try it out" and call API endpoints directly from the browser.

### 2. Postman
- A powerful GUI for testing APIs.
- Supports collections, environment variables, and automated testing scripts (Newman).

### 3. Redoc
- Another popular tool for rendering beautiful, clean API documentation from OpenAPI files.

---

## 🔄 API Lifecycle in DevOps

1. **Design**: Using tools like Stoplight or Swagger Editor.
2. **Mocking**: Creating mock servers to unblock frontend developers before the backend is ready.
3. **Deployment**: Automating the rollout of API updates through CI/CD.
4. **Versioning**: Managing `/v1`, `/v2` endpoints to ensure backward compatibility.
5. **Observability**: Monitoring API latency, error rates, and usage patterns.
6. **Deprecation**: Informing users and gracefully shutting down old versions.
