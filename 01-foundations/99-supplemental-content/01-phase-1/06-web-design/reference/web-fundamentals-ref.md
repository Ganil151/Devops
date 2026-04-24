# 🌐 Web Fundamentals: HTML, CSS & JavaScript
*Version 1.0 | The Core Trio of the Modern Web*

---

## 📖 Overview
Everything on the web starts here. Even the most complex frameworks like React or Django ultimately compile down to these three foundational technologies. For SREs, understanding the base layer is critical for debugging browser-side errors, performance issues, and UI glitches.

---

## 🏗️ HTML5: Structural Foundation

### Semantic Tags
**Definition**: Elements that clearly describe their meaning to both the browser and the developer.
**Example**:
- `<header>`, `<footer>`, `<main>`, `<article>`, `<section>`, `<nav>`.
- **SRE Impact**: Better accessibility and SEO.

### Forms & Input
**Definition**: Elements used to collect user data, essential for login screens and settings panels.
**Example**: `<input type="email">`, `<button>`, `<select>`.

### Media Embedding
**Definition**: Built-in support for video, audio, and graphics without third-party plugins.
**Example**: `<video>`, `<audio>`, `<canvas>`, `<svg>`.

---

## 🎨 CSS3: Visual & Layout Engine

### The Box Model
**Definition**: The core concept where every element is represented as a rectangular box consisting of Content, Padding, Border, and Margin.
**SRE Impact**: Crucial for fixing "overflow" or "jumping" UI bugs.

### Flexbox & Grid
**Definition**: Modern layout systems. Flexbox is 1D (rows/cols); Grid is 2D (matrix).
**Example**: `display: flex; justify-content: center;`.

### Responsive Design (Media Queries)
**Definition**: Logic that adjusts styling based on the device width.
**Example**: `@media (max-width: 768px) { ... }`.

### CSS Variables (Custom Properties)
**Definition**: Entities defined by authors that contain specific values to be reused throughout a document.
**Example**: `--primary-color: #007bff;`.

---

## ⚙️ JavaScript (ES6+): Interaction Logic

### DOM Manipulation
**Definition**: The Document Object Model (DOM) is the tree structure of a page. JS allows dynamic updates to this tree.
**Example**: `document.getElementById('app').innerHTML = 'Hello World';`.

### Fetch API (Async Operations)
**Definition**: The modern way to make network requests (AJAX) to backend APIs.
**Example**:
```javascript
async function getData() {
  const response = await fetch('/api/stats');
  const data = await response.json();
}
```

### Arrow Functions & Classes
**Definition**: Syntactic sugar for cleaner, more readable logic.
**Example**: `const log = (msg) => console.log(msg);`.

---

## 💡 SRE Pro-Tips
- **Browser DevTools**: Use `F12` to inspect the "Network" tab for slow API calls and "Elements" for CSS layout issues.
- **Resource Priority**: Use `<link rel="preload">` to speed up the loading of critical fonts or scripts.
- **Console Errors**: Always check `console.log` for client-side JavaScript crashes that might prevent your app from functioning.

---
**Next Step**: [React Frontend Mastery →](./react-frontend-ref.md)
