## 📋 **Enhanced Go Cheat Sheet with Beginner-Friendly Explanations**
```go
// Single-line comment - explains the code below

/*
   Multi-line comment
   Used for longer explanations or disabling code blocks
*/

// Go doc comment - appears in documentation (godoc)
// Functions/types starting with capital letter are exported (public)
```

---

## 1. VARIABLES & CONSTANTS

### Declaration Patterns
```go
// ZERO VALUES: Go automatically initializes variables to "zero values"
// string = "", int = 0, bool = false, slice/map = nil
// This prevents uninitialized variable bugs!

// Pattern 1: Explicit declaration with var
var a string           // Declares 'a' as string, initialized to "" (empty)
var a string = "hello" // Declares and initializes
var a = "hello"        // Type inferred from value (compiler figures out it's string)

// Pattern 2: Short declaration (ONLY inside functions!)
// := declares AND initializes, type inferred automatically
a := "hello"           // Most common in real Go code
a, b := "one", "two"   // Multiple variables at once

// Pattern 3: Multiple declarations
var (
    name string        // Grouped declarations for related variables
    age  int           // Cleaner than multiple var statements
    active bool
)

// CONSTANTS: Immutable values (cannot change after declaration)
const Pi = 3.14159
const (
    MaxRetries = 5     // Related constants grouped together
    Timeout    = 30
)

// ⚠️ Common mistake: 
// a := "hello"         // ✅ Works inside functions
// var b = "world"      // ✅ Works anywhere
// c := "test"          // ❌ ERROR outside functions (package level)
```

---

## 2. BASIC TYPES

```go
// Go is STATICALLY TYPED: type checked at compile time
// This catches errors early before runtime!

// BOOLEAN
var isActive bool        // true or false only
isActive = true          // ✅
// isActive = 1          // ❌ ERROR: Go doesn't coerce int to bool

// STRINGS: Immutable sequence of bytes (usually UTF-8)
var name string = "Alice"
name := "Alice"
// name[0] = 'B'        // ❌ ERROR: strings are immutable

// Multi-line strings with backticks (raw string literal)
query := `
    SELECT * FROM users
    WHERE id = 1
`                        // Preserves newlines and spacing

// NUMBERS
// Integers (whole numbers)
var count int = 42       // Platform-dependent: 32 or 64 bits
var small int8 = 127     // Range: -128 to 127
var large int64 = 1000000 // Always 64 bits

// Unsigned integers (only positive, including zero)
var port uint16 = 8080   // Range: 0 to 65535 (perfect for ports!)

// Floating point (decimal numbers)
var price float64 = 19.99 // Most common for calculations
var ratio float32 = 0.75  // Less precision, less memory

// Special types
var ptr uintptr          // Holds memory address (for low-level code)
var letter rune = 'A'    // Unicode code point (int32 alias)
var byteVal byte = 65    // Single byte (uint8 alias)

// COMPLEX NUMBERS (rare in most apps)
var c complex128 = 3 + 4i // For scientific/engineering calculations

// ⚠️ Type conversion is EXPLICIT (no automatic conversion!)
var i int = 42
// var f float64 = i      // ❌ ERROR: can't mix int and float64
var f float64 = float64(i) // ✅ Must explicitly convert

// 💡 When to use which type:
// - int: default for counting, indices
// - int64: large numbers, timestamps, file sizes
// - uint16/32: ports, protocol fields, memory-constrained systems
// - float64: money (use decimal library for production!), measurements
```

---

## 3. COLLECTIONS: ARRAYS, SLICES, MAPS

### Arrays (Fixed Size)
```go
// ARRAYS: Fixed-size collections (rarely used directly)
var arr [3]int           // Array of exactly 3 integers
arr[0] = 1
arr[1] = 2
arr[2] = 3
// arr[3] = 4            // ❌ PANIC: index out of bounds!

// Array literal
var days [7]string = [7]string{"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}

// ⚠️ Arrays are VALUES: copying creates a full copy!
a := [3]int{1, 2, 3}
b := a                   // b is a COMPLETE COPY of a
b[0] = 99
fmt.Println(a[0])        // Still prints 1 (a unchanged)

// 💡 Use arrays when:
// - Size is truly fixed and known at compile time
// - You need stack allocation for performance
// - Interfacing with C code
```

