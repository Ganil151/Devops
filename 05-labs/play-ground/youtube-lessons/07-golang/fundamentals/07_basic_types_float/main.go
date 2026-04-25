package main

import (
	"fmt"
)

func main() {
	// Integers Types
	views1 := 1000
	views2 := 2000
	totalViews := views1 + views2

	likes := 10
	likes++
	likes++

	avgViews := totalViews / 2 

	// Floats Types
	ratings1 := 4.5
	ratings2 := 5.1
	avgRatings := (ratings1 + ratings2) / 2

	fmt.Printf(
		"Total Views: %v\nLikes: %v\nAverage Views: %v\nAverage Ratings: %v\n", totalViews, likes, avgViews, avgRatings,
	)
}