# 🔌 React API Integration
*Connecting Your Frontend to Backend Services*

---

## 📖 Overview
React is just the "V" (View) in MVC. To be useful, it needs to talk to your infrastructure APIs (FastAPI, Flask, Node.js). This module covers fetching, handling loading states, and error management.

---

## 🏗️ The Data Flow Pattern

### 1. The Async Fetch
Usually performed inside a `useEffect` hook.
```javascript
useEffect(() => {
  const loadData = async () => {
    const res = await fetch('http://api.infra.com/stats');
    const data = await res.json();
    setStats(data);
  };
  loadData();
}, []);
```

### 2. Loading States
Users should never see an empty screen. Use booleans or skeletons.
```javascript
if (isLoading) return <LoadingSkeleton />;
```

### 3. Error Boundaries
Use a dedicated React Error Boundary or a simple `try/catch` to display "Backend Unreachable" messages instead of crashing the UI.

---

## 🚀 Advanced Tools

- **Axios**: A more powerful alternative to `fetch` with built-in retry logic and interceptors.
- **TanStack Query (React Query)**: The production standard for handling caching, synchronizing and updating asynchronous state in React.

---

## 🛡️ SRE Standard Checklist
- [ ] Are API base URLs stored in environment variables (`.env`)?
- [ ] Is there a global "Request Timeout"?
- [ ] Does the UI handle "Rate Limited" (429) errors from the API?
- [ ] Is there a "Retry" button for failed fetches?

---
**Back to Module**: [React Main Guide](../readme.md)
