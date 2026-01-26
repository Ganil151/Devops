# 🔌 Next.js Route Handlers (API)
*Building Backends within the Frontend*

---

## 📖 Overview
Next.js allows you to create API endpoints as "Route Handlers." These are equivalent to building Node.js/Express routes, but integrated directly into your App Router hierarchy.

---

## 🏗️ Technical Pillars

### 1. `route.js`
Any file named `route.js` inside a folder will act as an API endpoint.
```javascript
export async function GET() {
  return Response.json({ status: 'API Online' });
}
```

### 2. Supported Methods
Next.js supports standard HTTP methods: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.

### 3. Usage inside Frontend
You can call your internal API routes using standard `fetch()` calls from client components.

---

## 💡 SRE Pro-Tip
Route Handlers run on the server (often as Serverless Functions). Use them to mask third-party API keys so they never reach the user's browser.

---
**Back to Module**: [NextJS Main Guide](../README.md)
