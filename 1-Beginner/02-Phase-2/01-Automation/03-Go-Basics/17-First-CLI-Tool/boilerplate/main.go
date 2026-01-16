package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

// DevOps Context: Often we need to wrap existing binaries (like kubectl, terraform, or git)
// to build higher-level automation workflows.

func main() {
	// Task: Check if 'git' is installed and get the version.
	// This simulates a "Pre-flight Check" in a setup script.

	cmdName := "git"
	cmdArgs := []string{"version"}

	// 1. Prepare Command
	cmd := exec.Command(cmdName, cmdArgs...)

	// 2. Execute and Capture Output
	output, err := cmd.Output()
	if err != nil {
		if strings.Contains(err.Error(), "executable file not found") {
			log.Fatalf("❌ Error: %s is not installed or not in PATH.", cmdName)
		}
		log.Fatalf("❌ Command failed: %v", err)
	}

	// 3. Process Output
	versionStr := strings.TrimSpace(string(output))
	fmt.Printf("✅ Pre-flight check passed.\n")
	fmt.Printf("Found Tool: %s\n", versionStr)

	// Example 2: Running a command that might not exist (Simulating failure)
	fmt.Println("\nAttempting to run a missing tool...")
	fakeCmd := exec.Command("terraform-fake", "version")
	if _, err := fakeCmd.Output(); err != nil {
		fmt.Printf("⚠️  Expected error caught: %v\n", err)
	}
}
