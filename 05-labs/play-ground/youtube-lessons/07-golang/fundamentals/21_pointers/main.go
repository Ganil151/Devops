// Pointer 
package main

import "fmt"

func main() {
	score := 10
	fmt.Println("Original score:", score)
	addScore(&score)
	fmt.Println("After score:", score)
}

func addScore(score *int) {
	*score += 5

}