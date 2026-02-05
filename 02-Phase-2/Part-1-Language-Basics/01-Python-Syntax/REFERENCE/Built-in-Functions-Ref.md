# 🧰 Python Built-in Functions: The Complete Master Reference
*Version 3.0 | Enterprise-Grade Standard Library Audit*

---

## 📖 Overview
This guide provides an exhaustive breakdown of every Python built-in function (Python 3.12+). These functions are pre-loaded into the Global Namespace and represent the most efficient, C-optimized ways to handle operations in automation.

---

## 🖥️ I/O & Filesystem

### `print()`
**Definition**: Outputs data to the standard output stream (stdout). It supports custom separators, end characters, and output redirection.
**Example**:
```python
# Real-time CI/CD logging
print("Deployment started...", end=" | ", flush=True)
```

### `open()`
**Definition**: Opens a file and returns a corresponding file object. Mandatory for handling configurations, logs, and state files.
**Example**:
```python
with open("inventory.yaml", "r") as f:
    data = f.read()
```

### `input()`
**Definition**: Reads a string from standard input (stdin).
**Example**:
```python
prompt = input("Enter confirmation code (OTP): ")
```

---

## 🔢 Mathematical Operations

### `abs()`
**Definition**: Returns the absolute value of a number (distance from zero).
**Example**:
```python
drift = abs(current_count - target_count)
```

### `divmod()`
**Definition**: Takes two numbers and returns a pair (tuple) consisting of their quotient and remainder.
**Example**:
```python
# Calculating hours and minutes for runtime logs
hours, mins = divmod(total_minutes, 60)
```

### `max()`
**Definition**: Returns the largest item in an iterable or the largest of two or more arguments.
**Example**:
```python
highest_latency = max([120, 450, 200, 89])
```

### `min()`
**Definition**: Returns the smallest item in an iterable.
**Example**:
```python
cheapest_region = min(region_costs, key=region_costs.get)
```

### `pow()`
**Definition**: Returns base to the power of exp.
**Example**:
```python
# Exponential backoff base
retry_delay = pow(2, attempt_number)
```

### `round()`
**Definition**: Rounds a number to a specified number of decimal places.
**Example**:
```python
print(f"CPU Load: {round(cpu_util, 2)}%")
```

### `sum()`
**Definition**: Adds all items in an iterable.
**Example**:
```python
total_usage = sum(sent_bytes_list)
```

---

## 🔄 Iteration & Sequences

### `enumerate()`
**Definition**: Returns an enumerate object. It contains the index and value of all items in an iterable as pairs.
**Example**:
```python
for line_no, content in enumerate(log_lines, start=1):
    print(f"Error at Line {line_no}: {content}")
```

### `filter()`
**Definition**: Constructs an iterator from elements of an iterable for which a function returns true.
**Example**:
```python
unhealthy_nodes = list(filter(lambda x: x.status == "DOWN", all_nodes))
```

### `iter()`
**Definition**: Returns an iterator object for the given argument.
**Example**:
```python
stream = iter(log_file_lines)
first_item = next(stream)
```

### `len()`
**Definition**: Returns the number of items (length) in an object.
**Example**:
```python
if len(target_fleet) == 0:
    raise Exception("No targets found")
```

### `map()`
**Definition**: Applies a given function to each item of an iterable and returns a list of the results (via iterator).
**Example**:
```python
int_ports = list(map(int, ["80", "443", "8080"]))
```

### `next()`
**Definition**: Retrieves the next item from an iterator by calling its `__next__()` method.
**Example**:
```python
current_log = next(log_stream)
```

### `range()`
**Definition**: Represents an immutable sequence of numbers.
**Example**:
```python
for attempt in range(MAX_RETRIES):
    if try_deploy(): break
```

### `reversed()`
**Definition**: Returns a reverse iterator of the given sequence.
**Example**:
```python
for log in reversed(audit_trail):
    process(log)
```

### `slice()`
**Definition**: Returns a slice object representing the set of indices specified by range(start, stop, step).
**Example**:
```python
short_hash = commit_id[slice(0, 7)]
```

