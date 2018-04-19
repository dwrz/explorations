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

func calcAgeInDays(date string) (int, error) {
	dob, err := time.Parse("20060102", date)
	if err != nil {
		return 0, errors.New("UNABLE TO PARSE INPUTTED DATE.")
	}
	return calcElapsedDays(dob), nil
}

func calcElapsedDays(date time.Time) int {
	return int(math.Round(time.Since(date).Hours() / 24))
}

func server(w http.ResponseWriter, r *http.Request) {
	age, err := calcAgeInDays(r.URL.Path[1:])
	if err != nil {
		fmt.Println(err)
		fmt.Fprintf(w, "UNABLE TO PARSE THAT DATE.")
		return
	}
	fmt.Fprintf(w, "YOU ARE ~%d DAYS OLD.", age)
	return
}
