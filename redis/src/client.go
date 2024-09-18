package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/sirupsen/logrus"
)

type Client struct {
	id          string
	redisClient *redis.Client
}

func newClient(id string, redisClient *redis.Client) *Client {
	return &Client{id: id, redisClient: redisClient}
}

func (client *Client) get(key string) {
	start := time.Now()
	// Realiza um get do valor tipo lista a partir da key
	_, err := client.redisClient.LRange(context.Background(), key, 0, -1).Result()
	elapsed := time.Since(start)

	hitMiss := "miss"
	if err == nil {
		hitMiss = "hit"
	}

	logrus.Infof("%s %s %v %s", client.id, key, elapsed, hitMiss)
}

func getUsedMemory(info string) (string, error) {
	// Find the line starting with "used_memory:"
	for _, line := range strings.Split(info, "\n") {
		if strings.HasPrefix(line, "used_memory:") {
			return strings.TrimPrefix(line, "used_memory:"), nil
		}
	}
	return "", fmt.Errorf("used_memory not found in INFO memory result")
}

func main() {
	if len(os.Args) < 5 {
		fmt.Println("Usage: go run client.go <qtd_clients> <iat> <execution_time> <num_keys>")
		return
	}

	arg1 := os.Args[1]
	arg2 := os.Args[2]
	arg3 := os.Args[3]
	arg4 := os.Args[4]

	qtdClients, errClients := strconv.Atoi(arg1)
	iat, errIat := strconv.Atoi(arg2)
	executionTime, errExecutionTime := time.ParseDuration(arg3)
	numKeys, errNumKeys := strconv.Atoi(arg4)

	if errClients != nil || errIat != nil || errNumKeys != nil {
		log.Fatalf("Erro ao converter '%s' ou '%s' ou '%s' para inteiro.", arg1, arg2, arg4)
	}

	if errExecutionTime != nil {
		log.Fatalf("Erro ao converter '%s' para unidade de tempo.", arg3)
	}

	redisClient := redis.NewClient(&redis.Options{
		Addr: "localhost:6380",
	})

	for i := 0; i < qtdClients; i++ {
		clientID := fmt.Sprintf("c%d", i)
		client := newClient(clientID, redisClient)

		go func() {
			start := time.Now()

			for {
				// Context for the operations
				ctx := context.Background()

				// Get memory info
				memInfo, err := redisClient.Info(ctx, "memory").Result()
				if err != nil {
					log.Fatalf("Error getting memory info: %v", err)
				}

				// Get used memory directly from the INFO command result
				usedMemory, err := getUsedMemory(memInfo)
				if err != nil {
					log.Fatalf("Error extracting used memory: %v", err)
				}

				fmt.Printf("Used memory: %s\n", usedMemory)

				// Get number of keys in the database
				numberOfKeys, err := redisClient.DBSize(ctx).Result()
				if err != nil {
					log.Fatalf("Error getting number of keys: %v", err)
				}

				fmt.Printf("Number of keys: %d\n", numberOfKeys)

				elapsed := time.Since(start)

				if elapsed >= executionTime {
					break
				}

				key := fmt.Sprintf("key%d", rand.Intn(numKeys))
				client.get(key)
				time.Sleep(time.Duration(iat) * time.Second)
			}
		}()
	}

	time.Sleep(30 * time.Second)
}
