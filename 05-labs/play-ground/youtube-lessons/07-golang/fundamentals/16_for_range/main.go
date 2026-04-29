package main

import "fmt"

func main() {
	views := []int{10, 20, 45, 50, 60}

	total := 0
	for i, v := range views{
		fmt.Printf("Day: %v, Views: %v\n", i, v)
		total += v
	}
	fmt.Printf("Total views: %v\n", total)
}