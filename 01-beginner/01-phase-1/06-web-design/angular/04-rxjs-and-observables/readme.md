# 📡 Angular: RxJS & Observables
*Mastering Asynchronous Data Streams*

---

## 📖 Overview
Angular uses RxJS for handling asynchronous data. An **Observable** is a stream of values that can be observed over time.

---

## 🏗️ Technical Pillars

### 1. Observable Basics
Emits values to subscribers using `.subscribe()`.

### 2. Operators
- `map`: Transform emitted values.
- `filter`: Catch only specific values.
- `switchMap`: Switch to a new observable (perfect for search functionality).

### 3. Subscription Management
Always unsubscribe to prevent memory leaks, or use the `async` pipe.

---
**Back to Module**: [Angular Main Guide](../readme.md)
