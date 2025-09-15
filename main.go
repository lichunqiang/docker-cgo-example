package main

import (
	"flag"
	"fmt"

	"github.com/erikdubbelboer/gspt"
	"github.com/gin-gonic/gin"
)

var port int

func init() {
	flag.IntVar(&port, "port", 8080, "port to listen on")
	flag.Parse()
}

func main() {
	gspt.SetProcTitle("Example-Gin-Server")

	router := gin.Default()
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "Hello, World!"})
	})
	router.Run(fmt.Sprintf(":%d", port))
}
