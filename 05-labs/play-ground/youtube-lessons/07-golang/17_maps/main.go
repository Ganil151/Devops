package main 

import "fmt"

func main() {
	// map[key-type]value-type

	ages := map[string]int{
		"Alice": 25,
		"Bob":   30,
		"Charlie": 35,
	}
	fmt.Printf("Alice: %v, Bob: %v, Charlie: %v, Count: %v\n", ages["Alice"], ages["Bob"], ages["Charlie"], len(ages))

	// make(map[K]V)
	var scores map[string]int //V nil map
	fmt.Println(scores, scores["a"])

	scores = make(map[string]int)
	scores["Alice"] = 85
	scores["Bob"] = 90
	scores["Charlie"] = 95
	fmt.Printf("Alice: %v, Bob: %v, Charlie: %v, Count: %v\n", scores["Alice"], scores["Bob"], scores["Charlie"], len(scores))

	// Delete in map
	users := map[string]string{
		"user1": "Alice",
		"user2": "Bob",
		"user3": "Charlie",
	}
	fmt.Printf("Users: %v\n", users)
	delete(users, "user2") // Delete user2
	fmt.Printf("Users: %v, Count: %v\n", users, len(users))
}