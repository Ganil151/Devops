package main

import "fmt"

func main() {
	// var statement
	var city string
	city = "Jersey City"
	
	// short variable declaration
	subscribers := 5000
	subscribers = subscribers + 1000
	likes,comments := 100,30
	likes = likes + 300
	comments = comments + 5
	fmt.Printf(
		"subscribers: %v\ncity:  %v\nlikes: %v\ncomments: %v\n", 
		subscribers, 
		city,
		likes,
		comments,
	)
}