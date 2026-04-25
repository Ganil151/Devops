package main 

import "fmt"

type User struct{
	ID int
	Name string
	Email string
	Age int
}

func main() {
	u1 := User{
		ID: 1,
		Name: "John Doe",
		Email: "john.doe@example.com",
		Age: 30,
	}
	fmt.Println("User 1:", u1, u1.ID, u1.Email, u1.Age)

	u1.Age = 48
	fmt.Println("User 1 after age update:", u1, u1.ID, u1.Email, u1.Age)

	// Partial
	u2 := User{
		Name: "Chuck",
		Email: "chuck.norris@example.com",
	}
	fmt.Println("partial", u2)
}

