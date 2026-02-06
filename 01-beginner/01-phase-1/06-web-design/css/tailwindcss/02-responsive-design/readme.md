# 📱 Tailwind: Responsive Design Standards
*Building Adaptive Interfaces for Desktop & Mobile*

---

## 📖 Overview
Tailwind uses a **Mobile-First** approach. Classes without a prefix apply at all sizes; prefixes apply styling at a specific breakpoint and above.

---

## 🏗️ The Breakpoint Scale

| Prefix | Minimum Width | Typical Device |
| :--- | :--- | :--- |
| (none) | 0px | Mobile Phone |
| `sm:` | 640px | Large Phone / Tablet |
| `md:` | 768px | Tablet / Small Laptop |
| `lg:` | 1024px | Desert / Desktop |
| `xl:` | 1280px | Large Monitor |

---

## 🚀 Responsive Strategy

- **Columns**: `grid-cols-1 md:grid-cols-2 lg:grid-cols-4` (Stacks on mobile, spreads on desktop).
- **Navigation**: Hide detailed menus on mobile (`hidden md:block`) and show a hamburger menu instead.
- **Font Sizes**: `text-sm md:text-lg` (Bigger text on bigger screens).

---

## 💡 SRE Pro-Tip
Always test your dashboards on small screens. An on-call engineer might need to check a status bar on their phone while away from their keyboard.

---
**Next Step**: [03-Custom-Config](../03-custom-config/readme.md)
