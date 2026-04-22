package main

import (
	"fmt"
)

func main() {
	score := 72

	if score >= 90 {
		fmt.Println("Grade: A")
	} else if score >= 75 {
		fmt.Println("Grade: B")
	} else if score >= 45 {
		fmt.Println("Grade: C")
	} else {
		fmt.Println("Grade: D")
	}
}

// Stopped at https://youtu.be/DR4QhvIlFfQ?t=2340