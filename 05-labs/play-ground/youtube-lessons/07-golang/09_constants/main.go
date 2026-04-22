package main

import (
	"fmt"
)

func main() {
	// Constants are the values that don't change
	const appName = "Go Basics"

	// Type Constants
	const maxUpload int = 25
	const discountPrice float64 = 10.3

	fmt.Println("App Name:", "%v\nMax Load:", "%v\nDiscount Price:", appName,maxUpload, discountPrice)

}