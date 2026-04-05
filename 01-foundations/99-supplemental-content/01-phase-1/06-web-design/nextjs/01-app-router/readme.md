# 🗺️ Next.js: The App Router
*Modern Routing & Shared Layouts*

---

## 📖 Overview
The App Router is a new paradigm for building React applications using Server Components. It uses file-system based routing where folders define routes and `page.js` defines the UI.

---

## 🏗️ Technical Pillars

### 1. File-Based Hierarchy
- `app/page.js`: Maps to `/`.
- `app/dashboard/page.js`: Maps to `/dashboard`.
- `app/layout.js`: UI shared across all routes (Root layout).

### 2. Server Components (Default)
By default, components in the `app` directory are **React Server Components**. They fetch data on the server and send minimal HTML to the client.

### 3. Dynamic Routes
Use square brackets to capture URL segments: `app/blog/[slug]/page.js`.

---

## 💡 SRE Pro-Tip
Server Components allow you to fetch data directly in the component using `async/await`, eliminating the need for complex state management for data fetching.

---
**Next Step**: [02-SSR-and-ISR](../02-ssr-and-isr/readme.md)
