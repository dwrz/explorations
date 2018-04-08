// Prints command line arguments and the name of the executed program.
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Println("ECHO: ")
	fmt.Println(strings.Join(os.Args, " "))
}
