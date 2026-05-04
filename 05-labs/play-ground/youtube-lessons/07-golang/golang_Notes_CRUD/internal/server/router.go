package server

import (
	"net/http"
	"notes-api/notes"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/mongo"
)

func NewRouter(database *mongo.Database) *gin.Engine {
	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"ok" : true,
			"status" : "healthy",
		})
	})
	notes.RegisterRoutes(r, database)
	return r
}

// Customize Gin Logging
// func NewRouter(database *mongo.Database) *gin.Engine {
// 	r := gin.New()

// 	r.Use(func (c *gin.Context)  {
// 		start := time.Now()
// 		path := c.Request.URL.Path
// 		method := c.Request.Method


// 		c.Next()
// 		duration := time.Since(start)
// 		fmt.Printf("Request: %s %s - Duration: %v\n", c.Request.Method, c.Request.URL.Path, duration)

// 		latency := time.Since(start)
// 		status := c.Writer.Status()
// 		fmt.Printf("Request: %s %s - Duration: %v, Latency: %v, Status: %d\n", method, path, duration, latency, status)

// 		slog.Info(
// 			"http_request",
// 			"method", method,
// 			"path", path,
// 			"status", status,
// 			"latency_ms", latency.Milliseconds(),
// 			"client_ip", c.ClientIP(),
// 			"user_agent", c.Request.UserAgent(),
// 		)
// 	})

// 	r.Use(gin.Recovery())

// 	notes.RegisterRoutes(r, database)
// 	return r

// }