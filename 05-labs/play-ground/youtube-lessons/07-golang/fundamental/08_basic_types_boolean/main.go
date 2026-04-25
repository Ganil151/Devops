package main 

import (
	"fmt"
)

func main() {
	// Boolean Types
	isLogged := true;
	isAdmin := false;
	hasSubscription := true;

	// AND &&
	canOpenDashboard := isLogged && hasSubscription
	canDeletePost := isAdmin || (isLogged && hasSubscription)

	age := 25
	isAdult := age >= 18

	fmt.Printf("Is Logged: %v\nIs Admin: %v\nHas Subscription: %v\nCan Open Dashboard: %v\nCan Delete Post: %v\nIs Adult: %v\n", isLogged, isAdmin, hasSubscription, canOpenDashboard, canDeletePost, isAdult)

}