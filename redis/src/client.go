package main

import (
	"context"
	"fmt"
	"log"
	"math/rand"
	"os"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
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
	// get to retrieve a list using arg key
	res, _ := client.redisClient.LRange(context.Background(), key, 0, -1).Result()
	elapsed := time.Since(start)

	hitMiss := "hit"
	if len(res) == 0 {
		hitMiss = "miss"
	}

	log.Printf("%s %v %dµs %s", client.id, key, elapsed.Microseconds(), hitMiss)
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

			for {
				key := fmt.Sprintf("key%d", rand.Intn(numKeys))
				client.get(key)
				time.Sleep(time.Duration(iat) * time.Second)
			}
		}()
	}

	time.Sleep(executionTime)
}
