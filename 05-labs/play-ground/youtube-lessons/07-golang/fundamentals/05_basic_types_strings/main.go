package main

import (
	"fmt"
	"strings"
)

func main() {
	firstName := "Chuck"
	lastName := "Brown"
	fullName := firstName + " " + lastName
	fmt.Printf("%v\n", fullName)

	fmt.Println(strings.ToUpper(fullName))
}