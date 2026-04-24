package main 

import "fmt"

func main() {
	results := []string{"Alice", "Bob", "Charlie"}
	fmt.Println(results, results[0], results[len(results)-1]) 

	results[1] = "David"
	fmt.Println(results, results[1], results[len(results)-1])

	nums := []int{}
	nums = append(nums, 10)
	nums = append(nums, 20, 30)
	fmt.Println(nums)

	// Length and Capacity
	//make([]type, length, capacity)
	scores := make([]int, 0, 5)
	fmt.Printf("Length: %v\n", len(scores))
	fmt.Printf("Capacity: %v\n", cap(scores))

	scores = append(scores, 100)
	fmt.Printf("after appending 100: %v\n", scores)

	scores = append(scores, 200, 3000)
	fmt.Printf("after appending 200 and 3000: %v\n", scores)

	scores = append(scores, 45, 55)
					fmt.Printf("after appending 45 and 55: %v\n", scores)
					// if in case we are exceeding the capacity, go will automatically allocate more memory, usually doubling the capacity
					scores = append(scores, 60)
					fmt.Printf("after appending 60: %v, Length: %v, Capacity: %v\n", scores, len(scores), cap(scores))

	// Spread...
	todos := []string{"Buy groceries", "Walk the dog", "Finish the report"}
	more := []string{"Call mom", "Pay bills"}
	todos = append(todos, more...)
	fmt.Printf("Appending the spread in the array: %v\n", todos)

}