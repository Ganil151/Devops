package main

import (
	"fmt"
)

func main() {
	items := 2;
	pricePerItem := 49;
	if total := items * pricePerItem; total >= 100 {
		fmt.Println("Eligible for shipping")
	} else {
		fmt.Println("Not Eligible for shipping ***")
	}
}