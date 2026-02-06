# 🖼️ Vue.js Core Syntax
*Approachable, Versatile UI Building*

---

## 📖 Overview
Vue.js is known for being extremely easy to pick up. It uses a "Directive" based approach and Single File Components (`.vue`).

---

## 🏗️ Technical Pillars

### 1. Template Directives
- `v-if`: Conditional rendering.
- `v-for`: List rendering.
- `v-model`: Two-way data binding for forms.

### 2. Composition API (Modern)
The `setup()` function and `ref()` are used to handle logic cleanly.
```javascript
<script setup>
import { ref } from 'vue'
const count = ref(0)
</script>
```

### 3. SFC (Single File Components)
Putting `<template>`, `<script>`, and `<style>` in one `.vue` file.

---
**Next Step**: [02-Vue-Router](../02-vue-router/readme.md)
