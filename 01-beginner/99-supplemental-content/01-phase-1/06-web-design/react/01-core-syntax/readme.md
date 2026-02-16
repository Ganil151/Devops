# ⚛️ Core React Syntax: JSX & Components
*Foundation for Building Modern User Interfaces*

---

## 📖 Overview
React uses a declarative approach to build UIs. Instead of telling the browser exactly how to change the DOM, you describe what the UI should look like based on the current state.

---

## 🏗️ Technical Pillars

### 1. JSX (JavaScript XML)
JSX allows you to write HTML-like code inside JavaScript. It is compiled by tools like Babel into `React.createElement()` calls.
- **Rule**: You must return a single parent element (or a fragment `<>...</>`).
- **Rule**: Use `className` instead of `class`.
- **Expression**: Use `{ }` to embed JavaScript logic.

### 2. Functional Components
The modern standard. A component is a simple JavaScript function that returns JSX.
```javascript
function StatusCard({ label, value }) {
  return (
    <div className="card">
      <h3>{label}</h3>
      <p>{value}</p>
    </div>
  );
}
```

### 3. Props (External Data)
Props (short for properties) are read-only inputs passed from a parent component.
- **One-Way Data Flow**: Data moves down from parent to child.

---

## 🧪 Exercise
1. Create a `Header` component that accepts a `title` prop.
2. Nest a `UserMenu` component inside the `Header`.
3. Render the `Header` in the main `App` component.

---
**Next Step**: [02-Hooks-and-State](../02-hooks-and-state/readme.md)
