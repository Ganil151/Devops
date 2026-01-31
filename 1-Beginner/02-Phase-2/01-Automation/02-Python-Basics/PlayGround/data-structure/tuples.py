# Tuples are immutable, so they do not have methods to add, remove, or modify
# elements. However, we can perform some operations like counting occurrences
# and finding the index of an element.

s3_bucket_tuple = (
	"Alice_demo_bucket",
	"Bob_demo_bucket",
	"Chuck_demo_bucket",
	"David_demo_bucket"
)

# Count occurrences of an element
s3_bucket_tuple.count("Alice_demo_bucket")

# Find index of an element
s3_bucket_tuple.index("Bob_demo_bucket")
# Tuple operations
# Accessing first element
print(s3_bucket_tuple[0]) 
 
# Slicing tuple
print(s3_bucket_tuple[1:3]) 

# Length of the tuple 
print(len(s3_bucket_tuple))  

# Membership test
print("Alice_demo_bucket" in s3_bucket_tuple) 

# Max element 
print(max(s3_bucket_tuple))

# Min element  
print(min(s3_bucket_tuple))  

# Reversing the tuple
print(tuple(reversed(s3_bucket_tuple)))  
print(sorted(s3_bucket_tuple))  # Sorting the tuple
# print(sum(s3_bucket_tuple))  # Sum of elements (Error: cannot sum strings)
print(any(s3_bucket_tuple))  # Any element is true
print(all(s3_bucket_tuple))  # All elements are true
print(enumerate(s3_bucket_tuple))  # Enumerate the tuple
print(zip(s3_bucket_tuple))  # Zip the tuple
print(list(s3_bucket_tuple))  # Convert to list
print(set(s3_bucket_tuple))  # Convert to set
# Convert to dictionary (Error: requires key-value pairs)
# print(dict(s3_bucket_tuple))
print(tuple(s3_bucket_tuple))  # Convert to tuple
print(str(s3_bucket_tuple))  # Convert to string
print(bytes(s3_bucket_tuple))  # Convert to bytes
# (Error: valid only for int tuples)
print(bytearray(s3_bucket_tuple))
# Convert to bytearray (Error: valid only for int tuples)
print(frozenset(s3_bucket_tuple))  # Convert to frozenset
# Convert to complex (Error: invalid argument)
print(complex(s3_bucket_tuple))
print(bool(s3_bucket_tuple))  # Convert to boolean
print(float(s3_bucket_tuple))  # Convert to float (Error: invalid argument)
print(int(s3_bucket_tuple))  # Convert to integer (Error: invalid argument)
print(str(s3_bucket_tuple))  # Convert to string
print(repr(s3_bucket_tuple))  # Convert to string representation
print(eval(repr(s3_bucket_tuple)))  # Evaluate string representation
print(hash(s3_bucket_tuple))  # Hash of the tuple
print(type(s3_bucket_tuple))  # Type of the tuple
print(id(s3_bucket_tuple))  # Id of the tuple
print(dir(s3_bucket_tuple))  # List of attributes and methods
print(vars(s3_bucket_tuple))  # Error: no __dict__
print(getattr(s3_bucket_tuple, "count"))  # Get attribute
print(hasattr(s3_bucket_tuple, "count"))  # Check if attribute exists
# Check if subclass (Error: arg 1 must be class)
print(issubclass(s3_bucket_tuple, tuple))
print(isinstance(s3_bucket_tuple, tuple))  # Check if instance
print(callable(s3_bucket_tuple))  # Check if callable
# print(next(s3_bucket_tuple))  # Next element (Error: tuple is not iterator)
print(next(s3_bucket_tuple))  # Next element
print(iter(s3_bucket_tuple))  # Iterator of the tuple
print(next(iter(s3_bucket_tuple)))  # Next element

print(s3_bucket_tuple)
