#!/bin/bash

# Define Functions
add() {
	echo "Sum: $(( $1 + $2 ))"
}

subtract() {
	echo "Difference: $(( $1 - $2 ))"
}

multiply() {
	echo "Products: $(( $1 * $2 ))"
}

# Call Functions
add 10 5
subtract 10 9
multiply 20 17
