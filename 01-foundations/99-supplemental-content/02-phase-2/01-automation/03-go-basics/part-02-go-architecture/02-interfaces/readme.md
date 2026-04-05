# 🔌 Interfaces in Go

> **"Interfaces are the ultimate tool for decoupling in Go. They allow you to define contracts for your automation components—whether it's a cloud provisioner, a database client, or a notification system—enabling seamless swaps and unified testing without changing core logic."**

Interfaces in Go are different from many other languages. They are **implicit**, meaning you don't need a keyword like `implements`. If a type provides the methods an interface requires, it automatically satisfies that contract. This "duck typing" philosophy is a core strength of Go's modular architecture.

![Go Interfaces Diagram](./go-interfaces-diagram.png)

## Table of Contents

- [Introduction to Interfaces](#introduction-to-interfaces)
- [Implementing Interfaces](#implementing-interfaces)
- [The Empty Interface and Type Assertions](#the-empty-interface-and-type-assertions)
- [Interface Composition](#interface-composition)
- [Practical Use Cases](#practical-use-cases)
- [Best Practices](#best-practices)
- [Knowledge Vault (Scenarios, Interview, Quiz)](#knowledge-vault)
- [Additional Resources](#additional-resources)

---

## 💼 The Automation Why: The Universal Connector 

**The Beginner's Question**: "Interfaces seem like extra work. Why not just pass the struct directly?"

**The Answer**: **Hard-coding is a technical debt you can't afford.**
If your automation script is hard-coded to work only with "AWS S3," what happens when your company moves to "Azure Blob Storage"? You have to rewrite every line that interacts with storage. An interface allows you to write your logic once ("Save this file somewhere") and swap the provider ("S3" or "Azure") with a single line of config.

### The Universal Remote Analogy 📺

- **Concrete Types** = **The TV's Internal Circuitry**: If you want to change the channel, you could take apart the TV and flip a specific switch inside. But that's dangerous, messy, and specific to *that* TV. You can't use a Sony switch on a Samsung TV.
- **Interfaces** = **The Universal Remote Control**: The remote doesn't care if the TV is a Sony, Samsung, or LG. It just knows it needs to send a "Power" signal or a "Volume Up" signal. By using the remote (The Interface), you can control any TV (The Concrete Type) without knowing its internal wiring. In Go, you program the "Remote," and let the "TVs" handle the implementation.

---

## Introduction to Interfaces

### What is an Interface?

An **interface** is an abstract type that defines a set of method signatures. It does not provide any implementation logic itself; instead, it defines a "contract" that other types must fulfill.

### Key Features

- **Decoupling**: Interfaces allow you to write code that depends on behaviors (methods) rather than specific concrete types.
- **Implicit Implementation**: A type implements an interface by simply implementing its methods. There is no `implements` keyword in Go.

### Example: A Simple Interface

```go
type Notifier interface {
    Notify(message string) error
}
```

---

## Implementing Interfaces

To satisfy the `Notifier` interface above, a struct only needs to have a method named `Notify` that matches the signature.

```go
type SlackNotifier struct {
    WebhookURL string
}

func (s SlackNotifier) Notify(message string) error {
    fmt.Printf("Sending Slack alert to %s: %s\n", s.WebhookURL, message)
    return nil
}

type EmailNotifier struct {
    Address string
}

func (e EmailNotifier) Notify(message string) error {
    fmt.Printf("Sending Email to %s: %s\n", e.Address, message)
    return nil
}

// Any type that satisfies the interface can be used here
func SendAlert(n Notifier, msg string) {
    n.Notify(msg)
}
```

---

## The Empty Interface and Type Assertions

### The Empty Interface (`interface{}`)

The empty interface specifies zero methods. Because every type has at least zero methods, **every type satisfies the empty interface**. It is used to handle values of unknown types.

```go
func printAnything(v interface{}) {
    fmt.Println(v)
}
```

### Type Assertions

To get the original type back from an interface value, you use a **type assertion**.

```go
var val interface{} = "hello"

s, ok := val.(string)
if ok {
    fmt.Println("Found string:", s)
}
```

### Type Switches

A cleaner way to handle multiple possible types in an interface.

```go
func identify(i interface{}) {
    switch v := i.(type) {
    case int:
        fmt.Printf("Twice %v is %v\n", v, v*2)
    case string:
        fmt.Printf("%q is %v bytes long\n", v, len(v))
    default:
        fmt.Printf("I don't know about type %T!\n", v)
    }
}
```

---

## Interface Composition

Just like structs can be embedded, interfaces can be composed of other interfaces. This allows you to build complex requirements from smaller, simpler contracts.

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// ReadWriter is the combination of Reader and Writer
type ReadWriter interface {
    Reader
    Writer
}
```

---

## Practical Use Cases

### Example: Multi-Cloud Provisioner

In DevOps, you might want to provision resources on AWS, Azure, or GCP using the same high-level logic.

```go
type Provisioner interface {
    CreateServer(name string) error
    DeleteServer(name string) error
}

type AWSProvisioner struct {
    Region string
}

func (a AWSProvisioner) CreateServer(name string) error {
    fmt.Printf("AWS: Provisioning EC2 instance %s in %s\n", name, a.Region)
    return nil
}

type GCPProvisioner struct {
    ProjectID string
}

func (g GCPProvisioner) CreateServer(name string) error {
    fmt.Printf("GCP: Provisioning VM %s in project %s\n", name, g.ProjectID)
    return nil
}

func SetupInfrastructure(p Provisioner, nodeName string) {
    p.CreateServer(nodeName)
}
```

---

## Best Practices

- **Keep Interfaces Small**: Prefer many small, specific interfaces (like `Reader` or `Writer`) over one large "god" interface.
- **Accept Interfaces, Return Structs**: A common Go mantra. Functions should accept parameters as interfaces to be flexible, but they should return concrete structs so the caller has more control.
- **Pointer Receivers**: Remember that if a method uses a pointer receiver (`*T`), then only a pointer to that type (`*T`) satisfies the interface, not the value (`T`).
- **Zero Values**: An interface variable's zero value is `nil`. Calling a method on a `nil` interface will cause a runtime panic.

---

## Knowledge Vault

### Real-World Scenarios

#### Scenario 1: The Pluggable Monitoring System

A startup built an internal tool to monitor their servers. Initially, it only sent alerts to Slack. As the team grew, some senior engineers wanted PagerDuty alerts, while developers wanted simple console logs for local testing.
**Go Solution**: They defined an `AlertSystem` interface. Now, they can write `SlackAlert`, `PagerDutyAlert`, and `ConsoleLog` implementations and swap them out via a simple config flag without touching any core monitoring logic.

#### Scenario 2: Mocking for Tests

You have a function that deletes files from an S3 bucket. Testing this in a CI/CD pipeline is expensive and slow if you actually call AWS every time.
**Go Solution**: Create a `FileStorage` interface. In production, use the real AWS client. In tests, use a "MockStorage" struct that satisfies the interface but only records the calls in memory, making tests fast and free.

### Interview Preparation

1. **How does Go differ from Java regarding interface implementation?**
   > In Java, implementation is explicit (using the `implements` keyword). In Go, it is implicit; a type satisfies an interface automatically if it possesses the required methods. This allows you to satisfy interfaces defined in third-party packages without needing to modify their source code.

2. **What is a "Type Switch"?**
   > A type switch is a construct that compares the underlying type of an interface variable against multiple types. It is similar to a regular switch statement but used specifically for type identification.

3. **What happens if you call a method on a `nil` interface?**
   > It will cause a runtime panic. An interface variable is only "non-nil" if both its type information and its value information are set.

4. **Why should you "Accept Interfaces, Return Structs"?**
   > Accepting interfaces makes your function flexible (it can take multiple types). Returning structs makes your function easy to use because the caller gets a concrete object with all its specific fields and methods available, rather than being limited to the interface's methods.

### Knowledge Check (Quiz)

1. **Does a type need to explicitly declare which interface it implements?**
   - a) Yes, using the `satisfies` keyword
   - b) No, implementation is implicit ✅
   - c) Only at the package level

2. **What is the zero value of an interface?**
   - a) `nil` ✅
   - b) `struct{}`
   - c) `undefined`

3. **Which special interface is satisfied by ALL types in Go?**
   - a) `type Any interface`
   - b) `interface{}` (The empty interface) ✅
   - c) `object`

4. **In the mantra "Accept Interfaces, Return Structs", why return structs?**
   - a) They are faster to compile
   - b) To give the caller maximum flexibility with the resulting object ✅
   - c) Structs can be converted to JSON automatically

5. **When composing interfaces, do you need to rewrite the method signatures?**
   - a) Yes, for clarity
   - b) No, just list the interface names inside the new interface ✅
   - c) Interfaces cannot be composed, only structs can

---

## Additional Resources

- **Official Go Documentation on Interfaces**: [https://golang.org/ref/spec#Interface_types](https://golang.org/ref/spec#Interface_types)
- **Go Tour (Interfaces)**: [https://tour.golang.org/methods/9](https://tour.golang.org/methods/9)
- **Effective Go (Interfaces)**: [https://golang.org/doc/effective_go#interfaces](https://golang.org/doc/effective_go#interfaces)

---

**Next Step**: [Error Handling →](../03-error-handling/readme.md)
