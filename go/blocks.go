package main

import (
	"fmt"
)

func main() { // Prints "hello world!"
	s := "!"
	{
		s := "hello"
		fmt.Printf(s)
	}
	fmt.Printf(" ")
	{
		s := "world"
		fmt.Printf(s)
	}
	fmt.Printf(s)
}
