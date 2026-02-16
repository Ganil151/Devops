import sys


def addition(num1, num2):
    add = num1 + num2
    return add


def subtraction(num1, num2):
    sub = num1 - num2
    return sub


def multiplication(num1, num2):
    mul = num1 * num2
    return mul


def division(num1, num2):
    div = num1 / num2
    return div


def modulus(num1, num2):
    mod = num1 % num2
    return mod
    

num1 = float(sys.argv[1])
operation = sys.argv[2]
num2 = float(sys.argv[3])
if operation == "add":
    output = addition(float(num1), float(num2))
    print(output)
elif operation == "sub":
    output = subtraction(float(num1), float(num2))
    print(output)
elif operation == "mul":
    output = multiplication(float(num1), float(num2))
    print(output)
elif operation == "div":
    output = division(float(num1), float(num2))
    print(output)
elif operation == "mod":
    output = modulus(int(num1), int(num2))
    print(output)
else:
    print("Invalid operation")

