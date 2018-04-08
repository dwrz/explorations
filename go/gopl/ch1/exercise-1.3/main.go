// Measure the difference in running time for implementions of the 'echo' program.
package main

import (
	"fmt"
	"os"
	"strings"
	"time"
)

func main() {
	fmt.Println("RUNNING FORLOOP:")
	forLoop()
	fmt.Println("RUNNING JOINER:")
	joiner()
}

func forLoop() {
	start := time.Now()
	s, sep := "", ""
	for _, arg := range os.Args[1:] {
		s += sep + arg
		sep = " "
	}
	fmt.Println(s)
	fmt.Println(time.Since(start))
}

func joiner() {
	start := time.Now()
	fmt.Println(strings.Join(os.Args[1:], " "))
	fmt.Println(time.Since(start))
}
