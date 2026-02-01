numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
for number in numbers:
    if number == 3:
        break
    print(number)
# Output:
# 1
# 2
print("Loop ended due to break statement.")
# Loop ended due to break statement.

for number in numbers:
    if number == 3:
        continue
    print(number)
# Output:
# 1
# 2
# 4
# 5
# 6
# 7
# 8
# 9
# 10
print("Loop ended after skipping number 3.")
# Loop ended after skipping number 3.

for number in numbers:
    if number == 3:
        pass
    print(number)
# Output:
# 1
# 2
# 3   
# 4
# 5
# 6
# 7
# 8
# 9
# 10
print("Loop ended after passing number 3.")
# Loop ended after passing number 3.

for number in numbers:
    print(number)
else:
    print("Loop completed without break.")
# Output:
# 1
# 2   
# 3
# 4
# 5     
# 6
# 7
# 8
# 9
# 10
# Loop completed without break. 

for number in numbers:
    print(number)
    if number == 3:
        break
else:
    print("Loop completed without break.")
# Output:
# 1
# 2
# 3 
print("Loop ended due to break statement.")
# Loop ended due to break statement.

for number in numbers:
    print(number)
    if number == 11:
        break
else:
    print("Loop completed without break.")
# Output:
# 1
# 2
# 3
# 4   
# 5
# 6
# 7
# 8
# 9
# 10    
# Loop completed without break. 

for number in numbers:
    print(number)
    if number == 11:
        continue
else:
    print("Loop completed without break.")
# Output: 
# 1
# 2   
# 3
# 4
# 5
# 6
# 7
# 8
# 9
# 10
# Loop completed without break.
