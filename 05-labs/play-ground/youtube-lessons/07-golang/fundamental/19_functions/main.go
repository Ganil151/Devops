// return function
package main

import (
	"fmt"
	"log"
	"strconv"
)

func add(a int, b int) int{
	return a + b
}

func SumAndProduct(a int, b int) (int, int) {
	sum2 := a + b
	product := a * b
	return  sum2, product
}

// Named return values
func divided(a, b int) (chuck int, ganil int) {
	chuck = a / b
	ganil = a + b
	return
}

// Variadic functions
func sumAll(nums ...int) int{
	total := 0

	for _, currentValue := range nums {
		total = total + currentValue
	}
	return total
}



func main() {
	sum1 := add(10, 20)
	sum2, product := SumAndProduct(10, 20)
	fmt.Printf("The sum of one is: %v, and sum two is: %v, and the product is: %v\n", sum1, sum2, product)

	// Or use a placeholder
	onlySum, _ := SumAndProduct(10, 2)
	fmt.Printf("The sum is: %v\n", onlySum)

	q, r := divided(10, 10)
	fmt.Printf("The quotient is: %v, and the remainder is: %v\n", q, r)

	total := sumAll(1, 2, 3, 4, 5)
	fmt.Printf("The sum of all numbers is: %v\n", total)

	values := []int{1, 2, 3, 4, 5}
	total2 := sumAll(values...)
	fmt.Printf("The sum of all numbers is: %v\n", total2)

	res := func(n int) int {
		return n * 2
	}
	fmt.Println(res(2))

	// Immediately invoked function expression (IIFE)
	res1 := func(a, b int) int{
		return a + b
	}(13, 33)

	fmt.Println(res1)
	
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

// Return Error
func run() error {
	input := "3"

	level, err := parseLevel(input)
	if err != nil {
		return err
	}
	fmt.Printf("The level is: %v\n", level)
	return nil
}

func parseLevel(s string) (int, error) {
	n, err := strconv.Atoi(s)
	if err != nil {
		return 0, fmt.Errorf("level must be a number: %s")
	}

	if n < 1 || n > 5 {
		return 0, fmt.Errorf("level must be between 1 and 5")
	}
	return n, nil
}

