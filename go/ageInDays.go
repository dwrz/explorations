package main

import (
	"fmt"
	"math"
	"os"
	"time"
)

func main() {
	dob, err := time.Parse("20060102", os.Args[1])
	if err != nil {
		fmt.Println("UNABLE TO PARSE INPUTTED DATE.")
		os.Exit(1)
	}
	elapsedDays := int(math.Round(time.Since(dob).Hours() / 24))
	fmt.Printf("YOU ARE ~%d DAYS OLD.", elapsedDays)
	return
}
