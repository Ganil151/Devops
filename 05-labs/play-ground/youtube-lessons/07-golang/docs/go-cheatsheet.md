Here is the content of the image transcribed into a clean, formatted `README.md` file.

```markdown
# Go (Golang) Cheat Sheet

A quick reference guide for Go syntax and concepts based on the provided cheat sheet.

## 1. Variables

### Declaration
```go
// declare variable
var a string
var a string = "something"

// type is inferred:
var a = "something"
a := "something"
a, b := "one", "two"
```

### Maps
```go
// map
var a map[string]string
a := make(map[string]string)
a := map[string]string{"k": "v"}
```

### Arrays & Slices
```go
// array
var d [2]int = [2]int{1, 2}

// slice
var a []string
a := make([]string, 5)
a := make([]string, 5, 10)
```

### Multiple Variables
```go
var (
    a string
    b int
)
```

### Structs
```go
// struct
type myStruct struct {
    c string
}

var a myStruct
a := myStruct{c: "a string"}
a := myStruct{"a string"} // Positional
a.c = "a string"
```

---

## 2. Types

| Type | Description |
| :--- | :--- |
| `bool` | Boolean |
| `string` | String |
| `byte` | alias for `uint8` |
| `rune` | alias for `int32` |
| `float32`, `float64` | Floating point numbers |
| `int`, `int8`, `int16`, `int32`, `int64` | Signed integers |
| `uint`, `uint8`, `uint16`, `uint32`, `uint64` | Unsigned integers |
| `uintptr` | Unsigned integer to hold a pointer |
| `complex64`, `complex128` | Complex numbers |

---

## 3. Conditions

### Comparison & Logical
```go
// Comparison: < > <= >= == !=
// Logical: || && !

if a >= 10 && b >= 10 {
    // ...
} else if !(a < 5) {
    // ...
} else {
    // ...
}
```

### Switch
```go
switch a {
case 5:
    // ...
default: // optional
    // ...
}
```

---

## 4. Operators

```go
a := 5 + 5
a += 5 // same as a = a + 5
b := a >= 5 // returns boolean
b++ // increase b by one
b-- // decrease b by one
```

---

## 5. Slices

```go
a := []int{}
a := []int{1, 2, 3, 4, 5, 6, 7}

fmt.Printf("%v", a[0:2]) // [1 2]
fmt.Printf("%v", a[5:len(a)]) // [6 7]
```

---

## 6. Functions

```go
func returnTwo() (bool, bool) { 
    // ... 
}

func myFunc(b int, c int64) bool {
    return true
}

func myFunc(b, c int) { 
    // ... 
}

// assigning function to a variable:
a := func (a int) int { return a + 1 }
fmt.Printf("%v", a(1))
```

---

## 7. Loops

```go
// Standard for loop
for i := 0; i < 5; i++ { 
    // ... 
}

// Indefinite loop
for { 
    // ... 
}

// While-style loop
for {
    if a == 5 { break } // break loop
}

for {
    if a == 5 { continue } // next iter.
}

// range keyword
for k, v := range a {
    // k will be int for array/slice
    // k will be key for map
    // v will be value
}
```

---

## 8. Methods

```go
type myStruct struct {
    c string
}

// Value receiver (will NOT update original struct)
func (m myStruct) method() {
    m.c = "newstr" 
}

// Pointer receiver (WILL update original struct)
func (m *myStruct) method() {
    m.c = "newstr" 
}

a := MyStruct{}
b := &MyStruct{}
```

---

## 9. Interfaces

```go
type myIface interface {
    method()
    method2(a int) (bool, error)
}
```

---

## 10. Pointers

```go
a := "123"
b := &a // pointer to a

fmt.Println(b)   // 0x00001c030 (memory address)
fmt.Println(*b)  // "123" (dereference)

*b = "456" // change a through pointer b
```

---

## 11. Various

### Constants
```go
// constants (fixed value)
const a int = 5
```

### Goroutines
```go
// run hello() in goroutine
go hello()
```
```