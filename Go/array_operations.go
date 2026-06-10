package main

import "fmt"

func main() {
	//We can define an array like:

	//This will create an array with a capacity of 10.
	//var a [10]int

	// Initialize an array of two values
	var numArray = [3]int{1, 2}
	fmt.Println(numArray)
	// Initialize an array of two strings
	var cityArray = [2]string{"London", "Paris"}
	fmt.Println(cityArray)

	// Inferred length initialization. The compiler will infer the array based on the initial values.
	var inferredArray = [...]string{"London", "Paris"}
	fmt.Printf("Inferred array: ")
	fmt.Println(inferredArray)

	// Initialize with specified indices
	a := [...]int{1: 1, 3: 5}
	fmt.Println("Initialize with specified indices")
	fmt.Println(a)
	fmt.Printf("The type of array a is: %T\n", a) // The type of array a is: [4]int

	// Array traversal

	arr := [...]int{123, 321, 456, 777}
	// Method 1: range
	fmt.Println("Traversing the array using range")
	for index, value := range arr {
		fmt.Println(index, " ", value)
	}
	// Method 2: using indices
	fmt.Println("\nTraversing the array using indices")
	for i := 0; i < len(a); i++ {
		fmt.Println(a[i])
	}

	// Modifying array elements will copy the values of a copy not the original array.
}
