package main

import (
	"errors"
	"fmt"
)

func main() {
	fmt.Println("Case 1: success")
	if err := doWork(true); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
	fmt.Println("Case 2: fail early")
	if err := doWork(false); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}

func doWork(success bool) error {


	fmt.Println("start: resource acquired")

	defer fmt.Println("cleanup: resource released")

	if !success {
		return errors.New("Something went wrong, resource not acquired")
	}
	fmt.Println("work: doing something important")
	fmt.Println("work: this work is done")
	return nil
}

