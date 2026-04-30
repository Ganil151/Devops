package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type CatFactResponse struct{
		Fact string `json:"fact"`
		Length int 	`json:"length"`
}

func main() {
	url := "https://catfact.ninja/fact"

	resp, err := http.Get(url)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer resp.Body.Close()

	// Check the Status Code
	if resp.StatusCode != http.StatusOK {
		fmt.Printf("Unexpected status code: %d\n", resp.StatusCode)
		return
	}

	// Read the response body
	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println("Error reading response body:", err)
		return
	}

	// Unmarshal the JSON into a struct
	var data CatFactResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		fmt.Println("Error unmarshaling JSON:", err)
		return
	}

	// Print the fact
	fmt.Println(data.Fact, data.Length)
}

// Stopped at: https://youtu.be/DR4QhvIlFfQ?t=13333