### Slices (Dynamic Size - USE THESE!)
```go
// SLICES: Dynamic view into an array (90% of what you'll use!)
// Think of slice as a "window" into an underlying array

// Declaration
var s []string           // Nil slice (len=0, cap=0)
s := []string{}          // Empty slice (len=0, cap=0)
s := make([]string, 5)   // Slice with length 5 (all elements = "")
s := make([]string, 0, 10) // Length 0, capacity 10 (pre-allocate for performance)

// Slice literal
nums := []int{1, 2, 3, 4, 5}

// Slicing operations: [low:high]
// Creates a NEW slice viewing elements from index low to high-1
nums := []int{0, 1, 2, 3, 4, 5}
sub := nums[1:4]         // [1 2 3] (indices 1, 2, 3)
start := nums[:3]        // [0 1 2] (from beginning)
end := nums[3:]          // [3 4 5] (to end)
all := nums[:]           // [0 1 2 3 4 5] (copy of entire slice)

// ⚠️ Slices SHARE the underlying array!
original := []int{1, 2, 3}
view := original[0:2]    // [1 2]
view[0] = 99
fmt.Println(original[0]) // Prints 99! (original modified)

// Append: Add elements (may allocate new array if capacity exceeded)
s := []int{1, 2, 3}
s = append(s, 4)         // [1 2 3 4]
s = append(s, 5, 6, 7)   // [1 2 3 4 5 6 7]
// ⚠️ MUST reassign: append may return new slice!

// Copy: Duplicate slice contents
src := []int{1, 2, 3}
dst := make([]int, len(src))
copy(dst, src)           // dst = [1 2 3]

// Length vs Capacity
s := make([]int, 3, 10)
len(s) // 3 (number of elements)
cap(s) // 10 (total allocated space)

// 💡 Slice best practices:
// - Use slices for 99% of collection needs
// - Pre-allocate with make([]T, 0, expectedSize) for performance
// - Always reassign append(): s = append(s, x)
// - Be careful with subslices sharing underlying array
```

### Maps (Hash Tables / Dictionaries)
```go
// MAPS: Key-value pairs with O(1) average lookup
// Keys must be comparable (== operator works)

// Declaration
var m map[string]int     // Nil map (can't add to it yet!)
m = make(map[string]int) // Writable map
m := make(map[string]int) // Short declaration
m := map[string]int{     // Map literal
    "Alice": 25,
    "Bob":   30,
}

// Access and modify
m["Alice"] = 26          // Update existing
m["Charlie"] = 35        // Add new key
age := m["Alice"]        // Read value (returns 0 if key missing!)

// ⚠️ Checking if key exists: "comma ok" idiom
age, exists := m["Alice"]
if exists {
    fmt.Println("Found:", age)
} else {
    fmt.Println("Key not found")
}

// Inline check
if age, ok := m["Alice"]; ok {
    fmt.Println("Age:", age)
}

// Delete key
delete(m, "Bob")         // Removes "Bob" from map
delete(m, "Unknown")     // No panic if key doesn't exist

// Length
len(m)                   // Number of key-value pairs

// ⚠️ Map iteration order is RANDOM (by design!)
for key, value := range m {
    fmt.Println(key, value) // Order changes each run!
}

// 💡 Map best practices:
// - Always initialize with make() or literal before writing
// - Use "comma ok" to distinguish missing key vs zero value
// - Don't rely on iteration order (sort keys if needed)
// - Maps are reference types: passing to function shares the map
```

---

## 4. STRUCTS (Custom Types)

```go
// STRUCTS: Group related data together (like a class without methods)

// Define a struct type
type Person struct {
    Name    string  // Field names MUST be capitalized to be exported (public)
    Age     int     // Lowercase = private to package
    Email   string
    Active  bool
}

// Create instances
var p1 Person                    // Zero values: Name="", Age=0, Email="", Active=false
p2 := Person{"Alice", 25, "alice@example.com", true}  // Positional (order matters!)
p3 := Person{                    // Named fields (recommended!)
    Name:   "Bob",
    Age:    30,
    Email:  "bob@example.com",
    Active: true,
}

// Access fields
p1.Name = "Charlie"              // Modify
name := p1.Name                  // Read
fmt.Println(p1.Age)              // Access

// ⚠️ Field visibility (capitalization matters!)
// Capitalized field: exported (accessible from other packages)
// Lowercase field: private (only accessible within same package)

// Nested structs
type Company struct {
    Name    string
    CEO     Person      // Embed Person struct
    Employees []Person
}

company := Company{
    Name: "Tech Corp",
    CEO: Person{
        Name: "Alice",
        Age:  45,
    },
}
fmt.Println(company.CEO.Name)  // Access nested: "Alice"

// Struct tags (metadata for serialization)
type User struct {
    ID       int    `json:"id"`        // JSON field name
    Username string `json:"username"`  // Used by json.Marshal/Unmarshal
    Password string `json:"-"`         // "-" means ignore this field
}

// 💡 Struct best practices:
// - Use named fields for clarity (not positional)
// - Capitalize fields you need to export
// - Use struct tags for JSON, database, validation
// - Group related fields together logically
```

