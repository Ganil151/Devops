# 🖼️ Vue.js: The Progressive Framework
*Intuitive Tooling for Vibrant Interfaces*

---

## 🗺️ Learning Roadmap

### [01-Core-Syntax](./01-core-syntax/)
- **Concepts**: Directives, SFCs, Composition API.
- **Goal**: Build your first reactive component.

### [02-Vue-Router](./02-vue-router/)
- **Concepts**: Components as pages, Guarded routes.
- **Goal**: Navigate through your specialized Vue app.

### [03-State-Pinia](./03-state-pinia/)
- **Concepts**: Reactive stores, Persisting data.
- **Goal**: Share logic across your entire dashboard.

---

## 🛠️ Quick Start
```bash
npm create vue@latest
cd my-vue-app
npm install
npm run dev
```

---

## 🛡️ SRE Standards
- **Lazy Loading**: Use dynamic imports `() => import('./MyComp.vue')` for routes to reduce initial load.
- **Teleport**: Use `<Teleport>` to move modals to the end of `<body>` for cleaner CSS interactions.
- **Reactivity Check**: Prefer `ref()` for primitive state and `reactive()` only for complex objects.
