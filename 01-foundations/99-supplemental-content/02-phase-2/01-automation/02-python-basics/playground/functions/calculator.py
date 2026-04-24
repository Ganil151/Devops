from _operator import mul
from _operator import sub
from _operator import add


num1 = 10
num2 = 5

addition1 = num1 + num2
print("Addition function:", addition1)
# or
addition = add(num1, num2)
print("Addition using operator.add function:", addition)

subtraction1 = num1 - num2
print("Subtraction function:", subtraction1)
# or
subtraction = sub(num1, num2)
print("Subtraction using operator.sub function:", subtraction)

multiplication1 = num1 * num2
print("Multiplication function:", multiplication1)
# or
multiplication = mul(num1, num2)
print("Multiplication using operator.mul function:", multiplication)

division1 = num1 / num2
print("Division function:", division1)
# The operator module does not have a div function, so we use the standard division operator

modulus1 = num1 % num2
print("Modulus using operator.mod function:", modulus1)
# The operator module does not have a mod function, so we use the standard modulus operator