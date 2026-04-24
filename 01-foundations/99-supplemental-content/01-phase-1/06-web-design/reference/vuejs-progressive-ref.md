# 🖼️ Vue.js Reference: The Progressive Framework
*Version 1.0 | Approaches for Modular and Reactive UI Building*

---

## 📖 Overview
Vue.js is designed from the ground up to be incrementally adoptable. The core library is focused on the view layer only, and is easy to pick up and integrate with other libraries or existing projects.

---

## 🏗️ Core Syntax Components

### Declarative Rendering
**Definition**: Vue uses a template-based syntax to declaratively bind the rendered DOM to the underlying data.
**Example**: `<span>Message: {{ msg }}</span>`

### Directives
**Definition**: Special attributes with the `v-` prefix.
**Example**:
- `v-if`: Conditional rendering.
- `v-for`: List rendering.
- `v-model`: Two-way data binding on form inputs.

### Single File Components (SFCs)
**Definition**: A custom file format (`.vue`) that encapsulates the template, logic, and styles of a component in a single file.

---

## ⚙️ Modern Vue (Composition API)

### `setup()` & `<script setup>`
**Definition**: The entry point for using the Composition API. It allows for cleaner logic organization and better TypeScript support.

### Reactivity (`ref` and `reactive`)
**Definition**:
- `ref()`: Takes a value and returns a reactive object. (Use for primitives).
- `reactive()`: Returns a reactive proxy of the object. (Use for objects/arrays).

### Computed Properties
**Definition**: Reactive data that is derived from other reactive data and cached for performance.

---

## 🍍 State Management (Pinia)

### The Store Pattern
**Definition**: Pinia is the official state management library for Vue. It provides a intuitive way to share data across components.
**Core Concepts**: `State`, `Getters`, `Actions`.

---

## 🚀 Advanced Deployment & Operations

### Vue Router
**Definition**: The standard router for Single Page Apps (SPA) in Vue. Supports dynamic segments and nested routes.

### Teleport
**Definition**: A built-in component that allows us to "teleport" a part of a component's template into a DOM node that exists outside the hierarchy of that component.
**Use Case**: Modals and Popups.

---

## 💡 SRE Pro-Tips
- **Bundle Optimization**: Use `defineAsyncComponent` for heavy components to enable automatic lazy loading.
- **Tree-Shaking**: Ensure you are using the ES module build of Vue to allow the bundler to remove unused parts of the library.
- **SSR (Nuxt.js)**: For huge public-facing portals, consider **Nuxt.js**, the Vue equivalent of Next.js, for better SEO.

---
**Next Step**: [Web Design Best Practices →](./web-design-best-practices-ref.md)
