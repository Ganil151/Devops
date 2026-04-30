package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

func writeJSON(w http.ResponseWriter, status int, data any){
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	// Implementation for writing JSON response
	_ = json.NewEncoder(w).Encode(data)
}

type TestRequest struct {
	Name string `json:"name"`
}

func testHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]any{
			"ok": false, 
			"message": "Method not allowed"})
		return
	}
	defer r.Body.Close()

	var req  TestRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"ok": false,
			"message": "Invalid JSON"})
		return
	}
	req.Name = strings.TrimSpace(req.Name)
	if req.Name == "" {
		writeJSON(w, http.StatusBadRequest, map[string]any{
			"ok": false,
			"message": "Name is required"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"ok": true,
		"message": "Success",
		"data": req,
		"timestamp": time.Now().UTC(),
	})
}


func main() {

	http.HandleFunc("/test", testHandler)


	err := http.ListenAndServe(":5000", nil)
	if err != nil {
		fmt.Println("Error no network connection", err)
	}
}