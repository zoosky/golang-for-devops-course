package main

import (
	"fmt"
	"os"
	"log"

	"github.com/wardviaene/golang-for-devops-course/ssh-demo"
)

func main() {
	var (
		err error
	)
	serverKeyBytes, err := os.ReadFile("server.pem")
	if err != nil {
		log.Fatalf("Failed to load authorized_keys, err: %v", err)
	}

	authorizedKeysBytes, err := os.ReadFile("mykey.pub")
	if err != nil {
		log.Fatalf("Failed to load authorized_keys, err: %v", err)
	}

	if err = ssh.StartServer(serverKeyBytes, authorizedKeysBytes); err != nil {
		fmt.Printf("Error: %s\n", err)
		os.Exit(1)
	}

}
