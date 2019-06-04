package main

import (
	"fmt"
	"sync"
)

type User struct {
	Id      string
	Account // NB: just type, not field name and type.
}

type Account struct {
	Balance    int
	sync.Mutex // NB: Again -- just the type, which is public.
}

func (a *Account) UpdateBalance(adjustment int) {
	a.Balance += adjustment
}

func main() {
	var user User

	user.Account.Balance = 2
	fmt.Println(user.Account.Balance) // 2

	// Since it's embedded...
	user.Balance = 8                  // Embedded field.
	fmt.Println(user.Balance)         // 8
	fmt.Println(user.Account.Balance) // 8

	// Let's apply some concurrent adjustments to the balance.
	// The sum of these adjustments is 0.
	// We should see no changes in balance at the end.
	var adjustments = []int{
		-8, -4, -2, 0, 2, 4, 8,
		-8, -4, -2, 0, 2, 4, 8,
		-8, -4, -2, 0, 2, 4, 8,
		-8, -4, -2, 0, 2, 4, 8,
		-8, -4, -2, 0, 2, 4, 8,
		-8, -4, -2, 0, 2, 4, 8,
	}

	var wg sync.WaitGroup
	wg.Add(len(adjustments))

	for _, adjustment := range adjustments {
		go func(adjustment int) {
			defer wg.Done()

			// With the mutex, only one goroutine at a time
			// will execute the CRITICAL SECTION.

			user.Lock()                    // Embedded mutex method!
			user.UpdateBalance(adjustment) // CRITICAL SECTION
			user.Unlock()                  // Embedded mutex method!

		}(adjustment)
	}

	wg.Wait() // Block until all goroutines finish.

	fmt.Println(user.Balance) // 8... if the mutex is used.

	// Try commenting out the Lock() and Unlock() calls.
	// You'll occasionally see a different final balance.
}
