package main

import (
	"bytes"
	"fmt"
)

func main() {
	in := new(bytes.Buffer)
	in.WriteString("hello world")
	fmt.Println("IN: ", in) // "IN: hello world"
	out := new(bytes.Buffer)
	fmt.Println("OUT: ", out)                                    // "OUT: "
	fmt.Println("EQUAL: ", bytes.Equal(in.Bytes(), out.Bytes())) // "EQUAL: false"
	fmt.Println("-------")
	in.WriteTo(out)
	fmt.Println("IN: ", in)                                      // "IN: "
	fmt.Println("OUT: ", out)                                    // "OUT: hello world"
	fmt.Println("EQUAL: ", bytes.Equal(in.Bytes(), out.Bytes())) // "EQUAL: false"
	fmt.Println("-------")
	in.WriteString("hello world")
	fmt.Println("IN: ", in)                                      // "IN: hello world"
	fmt.Println("OUT: ", out)                                    // "OUT: hello world"
	fmt.Println("EQUAL: ", bytes.Equal(in.Bytes(), out.Bytes())) // "EQUAL: true"
	fmt.Println("-------")
	in.Truncate(5)
	fmt.Println("IN: ", in)                                      // "IN: hello"
	fmt.Println("OUT: ", out)                                    // "OUT: hello world"
	fmt.Println("EQUAL: ", bytes.Equal(in.Bytes(), out.Bytes())) // "EQUAL: false"
	fmt.Println("-------")
	out.WriteString(" ")
	in.WriteTo(out)
	fmt.Println("IN: ", in)                                      // "IN: "
	fmt.Println("OUT: ", out)                                    // "OUT: hello world hello"
	fmt.Println("EQUAL: ", bytes.Equal(in.Bytes(), out.Bytes())) // "EQUAL: false"
	fmt.Println("-------")
	fmt.Println("BYTES: ")
	fmt.Println("IN: ", in.Bytes())
	fmt.Println("OUT: ", out.Bytes())
	fmt.Println("--------")
}