### `sorted()`
**Definition**: Returns a new sorted list from the items in any iterable.
**Example**:
```python
ips = sorted(unsorted_ip_list)
```

### `zip()`
**Definition**: Returns an iterator of tuples, where the i-th tuple contains the i-th element from each of the argument iterables.
**Example**:
```python
host_map = dict(zip(hostnames, ip_addresses))
```

---

## 🏗️ Type Constructors & Conversion

### `bool()`
**Definition**: Converts a value to a Boolean (True/False).
**Example**:
```python
is_configured = bool(os.getenv("CONFIG_PATH"))
```

### `bytearray()`
**Definition**: Returns a new array of bytes. A mutable sequence of integers in range 0 <= x < 256.
**Example**:
```python
mutable_data = bytearray(b"Raw Data")
```

### `bytes()`
**Definition**: Returns a new "bytes" object, which is an immutable sequence of integers.
**Example**:
```python
payload = bytes([0x13, 0x37])
```

### `complex()`
**Definition**: Returns a complex number with the value real + imag*1j.
**Example**:
```python
z = complex(2, 3)
```

### `dict()`
**Definition**: Creates a new dictionary.
**Example**:
```python
tags = dict(Environment="Prod", Owner="SRE")
```

### `float()`
**Definition**: Converts a number or string to a floating-point number.
**Example**:
```python
uptime_percent = float(raw_data)
```

### `frozenset()`
**Definition**: Returns a new frozenset object (an immutable set).
**Example**:
```python
ALLOWED_ACTIONS = frozenset(["START", "STOP", "RESTART"])
```

### `int()`
**Definition**: Converts a number or string to an integer.
**Example**:
```python
port = int(os.getenv("PORT", "80"))
```

### `list()`
**Definition**: Converts an iterable into a list.
**Example**:
```python
nodes = list(generator_results)
```

### `object()`
**Definition**: Returns a new featureless object. The base for all classes.
**Example**:
```python
sentinel = object() # Used for unique identity checks
```

### `set()`
**Definition**: Returns a new set object, whose elements are taken from iterable.
**Example**:
```python
unique_errors = set(all_errors_collected)
```

### `str()`
**Definition**: Returns a string version of an object.
**Example**:
```python
log_msg = "Error code: " + str(err_int)
```

### `tuple()`
**Definition**: Converts an iterable into an immutable tuple.
**Example**:
```python
config_pair = tuple(["us-east-1", "m5.large"])
```

---

## 🧠 Introspection & Meta-Programming

### `callable()`
**Definition**: Returns True if the object argument appears callable, False if not.
**Example**:
```python
if callable(plugin.run):
    plugin.run()
```

### `dir()`
**Definition**: Without arguments, return the list of names in the current local scope. With an object, return a list of valid attributes for that object.
**Example**:
```python
print(dir(boto3.resource('s3'))) # Explore available methods
```

### `getattr()`
**Definition**: Returns the value of the named attribute of an object.
**Example**:
```python
method = getattr(cloud_provider, "launch_instance")
```

### `hasattr()`
**Definition**: Returns True if the object has the named attribute.
**Example**:
```python
if hasattr(request, "json"):
    data = request.json()
```

### `id()`
**Definition**: Returns the "identity" of an object (a unique integer/memory address).
**Example**:
```python
if id(a) == id(b):
    print("Exact same object in memory")
```

### `isinstance()`
**Definition**: Returns True if the object argument is an instance of the classinfo argument.
**Example**:
```python
if isinstance(config, dict):
    process_map(config)
```

### `issubclass()`
**Definition**: Returns True if class is a subclass of classinfo.
**Example**:
```python
if issubclass(CustomError, Exception):
    raise CustomError
```

### `locals()`
**Definition**: Updates and returns a dictionary representing the current local symbol table.
**Example**:
```python
# Quick debugging of local state
print(locals())
```

### `globals()`
**Definition**: Returns a dictionary representing the current global symbol table.
**Example**:
```python
print(globals().keys())
```

### `type()`
**Definition**: Returns the type of an object.
**Example**:
```python
if type(data) is list:
    print("Processing collection")
```

