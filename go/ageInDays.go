package main

import (
	"fmt"
	"math"
	"os"
	"time"
)

func main() {
	if len(os.Args) <= 1 {
		fmt.Println("PLEASE ENTER A DATE IN YYYYMMDD FORMAT.")
		fmt.Printf("EG: %s FOR TODAY'S DATE.", time.Now().Format("20060102"))
		os.Exit(1)
	}
	dob, err := time.Parse("20060102", os.Args[1])
	if err != nil {
		fmt.Println("UNABLE TO PARSE INPUTTED DATE.")
		os.Exit(2)
	}
	fmt.Printf("YOU ARE ~%d DAYS OLD.", calcElapsedDays(dob))
	return
}

func calcElapsedDays(date time.Time) int {
	return int(math.Round(time.Since(date).Hours() / 24))
}
