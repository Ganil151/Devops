# 🏗️ Angular: Core Syntax & Typescript
*Foundation for Component-Driven Architecture*

---

## 📖 Overview
Angular is a platform for building mobile and desktop web applications. It uses HTML for templates, CSS for styles, and TypeScript for application logic.

---

## 🏗️ Technical Pillars

### 1. TypeScript Foundations
Angular is built in TypeScript. It provides strong typing, interfaces, and decorators.
- **Decorators**: `@Component`, `@NgModule`, `@Injectable`.

### 2. Components
The basic building block. Consists of a class, a template, and styles.
```typescript
@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  title = 'my-app';
}
```

### 3. Data Binding
- **Interpolation**: `{{ value }}`.
- **Property Binding**: `[prop]="value"`.
- **Event Binding**: `(event)="handler()"`.

---
**Next Step**: [02-Directives-and-Pipes](../02-directives-and-pipes/readme.md)
