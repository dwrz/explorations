// Calculate days elapsed (age) from an inputted date to the present moment.
//
// The days of our years are threescore years and ten;
// and if by reason of strength they be fourscore years,
// yet is their strength labour and sorrow;
// for it is soon cut off, and we fly away.
// . . .
// Teach us to number our days,
// that we may gain a heart of wisdom.
//
// Psalm 90:10
package main

import (
	"errors"
	"fmt"
	"log"
	"math"
	"net/http"
	"os"
	"time"
)

func main() {
	if len(os.Args) <= 1 {
		fmt.Println("PLEASE ENTER A DATE IN YYYYMMDD FORMAT.")
		fmt.Printf("EG: %s FOR TODAY'S DATE.", time.Now().Format("20060102"))
		os.Exit(1)
	}
	calcAgeInDays()
}

func calcAgeInDays () {
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
