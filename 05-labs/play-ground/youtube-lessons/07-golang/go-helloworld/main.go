package main

import (
	"fmt"
	"os"
)

func main() {
	args := os.Args

	if len(args) < 2 {
		fmt.Printf("Usage: ./hello-world <argument>\n")
		os.Exit(1)
	}
	fmt.Printf("Hello World🤡\n1th argument: %v\n", args, args[1:3])
}

// Stopped at https://youtu.be/aUrOXNN_WhI?t=2718

