package main 

import "fmt"
// Arrays
func main() {
	// Arrays are fixed and can not grow

	var marks [3]int
	marks[0] = 10
	marks[1] = 20
	marks[2] = 50

	fmt.Println(marks)

	// Array literals
	res := [5]int{1, 2, 3, 4, 5}
	fmt.Println(len(res))
}