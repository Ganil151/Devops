# ⚙️ Tailwind CSS: Custom Configuration
*Tailoring Architecture to Enterprise Standards*

---

## 📖 Overview
The `tailwind.config.js` file is the brain of your project. It allows you to extend the default theme or customize the built-in design system entirely.

---

## 🏗️ Technical Pillars

### 1. `content` Array
Mandatory for production. It tells Tailwind which files to scan to find used classes for the purge engine.
```javascript
content: [
  "./index.html",
  "./src/**/*.{js,ts,jsx,tsx}",
],
```

### 2. `extend` (Branding)
Use this to add your company's specific hex codes without removing the default Tailwind colors.
```javascript
theme: {
  extend: {
    colors: {
      'infra-blue': '#1e293b',
    },
  },
},
```

### 3. Dark Mode
Tailwind has a built-in `dark:` modifier.
```javascript
darkMode: 'class', // Toggle via a class on the HTML tag
```

---

## 🚀 Advanced Pattern: Plugins
Add functionality like `typography` (for styling raw markdown) or `forms` (to reset browser defaults).

---

## 🛡️ SRE Standard Checklist
- [ ] Is the `content` path exhaustive?
- [ ] Are custom colors documented for other developers?
- [ ] Is `darkMode` enabled for late-night on-call shifts?

---
**Back to Module**: [TailwindCSS Main Guide](../readme.md)
