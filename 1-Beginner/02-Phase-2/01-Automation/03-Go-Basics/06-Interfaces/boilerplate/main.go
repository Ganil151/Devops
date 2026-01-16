package main

import (
	"fmt"
	"time"
)

// DevOps Context: Interfaces enable pluggable monitoring backends

// MetricsCollector interface - any monitoring system must implement this
type MetricsCollector interface {
	RecordMetric(name string, value float64) error
	GetMetrics() map[string]float64
}

// PrometheusCollector implements MetricsCollector
type PrometheusCollector struct {
	metrics map[string]float64
}

func (p *PrometheusCollector) RecordMetric(name string, value float64) error {
	if p.metrics == nil {
		p.metrics = make(map[string]float64)
	}
	p.metrics[name] = value
	fmt.Printf("[Prometheus] Recorded: %s = %.2f\n", name, value)
	return nil
}

func (p *PrometheusCollector) GetMetrics() map[string]float64 {
	return p.metrics
}

// CloudWatchCollector implements MetricsCollector
type CloudWatchCollector struct {
	metrics map[string]float64
}

func (c *CloudWatchCollector) RecordMetric(name string, value float64) error {
	if c.metrics == nil {
		c.metrics = make(map[string]float64)
	}
	c.metrics[name] = value
	fmt.Printf("[CloudWatch] Recorded: %s = %.2f\n", name, value)
	return nil
}

func (c *CloudWatchCollector) GetMetrics() map[string]float64 {
	return c.metrics
}

// Application code using the interface
func monitorApplication(collector MetricsCollector) {
	fmt.Println("\n=== Monitoring Application ===")
	
	collector.RecordMetric("http_requests_total", 1523)
	collector.RecordMetric("cpu_usage_percent", 45.2)
	collector.RecordMetric("memory_usage_mb", 2048)
	
	time.Sleep(100 * time.Millisecond)
	
	fmt.Println("\n=== Current Metrics ===")
	for name, value := range collector.GetMetrics() {
		fmt.Printf("  %s: %.2f\n", name, value)
	}
}

func main() {
	// Switch monitoring backends without changing application code
	fmt.Println("Using Prometheus Collector:")
	prom := &PrometheusCollector{}
	monitorApplication(prom)
	
	fmt.Println("\n" + "="*50)
	fmt.Println("Switching to CloudWatch Collector:")
	cw := &CloudWatchCollector{}
	monitorApplication(cw)
}
