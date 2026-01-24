print("You are running num-1.py")

x = 5
y = 7

addition = x + y
subtraction = x - y
multiplication = x * y
division = x / y
modulus = x % y
exponentiation = x ** y
floor_division = x // y

print("Addition:", addition)
print("Subtraction:", subtraction)
print("Multiplication:", multiplication)
print("Division:", division)
print("Modulus:", modulus)
print("Exponentiation:", exponentiation)
print("Floor Division:", floor_division) 

# Integer
my_integer = 42
print(my_integer)

# Float
my_float = 3.14
print(my_float)

# Complex
my_complex = 2 + 3j
print(my_complex)


# List 
# Lists are mutable
my_list = [1, 2, 3, 4, 5, "six", "seven", "eight", "nine", "ten"]
print(my_list)

print(my_list[3])  # Print the fourth element

my_list[4] = "five"  # Change the fifth element
print(my_list)

my_list.append("eleven")  # Add an element to the end
print(my_list)

my_list.remove(2)  # Remove the element with value 2
print(my_list)
print("Length of the list:", len(my_list))  # Print the length of the list

# Tuple
# Tuples are immutable
my_tuple = (1, 2, 3, 4, 5, "six", "seven", "eight", "nine", "ten")
print(my_tuple)

print(my_tuple[3])  # Print the fourth element
# my_tuple[4] = "five"  # This will raise an error because tuples are immutable
print(my_tuple)

print("Length of the tuple:", len(my_tuple))  # Print the length of the tuple 

# Dictionary
# Dictionaries are mutable

person_dict = {'name': 'Alice', 'age': 30, 'city': 'New York'}
print(person_dict)

print(person_dict['name'])  # Access value by key 

person_dict['age'] = 31  # Update value by key
print(person_dict)

person_dict['country'] = 'USA'  # Add a new key-value pair
print(person_dict)

del person_dict['city']  # Remove a key-value pair
print(person_dict)

print("Length of the dictionary:", len(person_dict))  # Print the length of the dictionary # Set

# Sets are mutable and unordered
my_set = {1, 2, 3, 4, 5}
print(my_set)

my_set.add(6)  # Add an element
print(my_set)

my_set.remove(3)  # Remove an element
print(my_set)

print("Length of the set:", len(my_set))  # Print the length of the set

# Frozen Set
# Frozen sets are immutable 
my_frozen_set = frozenset([1, 2, 3, 4, 5])
print(my_frozen_set)

# my_frozen_set.add(6)  # This will raise an error because frozen sets are immutable

# Boolean 
is_true = True
is_false = False
print(is_true)
print(is_false)
print("is_true AND is_false:", is_true and is_false)
print("is_true OR is_false:", is_true or is_false)
print("NOT is_true:", not is_true)

# None Type
my_none = None
print(my_none)

# String
my_string = "Hello, World!"
print(my_string)

print(my_string[7])  # Print the eighth character
print(my_string.upper())  # Convert to uppercase
print(my_string.lower())  # Convert to lowercase  

print("Length of the string:", len(my_string))  # Print the length of the string


