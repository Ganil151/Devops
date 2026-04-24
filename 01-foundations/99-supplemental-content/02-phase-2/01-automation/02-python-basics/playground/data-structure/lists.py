# lists

s3_bucket_list = [
	"Alice_demo_bucket",
	"Bob_demo_bucket",
	"Charlie_demo_bucket",
	"David_demo_bucket"
]

# List methods

# add element
s3_bucket_list.append("Eve_demo_bucket")

# insert element at specific position
s3_bucket_list.insert(0, "Frank_demo_bucket")

# remove element by value 
s3_bucket_list.remove("Charlie_demo_bucket")

# remove element by index
s3_bucket_list.pop(2)

# sort list in ascending order
s3_bucket_list.sort()

# sort list in descending order
s3_bucket_list.reverse()

# clear all elements
s3_bucket_list.clear()

# copy list 
s3_bucket_list.copy()

# count occurrences of an element
s3_bucket_list.count("Alice_demo_bucket")

# find index of an element
# s3_bucket_list.index("Bob_demo_bucket")

print(s3_bucket_list) 