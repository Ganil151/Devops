package main

import "fmt"

func main() {
	points := map[string]int{
		"a": 10,
		"b": 0, // valid value
	}
	fmt.Printf("Points: %v\n", points)
	fmt.Printf("Points of a %v\n", points["a"])
	fmt.Printf("Points of b %v\n", points["b"])
	fmt.Printf("Points of c %v\n", points["c"]) // Does'nt exist

	// Using comma ok idiom to check if a key exists
	valB, okB := points["b"]
	fmt.Printf("Points of B is: %v, exists: %v\n", valB, okB)

	valC, okC := points["c"]
	fmt.Printf("Points of C is: %v, exists: %v\n", valC, okC)

	if val, exists := points["b"]; exists {
		fmt.Printf("Points of b %v\n", val)
	} else {
		fmt.Println("Key 'b' does not exist")
	}

	if val, exists := points["c"]; exists {
		fmt.Printf("Points of c %v\n", val)
	} else {
		fmt.Println("Key 'c' does not exist")
	}

	price := map[string]int{
		"xyz" : 500,
		"def" : 1800,
	}
	total := 0 
	for items, price := range price {
		fmt.Println(items, price)
		total += price
	}
	fmt.Printf("Total price: %v\n", total)

	for items := range price {
		fmt.Printf("Total of items: %v, Price: %v\n", items, price[items])
	}
}