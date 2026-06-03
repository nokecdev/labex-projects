package main

import (
	"fmt"
	"strings"
)

func ReverseString(input string) string {
	var c strings.Builder
	for i := len(input) - 1; i >= 0; i-- {
		c.WriteString(string(input[i]))
	}
	return c.String()
}

func main() {
	// Example usage
	original := "hello world!"
	reversed := ReverseString(original)
	fmt.Printf("Original: %s\n", original)
	fmt.Printf("Reversed: %s\n", reversed)
}
