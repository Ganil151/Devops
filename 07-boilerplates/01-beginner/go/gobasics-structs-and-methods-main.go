package main

import (
	"fmt"
	"time"
)

// DevOps Context: Modeling infrastructure resources as structs

type Server struct {
	ID       string
	Hostname string
	IP       string
	Status   string
	Uptime   time.Duration
	Tags     map[string]string
}

// Methods for server operations
func (s *Server) Start() error {
	if s.Status == "running" {
		return fmt.Errorf("server %s already running", s.ID)
	}
	s.Status = "running"
	fmt.Printf("✅ Started server %s (%s)\n", s.ID, s.Hostname)
	return nil
}

func (s *Server) Stop() error {
	if s.Status == "stopped" {
		return fmt.Errorf("server %s already stopped", s.ID)
	}
	s.Status = "stopped"
	fmt.Printf("🛑 Stopped server %s (%s)\n", s.ID, s.Hostname)
	return nil
}

func (s *Server) GetInfo() string {
	return fmt.Sprintf("Server(ID=%s, Host=%s, IP=%s, Status=%s, Uptime=%s)",
		s.ID, s.Hostname, s.IP, s.Status, s.Uptime)
}

func (s *Server) AddTag(key, value string) {
	if s.Tags == nil {
		s.Tags = make(map[string]string)
	}
	s.Tags[key] = value
	fmt.Printf("🏷️  Added tag to %s: %s=%s\n", s.ID, key, value)
}

func main() {
	// Create server instance
	srv := &Server{
		ID:       "srv-001",
		Hostname: "web-prod-01",
		IP:       "10.0.1.10",
		Status:   "stopped",
		Uptime:   0,
	}

	fmt.Println("=== Server Management Demo ===")
	fmt.Println(srv.GetInfo())

	// Perform operations
	srv.AddTag("environment", "production")
	srv.AddTag("role", "web-server")
	
	if err := srv.Start(); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
	
	srv.Uptime = 48 * time.Hour
	fmt.Println(srv.GetInfo())
	
	if err := srv.Stop(); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
}
