# 📳 Mobile App Frameworks Reference
*Version 1.0 | Comparing Native Cross-Platform Engineering Standards*

---

## 📖 Overview
Building mobile interfaces for infrastructure management requires balancing performance with development speed. This guide compares the two industry leaders for cross-platform mobile development: ReactNative and Flutter.

---

## 🏗️ ReactNative (JavaScript Core)

### The Bridge Architecture
**Definition**: ReactNative uses a "bridge" to communicate between JavaScript code and the native mobile platform APIs.
**Pros**: Leverage existing React/JavaScript skills; high accessibility to web developers.
**Cons**: Performance can lag during complex animations due to the bridge bottleneck.

### Native Modules
**Definition**: Custom code written in Java/Kotlin (Android) or Objective-C/Swift (iOS) that exposes native hardware functions to the JavaScript layer.

### Hot Reloading
**Definition**: Injecting updated code into the running app without losing its state.

---

## 🏗️ Flutter (Dart Engine)

### The Skia Rendering Engine
**Definition**: Unlike ReactNative which uses native widgets, Flutter paints its own UI using the Skia graphics engine.
**Impact**: Guaranteed "Pixel Perfect" consistency across iOS and Android.
**Pros**: Blazing fast performance; extremely flexible UI design.

### Everything is a Widget
**Definition**: In Flutter, the entire UI is built from a tree of nested widgets. Even padding and alignment are widgets.

### Dart Compilation
**Definition**: Dart is compiled "Ahead-of-Time" (AOT) to native machine code for production, resulting in near-native speed.

---

## ⚙️ Operational Comparison

| Feature | ReactNative | Flutter |
| :--- | :--- | :--- |
| **Language** | JavaScript/TypeScript | Dart |
| **UI Rendering** | Native Components (via Bridge) | Skia Engine (Custom Painting) |
| **Perf (Graphics)** | Good | Excellent |
| **Dev Speed** | Fast (Large ecosystem) | Very Fast (Hot Reload + UI Kits) |
| **Market Share** | Very High | Growing Fast |

---

## 🛡️ SRE Standard Checklist
- [ ] **HTTPS Enforced**: Mobile apps should never communicate via HTTP. Enforce SSL Pinning for high-security environments.
- [ ] **State Persistence**: Use `AsyncStorage` (RN) or `shared_preferences` (Flutter) to cache auth tokens and last-known-good infra states.
- [ ] **Crash Analytics**: Integrate **Firebase Crashlytics** or Sentry to track native-level crashes on various OS versions.

---
**Next Step**: [Web Design Best Practices →](./web-design-best-practices-ref.md)
