import sys

type = sys.argv[1]

if type == "t2.micro":
    print("You have selected the t2.micro instance.")
elif type == "t2.small":
    print("You have selected the t2.small instance.")
elif type == "t2.medium":
    print("You have selected the t2.medium instance.")
else:
    print("The selected instance type is not recognized.")
    sys.exit(1)

sys.exit(0)