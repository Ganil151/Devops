# 🅰️ Angular: Enterprise Frontend Engineering
*The High-Scale Robust Framework for Web Professionals*

---

## 🗺️ Learning Roadmap

### [01-Core-Syntax](./01-core-syntax/)
- **Concepts**: TypeScript, Components (`@Component`), Templates.
- **Goal**: Understand the highly-opinionated structure of an Angular application.

### [02-Directives-and-Pipes](./02-directives-and-pipes/)
- **Concepts**: `*ngIf`, `*ngFor`, Custom Directives, Async Pipes.
- **Goal**: Master DOM manipulation and data transformation.

### [03-Dependency-Injection](./03-dependency-injection/)
- **Concepts**: Services (`@Injectable`), Providers, Hierarchical Injectors.
- **Goal**: Handle business logic and data fetching outside of components.

### [04-RxJS-and-Observables](./04-rxjs-and-observables/)
- **Concepts**: Streams, Map/Filter operators, Subscription management.
- **Goal**: Manage complex asynchronous event streams.

---

## 🛠️ Quick Start (Angular CLI)
```bash
npm install -g @angular/cli
ng new my-app
cd my-app
ng serve
```

---

## 🛡️ SRE Standards
- **AOT Compilation**: Always use Ahead-of-Time (AOT) compilation for production builds.
- **Bundle Budgets**: Set strict budgets in `angular.json` to prevent performance regression.
- **Strict Mode**: Enforce TypeScript strict mode for maximum type safety in massive codebases.