### `vars()`
**Definition**: Returns the `__dict__` attribute for a module, class, instance, or any other object with a `__dict__` attribute.
**Example**:
```python
# Convert class instance to dictionary
config_dict = vars(config_object)
```

---

## 🛡️ Dynamic Code & Utilities

### `eval()`
**Definition**: Parses and evaluates a string expression as Python code.
**Example**:
```python
# USE WITH CAUTION (Security Risk)
result = eval("5 + 5")
```

### `exec()`
**Definition**: This function supports dynamic execution of Python code.
**Example**:
```python
# USE WITH CAUTION (Security Risk)
exec("print('Dynamic execution context')")
```

### `breakpoint()`
**Definition**: Drops you into the debugger (PDB) at the call site.
**Example**:
```python
if status == "CRASH":
    breakpoint() # Instant debugging
```

### `help()`
**Definition**: Invokes the built-in help system.
**Example**:
```python
help(subprocess.run) # Terminal-based documentation
```

### `repr()`
**Definition**: Returns a string containing a printable representation of an object.
**Example**:
```python
print(repr(error_object)) # Reveal internal structure
```

### `ascii()`
**Definition**: Returns a string containing a printable representation of an object, escaping non-ASCII characters.
**Example**:
```python
print(ascii("nödë")) # Output: 'n\xf6d\xeb'
```

### `bin()`
**Definition**: Converts an integer number to a binary string prefixed with “0b”.
**Example**:
```python
perms = bin(0o755)
```

### `hex()`
**Definition**: Converts an integer number to a lowercase hexadecimal string prefixed with “0x”.
**Example**:
```python
print(hex(255)) # Output: 0xff
```

### `oct()`
**Definition**: Converts an integer number to an octal string prefixed with “0o”.
**Example**:
```python
print(oct(8)) # Output: 0o10
```

### `ord()`
**Definition**: Given a string representing one Unicode character, return an integer representing the Unicode code point.
**Example**:
```python
code = ord('A') # Output: 65
```

### `chr()`
**Definition**: Returns the string representing a character whose Unicode code point is the integer.
**Example**:
```python
char = chr(65) # Output: 'A'
```

### `format()`
**Definition**: Converts a value to a “formatted” representation, as controlled by format_spec.
**Example**:
```python
binary = format(255, 'b')
```

### `hash()`
**Definition**: Returns the hash value of the object (if it has one).
**Example**:
```python
if hash(config_a) == hash(config_b):
    print("Potential identical state")
```

---

## 🆕 Advanced & Async (Python 3.10+)

### `aiter()`
**Definition**: Returns an asynchronous iterator for an asynchronous iterable.
**Example**:
```python
async_iter = aiter(async_resource_stream)
```

### `anext()`
**Definition**: Returns the next item from the given asynchronous iterator when awaited.
**Example**:
```python
val = await anext(async_iter)
```

### `classmethod()`
**Definition**: Transforms a method into a class method.
**Example**:
```python
class S3:
    @classmethod
    def from_config(cls, path):
        return cls(path)
```

### `staticmethod()`
**Definition**: Transforms a method into a static method.
**Example**:
```python
class Utils:
    @staticmethod
    def is_ip(val):
        return "." in val
```

### `property()`
**Definition**: Returns a property attribute (getter/setter/deleter logic).
**Example**:
```python
@property
def status(self):
    return self._status
```

### `super()`
**Definition**: Returns a proxy object that delegates method calls to a parent or sibling class.
**Example**:
```python
class CustomS3(S3):
    def __init__(self):
        super().__init__()
```

### `compile()`
**Definition**: Compile the source into a code or AST object.
**Example**:
```python
code = compile("print(x)", "test", "eval")
```

### `memoryview()`
**Definition**: Returns a “memory view” object created from the given argument.
**Example**:
```python
v = memoryview(bytearray(b"abc"))
```

### `__import__()`
**Definition**: This function is invoked by the import statement. Advanced use only.
**Example**:
```python
module = __import__("os")
```

---
**Next Step**: [Standard Library Deep Dive →](./Standard-Library-Ref.md)
