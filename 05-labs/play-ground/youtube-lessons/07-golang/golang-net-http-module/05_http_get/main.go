package main

import (
	"fmt"
	"io"
	"net/http"
)

func main(){
	url := "https://jsonplaceholder.typicode.com/todos"

	resp, err := http.Get(url)
		if err != nil {
		panic(err)
	
	}
	

	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		panic(fmt.Sprintf("unexpected status code: %d", resp.StatusCode))
	}

	bodyBytes, err := io.ReadAll(resp.Body)
		if err != nil {
		panic(err)
	}
	
	bodyText := string(bodyBytes)

	max := 250
	if len(bodyText) < max {
		max = len(bodyText)
	}
	
	fmt.Println(bodyText[:max])

}