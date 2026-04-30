package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

func successHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	res := map[string]any{
		"ok": true,
		"message": "JSON encode successful",
		"datetime": time.Now().UTC(),
	}
	_ = json.NewEncoder(w).Encode(res)
}

func main() {

	http.HandleFunc("/ok", successHandler)


	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		fmt.Printf("Error starting Server: %v", err)
	}
}