package main 

import (
	"fmt"
)

func main() {
	for i := 1; i <= 5; i++ {
		fmt.Println("The Value is:", i)
	}

	N := 10
	sum := 0
	for i := 1; i <= N; i++ {
		sum += i
	}
	fmt.Printf("The Value is: %v\n", sum)
}