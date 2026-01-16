package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
)

// DevOps Context: Parsing Terraform state files and API responses

type TerraformState struct {
	Version          int                    `json:"version"`
	TerraformVersion string                 `json:"terraform_version"`
	Resources        []Resource             `json:"resources"`
	Outputs          map[string]OutputValue `json:"outputs"`
}

type Resource struct {
	Mode string `json:"mode"`
	Type string `json:"type"`
	Name string `json:"name"`
	Instances []Instance `json:"instances"`
}

type Instance struct {
	Attributes map[string]interface{} `json:"attributes"`
}

type OutputValue struct {
	Value interface{} `json:"value"`
	Type  string     `json:"type"`
}

func main() {
	// Simulated Terraform state JSON
	stateJSON := `{
		"version": 4,
		"terraform_version": "1.5.0",
		"resources": [
			{
				"mode": "managed",
				"type": "aws_instance",
				"name": "web_server",
				"instances": [
					{
						"attributes": {
							"id": "i-1234567890abcdef0",
							"instance_type": "t3.micro",
							"public_ip": "54.123.45.67"
						}
					}
				]
			}
		],
		"outputs": {
			"instance_id": {
				"value": "i-1234567890abcdef0",
				"type": "string"
			}
		}
	}`

	// Parse JSON
	var state TerraformState
	if err := json.Unmarshal([]byte(stateJSON), &state); err != nil {
		log.Fatalf("Failed to parse state: %v", err)
	}

	// Extract information
	fmt.Println("=== Terraform State Analysis ===")
	fmt.Printf("Terraform Version: %s\n", state.TerraformVersion)
	fmt.Printf("Resource Count: %d\n\n", len(state.Resources))

	for _, res := range state.Resources {
		fmt.Printf("Resource: %s.%s\n", res.Type, res.Name)
		for _, inst := range res.Instances {
			fmt.Printf("  ID: %v\n", inst.Attributes["id"])
			fmt.Printf("  Type: %v\n", inst.Attributes["instance_type"])
			fmt.Printf("  Public IP: %v\n", inst.Attributes["public_ip"])
		}
	}

	// Generate modified state (add tag)
	fmt.Println("\n=== Modifying State ===")
	if len(state.Resources) > 0 && len(state.Resources[0].Instances) > 0 {
		attrs := state.Resources[0].Instances[0].Attributes
		if attrs["tags"] == nil {
			attrs["tags"] = make(map[string]interface{})
		}
		tags := attrs["tags"].(map[string]interface{})
		tags["Environment"] = "production"
		tags["ManagedBy"] = "terraform"
	}

	// Marshal back to JSON
	output, err := json.MarshalIndent(state, "", "  ")
	if err != nil {
		log.Fatalf("Failed to marshal state: %v", err)
	}

	fmt.Println("Modified state:")
	fmt.Println(string(output))
	
	// Write to file
	if err := os.WriteFile("terraform.tfstate", output, 0644); err != nil {
		log.Fatalf("Failed to write state file: %v", err)
	}
	fmt.Println("\n✅ State file written to terraform.tfstate")
}
