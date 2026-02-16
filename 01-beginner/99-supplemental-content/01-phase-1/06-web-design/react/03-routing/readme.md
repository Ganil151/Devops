# 🗺️ React Routing & Navigation
*Building Single Page Applications (SPA)*

---

## 📖 Overview
In a traditional web app, clicking a link loads a new page. In a React SPA, the router intercepts the link click and dynamically swaps components without refreshing the browser.

---

## 🏗️ Technical Pillars (React Router)

### 1. `BrowserRouter`
The top-level component that wraps your app and provides access to the browser's history API.

### 2. `Routes` & `Route`
Used to define the mapping between URL paths and components.
```javascript
<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/deployments" element={<DeployList />} />
</Routes>
```

### 3. `Link` vs `<a>`
Never use `<a>` for internal links in React. Use `Link` from the router to prevent full page refreshes.

### 4. `useParams`
A hook used to capture dynamic parts of the URL.
- **Path**: `/node/:nodeId`
- **Hook**: `const { nodeId } = useParams();`

---

## 🚀 Navigation Strategies

- **Programmatic Navigation**: Use `useNavigate()` to move users after an action (e.g., redirect after login).
- **Nested Routes**: Defining layouts with sub-pages (e.g., a Sidebar that stays while content changes).

---

## 💡 SRE Pro-Tip
- **404 Handling**: Always define a catch-all route `<Route path="*" element={<NotFound />} />` to handle broken links gracefully.
- **Protected Routes**: Wrap routes in an `AuthProvider` check to redirect unauthorized users to the login page.

---
**Next Step**: [04-API-Integration](../04-api-integration/readme.md)
