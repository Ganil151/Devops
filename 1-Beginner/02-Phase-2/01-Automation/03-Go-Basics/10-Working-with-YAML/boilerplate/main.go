package main

import (
	"fmt"
	"log"
	"os"

	"gopkg.in/yaml.v3"
)

// DevOps Context: Parsing Docker Compose and Kubernetes manifests

type DockerCompose struct {
	Version  string             `yaml:"version"`
	Services map[string]Service `yaml:"services"`
	Networks map[string]Network `yaml:"networks,omitempty"`
	Volumes  map[string]Volume  `yaml:"volumes,omitempty"`
}

type Service struct {
	Image       string            `yaml:"image"`
	Ports       []string          `yaml:"ports,omitempty"`
	Environment map[string]string `yaml:"environment,omitempty"`
	Volumes     []string          `yaml:"volumes,omitempty"`
	DependsOn   []string          `yaml:"depends_on,omitempty"`
}

type Network struct {
	Driver string `yaml:"driver,omitempty"`
}

type Volume struct {
	Driver string `yaml:"driver,omitempty"`
}

func main() {
	// Sample Docker Compose YAML
	composeYAML := `
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      NGINX_HOST: example.com
      NGINX_PORT: "80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - api
  api:
    image: node:18-alpine
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DB_HOST: postgres
    depends_on:
      - db
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
    driver: local
`

	// Parse YAML
	var compose DockerCompose
	if err := yaml.Unmarshal([]byte(composeYAML), &compose); err != nil {
		log.Fatalf("Failed to parse compose file: %v", err)
	}

	// Analyze services
	fmt.Println("=== Docker Compose Analysis ===")
	fmt.Printf("Version: %s\n", compose.Version)
	fmt.Printf("Services: %d\n\n", len(compose.Services))

	for name, svc := range compose.Services {
		fmt.Printf("Service: %s\n", name)
		fmt.Printf("  Image: %s\n", svc.Image)
		if len(svc.Ports) > 0 {
			fmt.Printf("  Ports: %v\n", svc.Ports)
		}
		if len(svc.DependsOn) > 0 {
			fmt.Printf("  Dependencies: %v\n", svc.DependsOn)
		}
		fmt.Println()
	}

	// Modify and export
	fmt.Println("=== Adding New Service ===")
	compose.Services["redis"] = Service{
		Image: "redis:7-alpine",
		Ports: []string{"6379:6379"},
	}

	// Marshal back to YAML
	output, err := yaml.Marshal(&compose)
	if err != nil {
		log.Fatalf("Failed to marshal compose: %v", err)
	}

	if err := os.WriteFile("docker-compose.yml", output, 0644); err != nil {
		log.Fatalf("Failed to write file: %v", err)
	}

	fmt.Println("✅ Updated docker-compose.yml written")
}
