package main

import "testing"

// DevOps Context: Writing actual Go tests

func TestCalculateResources(t *testing.T) {
	tests := []struct {
		name     string
		replicas int
		cpu      int
		want     int
	}{
		{"Single replica", 1, 100, 100},
		{"Multiple replicas", 3, 200, 600},
		{"Zero replicas", 0, 500, 0},
		{"Negative replicas", -1, 100, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := CalculateResources(tt.replicas, tt.cpu)
			if got != tt.want {
				t.Errorf("CalculateResources() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestValidateEnv(t *testing.T) {
	if !ValidateEnv("prod") {
		t.Error("ValidateEnv('prod') should be true")
	}
	if ValidateEnv("invalid") {
		t.Error("ValidateEnv('invalid') should be false")
	}
}
