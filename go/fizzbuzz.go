package main

import "fmt"

func main() {
	for i := 1; i <= 100; i++ {
		if i%5 == 0 && i%3 == 0 {
			fmt.Println("*FIZZ-BUZZ*")
		} else if i%3 == 0 {
			fmt.Println("FIZZ!")
		} else if i%5 == 0 {
			fmt.Println("BUZZ!")
		} else {
			fmt.Println(i)
		}
	}
}
