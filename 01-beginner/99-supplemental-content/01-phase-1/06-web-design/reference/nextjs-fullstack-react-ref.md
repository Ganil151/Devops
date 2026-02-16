# 🏔️ Next.js: The Complete Fullstack React Framework
*Version 1.0 | Optimizing Performance with SSR & ISR*

---

## 📖 Overview
Next.js is a flexible React framework that gives you building blocks to create fast web applications. It handles the heavy lifting of configuration, routing, and optimization. For DevOps, Next.js is ideal for building high-performance public portals and SEO-sensitive landing pages.

---

## 🏗️ Rendering Strategies

### Server-Side Rendering (SSR)
**Definition**: Generating the HTML on the server for every request.
**Example**: `getServerSideProps` or Server Components (App Router).
**Use Case**: Real-time dashboards with constantly changing data.

### Static Site Generation (SSG)
**Definition**: Generating the HTML at build time.
**Example**: `getStaticProps`.
**Use Case**: Documentation sites and blogs where content changes infrequently.

### Incremental Static Regeneration (ISR)
**Definition**: Updating static pages after the site has been built, without rebuilding the entire site.
**Config**: `revalidate: 60` (updates every minute).

---

## 🗺️ File-Based Routing

### App Router
**Definition**: The modern standard for routing in Next.js, using the `app/` directory and folders to define paths.
**Example**: `app/dashboard/page.tsx` maps to `/dashboard`.

### Layouts & Templates
**Definition**: UI shared across multiple pages (navbars, footers) that preserves state and avoids re-renders.

---

## ⚙️ Data Fetching & Optimization

### Server Components
**Definition**: React components that run exclusively on the server.
**Impact**: Zero client-side JavaScript for the component logic, leading to faster page loads.

### Image Optimization
**Definition**: Automatic resizing, optimizing, and serving images in modern formats like WebP.
**Component**: `<Image src="..." />`.

---

## 🚀 DevOps & Deployment

### Vercel Deployment
**Definition**: The native platform for Next.js with built-in CI/CD, edge functions, and preview deployments.

### Self-Hosting (Node.js/Docker)
**Definition**: Containerizing a Next.js app to run on Kubernetes or standard servers.
**Command**: `npm run build && npm run start`.

---

## 💡 SRE Pro-Tips
- **Middleware**: Use Next.js Edge Middleware for geo-blocking, rewrite logic, or authentication checks before a request reaches the application.
- **Environment Variables**: Use `NEXT_PUBLIC_` prefix for variables intended for the browser; others remain strictly server-side.
- **Bundle Analysis**: Use `@next/bundle-analyzer` to identify large dependencies slowing down your frontend.

---
**Next Step**: [Node.js & Express Backend →](./nodejs-express-ref.md)
