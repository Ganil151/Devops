# 🍍 Pinia: Vue State Management
*The Intuitive Data Store for Vue 3*

---

## 📖 Overview
Pinia is the modern successor to Vuex. It is type-safe, modular, and extremely lightweight.

---

## 🏗️ Technical Pillars

### 1. The Store
Stores contain `state`, `getters`, and `actions`.
```javascript
export const useAuthStore = defineStore('auth', {
  state: () => ({ user: null }),
  actions: {
    login(data) { this.user = data }
  }
})
```

### 2. Reactivity
Unlike standard JS objects, state in Pinia is reactive—changing it automatically updates the UI.

### 3. Persisted State
Use plugins like `pinia-plugin-persistedstate` to keep user settings after a page refresh.

---
**Back to Module**: [VueJS Main Guide](../readme.md)
