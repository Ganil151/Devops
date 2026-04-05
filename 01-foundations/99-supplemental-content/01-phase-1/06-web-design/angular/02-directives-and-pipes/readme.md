# 🩺 Angular: Directives & Pipes
*Mastering Template Logic and Data Transformation*

---

## 📖 Overview
Directives and Pipes allow you to dynamically alter the DOM and format data directly in the HTML template.

---

## 🏗️ Technical Pillars

### 1. Structural Directives
Alter the structure of the DOM by adding or removing elements.
- `*ngIf`: Conditional rendering.
- `*ngFor`: List rendering.

### 2. Attribute Directives
Alter the appearance or behavior of an existing element.
- `ngClass`: Dynamically change classes.
- `ngStyle`: Dynamically change styles.

### 3. Pipes
Transform data for display purposes without changing the underlying value.
- `{{ date | date:'short' }}`
- `{{ json_data | json }}` (SRE favorite for debugging)
- `AsyncPipe`: Automated subscription for Observables.

---
**Next Step**: [03-Dependency-Injection](../03-dependency-injection/readme.md)
