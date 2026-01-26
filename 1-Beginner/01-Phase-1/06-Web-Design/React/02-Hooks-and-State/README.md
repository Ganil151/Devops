# ⚓ React Hooks & State Management
*Managing Dynamic Data and Component Lifecycle*

---

## 📖 Overview
Hooks are functions that let you “hook into” React state and lifecycle features from function components. They allow you to maintain state without writing classes.

---

## 🏗️ Essential Hooks

### 1. `useState` (Local State)
Used to track data that changes over time within a component.
```javascript
const [isOnline, setIsOnline] = useState(false);
```

### 2. `useEffect` (Side Effects)
Used for operations that impact things outside the component, like fetching data, manual DOM changes, or setting up subscriptions.
- **Dependency Array**: Control when the effect runs.
  - `[]`: Runs once on mount.
  - `[data]`: Runs whenever `data` changes.

### 3. `useRef` (Direct Access)
Used to access DOM elements directly or to store values that don't trigger a re-render when changed.

---

## 🚀 State Management Architecture

- **Lifting State Up**: If two child components need the same data, move the state to their closest common parent.
- **Context API**: For global state (like auth or themes) that many components need at different levels.

---

## 💡 SRE Pro-Tip
- **Performance**: Avoid putting massive objects in `useState` if only a small field changes. Split into multiple state variables.
- **Cleanups**: Always return a cleanup function in `useEffect` for timers or socket connections to prevent memory leaks.

---
**Next Step**: [03-Routing](../03-Routing/README.md)
