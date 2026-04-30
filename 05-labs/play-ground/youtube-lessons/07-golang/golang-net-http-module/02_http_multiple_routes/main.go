package main

import (
	"fmt"
	"net/http"
)

func rootHandler(w http.ResponseWriter, r *http.Request) {
	_, _ = w.Write([]byte("Welcome try to /hello?name=Ganil"))
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	name := r.URL.Query().Get("name")
	if name == "" {
		name = "Guest"
	}
	_, _ = w.Write([]byte(fmt.Sprintf("Hello, %s!", name)))
}

func main() {

	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/hello", helloHandler)


	err := http.ListenAndServe(":5000", nil)
	fmt.Println(err)
}