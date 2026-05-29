# GOPATH and module
GOROOT = where Go is installed
GOPATH = Where go code resides

## Initialize mod
Go Modules were introduced in Go 1.11 and enabled by default from 1.13.
With Go Modules, you can store your code anywhere on your system.

Initialize a go module:
```
go mod init testHello
```

Create a new Go file


## Go also can import remote modules use 
```
import (
    "<remote url>"
)
```

Get the remote module to import it. Use CLI to get it from remote
```
go get <remote url>
```


<br />

# GO variables

If you declare a variable but do not use it, the code will not compile.

## Short declaration
`:=` means is a local variable. Frequently used inside a function
```
a, b, c := 0
// Declare variables a, b, c as integers and assign an initial value of 0
a, b, c := 0, "", true
// Declare variables a, b, c as integer, string, and boolean, respectively
```


# Integers

Integers can be divided into `unsigned` and `signed` integers.

Unsigned can be divided into four sizes: 8 bits, 16 bits, 32 bits, 64bits represented by uint8, uint16, uint32, uint64.

| Type   | Description         | Range                                       |
|--------|---------------------|---------------------------------------------|
| uint8  | 8-bit unsigned int  | 0 to 255                                    |
| int8   | 8-bit signed int    | -128 to 127                                 |
| uint16 | 16-bit unsigned int | 0 to 65535                                  |
| int16  | 16-bit signed int   | -32768 to 32767                             |
| uint32 | 32-bit unsigned int | 0 to 4294967295                             |
| int32  | 32-bit signed int   | -2147483648 to 2147483647                   |
| uint64 | 64-bit unsigned int | 0 to 18446744073709551615                   |
| int64  | 64-bit signed int   | -9223372036854775808 to 9223372036854775807 |

# Char and var types are not the same
Using '' is for characters and "" used for strings.

In Go, a rune is an alias for the int32 type. While a byte (or uint8) is used to represent a single character of ASCII text, it is not large enough to hold Unicode characters, which can span many different languages and symbols (like emojis).

Here is a simple breakdown:

What exactly is a rune?
Capacity: Because it uses 32 bits, a rune can represent any Unicode Code Point.
Purpose: It distinguishes a "character" (a Unicode scalar value) from a "byte" (which is just a sequence of 8 bits).
Representation: In Go, you define a rune literal by surrounding a character with single quotes, e.g., 'a' or '🙈'.


# Strings

Two way to create a string:
`var a string = "Hello"`

b := "World!"

You can print them out by separating with comma

fmt.Println(a, b)

Escape characters also work like `\n`, `\t` `\\` and more.

To print out the string in the original format use the backtick (`) operator

Use len() function to count the number of strings.

Use `strconv` package's `Atoi` function to convert strings to integers.

Concatenate strings with Sprintf

```
c2 := fmt.Sprintf("%s%s", a, b)
```

Important packages when working with strings:
- fmt
- strconv
- strings
- utf8

### Strings Practice

```
package main

import (
	"fmt"
	"strings"
)

func formatUserName(fullName string) string {
	// TODO: Implement string manipulation to format user name
	a := strings.Trim(fullName, " ")
	b := strings.ToLower(a)
	c := strings.Title(b)
	return c

    // Also works in one row:
    // 	return strings.Title(strings.ToLower(strings.Trim(fullName, " ")))
}

func main() {
	fmt.Println(formatUserName("  john doe  "))        // Output: John Doe
	fmt.Println(formatUserName("  alice bob smith  ")) // Output: Alice Bob Smith
	fmt.Println(formatUserName("JANE DOE"))            // Output: Jane Doe
}

```