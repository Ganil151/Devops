# ⚡ Next.js Rendering: SSR & ISR
*Optimizing Performance and SEO*

---

## 📖 Overview
Next.js offers multiple strategies for rendering pages, choosing between speed (Static) and freshness (Server).

---

## 🏗️ Technical Pillars

### 1. Server-Side Rendering (SSR)
HTML is generated on every request. Ideal for user-specific data.
- **Modern Syntax**: `fetch('url', { cache: 'no-store' })`.

### 2. Static Site Generation (SSG)
HTML is generated once at build time. Extreme speed.
- **Modern Syntax**: `fetch('url', { cache: 'force-cache' })`.

### 3. Incremental Static Regeneration (ISR)
The middle ground. Static pages are regenerated in the background as traffic comes in.
- **Syntax**: `fetch('url', { next: { revalidate: 60 } })`.

---

## 🚀 DevOps Benefit
ISR allows you to serve highly dynamic content with the speed of a static site, reducing load on your origin backend servers.

---
**Next Step**: [03-API-Routes](../03-API-Routes/README.md)
