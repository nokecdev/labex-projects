/*
Task:
Implement the filterLogs function that takes a slice of log entries and a keyword.
The function should return a new slice containing only the message content of log entries that include the specified keyword.
Ensure the function is case-sensitive.
Use Go slice operations to filter and process the log entries.
Handle empty slices and empty keywords gracefully.

Expected Output:
Error Logs: [Security breach detected Disk is almost full]
Warning Logs: [Unauthorized access attempt System temperature too high]
Info Logs: [System startup completed User login]

*/
package main

import (
	"fmt"
	"strings"
)

func filterLogs(logs []string, keyword string) []string {
	var formatted []string

	for _, log := range logs {
		parts := strings.SplitN(log, keyword+": ", 2)
		if len(parts) < 2 {
			continue
		}

		formatted = append(
			formatted,
			fmt.Sprintf("%s", parts[1]),
		)
	}

	return formatted
}

func main() {
	// Sample log entries
	logs := []string{
		"2023-06-15 ERROR: Security breach detected",
		"2023-06-15 INFO: System startup completed",
		"2023-06-15 WARN: Unauthorized access attempt",
		"2023-06-15 ERROR: Disk is almost full",
		"2023-06-15 INFO: User login",
		"2023-06-15 WARN: System temperature too high",
	}

	// Test filterLogs with different keywords
	errorLogs := filterLogs(logs, "ERROR")
	fmt.Println("Error Logs:", errorLogs)

	warningLogs := filterLogs(logs, "WARN")
	fmt.Println("Warning Logs:", warningLogs)

	infoLogs := filterLogs(logs, "INFO")
	fmt.Println("Info Logs:", infoLogs)
}