---

## 5. FUNCTIONS

```go
// FUNCTIONS: First-class citizens in Go

// Basic function
func greet(name string) string {
    return "Hello, " + name
}

// Multiple parameters (group same types)
func add(a, b int) int {  // Note: a, b both int (don't repeat type)
    return a + b
}

// Multiple return values (Go superpower!)
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, fmt.Errorf("division by zero")
    }
    return a / b, nil  // nil = no error
}

// Named return values (document what's returned)
func getUserInfo(id int) (name string, age int, err error) {
    // 'name', 'age', 'err' are initialized to zero values
    if id < 0 {
        err = fmt.Errorf("invalid id")
        return  // Naked return: returns current values of name, age, err
    }
    name = "Alice"
    age = 25
    return  // Returns ("Alice", 25, nil)
}

// Variadic functions (variable number of arguments)
func sum(numbers ...int) int {  // ...int means "zero or more ints"
    total := 0
    for _, n := range numbers {
        total += n
    }
    return total
}
sum(1, 2, 3)        // Returns 6
sum(1, 2, 3, 4, 5)  // Returns 15

// Pass slice to variadic function
nums := []int{1, 2, 3}
sum(nums...)        // Note: ... expands slice

// Functions as values (first-class citizens)
add := func(a, b int) int {
    return a + b
}
result := add(3, 4)  // 7

// Closures (function capturing outer variables)
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}
c := counter()
c()  // 1
c()  // 2
c()  // 3

// 💡 Function best practices:
// - Keep functions small and focused (single responsibility)
// - Use named returns for complex functions or documentation
// - Always handle errors (don't ignore with _)
// - Use variadic functions for flexible APIs
```

---

## 6. METHODS (Functions with Receivers)

```go
// METHODS: Functions attached to types (like object methods)

type Rectangle struct {
    Width, Height float64
}

// Value receiver: gets a COPY of the struct
// Use when you don't need to modify the original
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}

// Pointer receiver: gets a POINTER to struct (can modify)
// Use when you need to modify OR for performance (avoid copying large structs)
func (r *Rectangle) Scale(factor float64) {
    r.Width *= factor
    r.Height *= factor
}

// Usage
rect := Rectangle{Width: 10, Height: 5}
area := rect.Area()      // Go automatically takes address if needed
rect.Scale(2.0)          // rect is now Width: 20, Height: 10

// ⚠️ Consistency rule:
// If ANY method uses pointer receiver, ALL methods should use pointer receiver
// This avoids confusion about which methods can modify

// Method on non-struct types
type MyInt int

func (m MyInt) Double() int {
    return int(m) * 2
}

// 💡 Method best practices:
// - Use pointer receivers for mutation or large structs
// - Use value receivers for small structs (like time.Time) or immutability
// - Keep receiver variable names short (r, p, c, etc.)
```

---

## 7. INTERFACES (Behavior Contracts)

```go
// INTERFACES: Define behavior, not data
// "Duck typing": if it walks like a duck, it's a duck

// Define an interface
type Speaker interface {
    Speak() string  // Any type with Speak() method implements Speaker
}

// Implement interface (implicitly - no "implements" keyword!)
type Dog struct{}
func (d Dog) Speak() string {
    return "Woof!"
}

type Cat struct{}
func (c Cat) Speak() string {
    return "Meow!"
}

// Use interface
func makeSound(s Speaker) {
    fmt.Println(s.Speak())
}

dog := Dog{}
cat := Cat{}
makeSound(dog)  // "Woof!"
makeSound(cat)  // "Meow!"

// Empty interface: interface{} (or 'any' in Go 1.18+)
// Can hold ANY value (like 'Object' in Java, 'any' in TypeScript)
func printAny
```