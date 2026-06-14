package main

import "fmt"

// You can traverse a two dimensional array using the 
// range keyword or index numbers.
// The following example demonstrates both methods.
// With this concept you can create a multi dimensional array 
// of any size and traverse it using the range keyword or index numbers.

func main() {
	a := [...][]int{{123, 321, 222}, {404, 501, 503}, {857, 419, 857}}
	// Method 1: using the range keyword
	fmt.Println("Traversing the Two-Dimensional Array Using the range Keyword")
	for _, value := range a {
		for _, j := range value {
			fmt.Println(j)
		}
	}
	fmt.Println(a)
	// Method 2: using index numbers
	fmt.Println("\nTraversing the Two-Dimensional Array Using Index Numbers")
	for i := 0; i < len(a); i++ {
		for j := 0; j < len(a[i]); j++ {
			fmt.Println(a[i][j])
			a[i][j] = 0
		}
	}
	fmt.Println(a)
}
