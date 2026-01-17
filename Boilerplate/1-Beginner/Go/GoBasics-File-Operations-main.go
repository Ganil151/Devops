package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
)

// DevOps Context: Analyzing log files or config directories is a daily task.
// This boilerplate scans a directory, reads specific files, and checks permissions.

func main() {
	// 1. Define the target directory (DevOps: usually /var/log or /etc)
	targetDir := "./logs"
	
	// Ensure the directory exists for this demo
	if err := os.MkdirAll(targetDir, 0755); err != nil {
		log.Fatalf("Failed to create mock directory: %v", err)
	}
	defer os.RemoveAll(targetDir) // Cleanup (optional for boilerplate)

	// Create a dummy log file
	dummyFile := filepath.Join(targetDir, "service.log")
	content := []byte("ERROR: Connection timeout\nINFO: Service started\n")
	if err := ioutil.WriteFile(dummyFile, content, 0644); err != nil {
		log.Fatalf("Failed to write log file: %v", err)
	}

	// 2. Walk the directory to find files
	err := filepath.Walk(targetDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip directories
		if info.IsDir() {
			return nil
		}

		fmt.Printf("found file: %s (Size: %d bytes)\n", info.Name(), info.Size())

		// 3. Read File Content (DevOps: Log Analysis)
		data, err := ioutil.ReadFile(path)
		if err != nil {
			log.Printf("Error reading file %s: %v", path, err)
			return nil // Continue walking
		}

		fmt.Println("--- content review ---")
		fmt.Println(string(data))
		fmt.Println("----------------------")

		return nil
	})

	if err != nil {
		log.Fatalf("Error walking directory: %v", err)
	}
}
