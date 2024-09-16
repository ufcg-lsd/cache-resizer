package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"
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
	_, err := client.redisClient.LRange(context.Background(), key, 0, -1).Result()
	elapsed := time.Since(start)

	hitMiss := "miss"
	if err == nil {
		hitMiss = "hit"
	}

	if err != nil {
		logrus.Warnf("Get failed: %v", err)
	} else {
		logrus.Infof("%s %s %v %s", client.id, key, elapsed, hitMiss)
	}
}

func main() {
	arg1 := os.Args[1]
	arg2 := os.Args[2]
	arg3 := os.Args[3]

	qtdClients, errClients := strconv.Atoi(arg1)
	iat, errIat := strconv.Atoi(arg2)
	executionTime, errExecutionTime := time.ParseDuration(arg3)

	if errClients != nil || errIat != nil {
		log.Fatalf("Erro ao converter '%s' ou '%s' para inteiro.", arg1, arg2)
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
			j := 0

			for {
				elapsed := time.Since(start)

				if elapsed >= executionTime {
					break
				}

				key := fmt.Sprintf("key%d", j)
				client.get(key)
				time.Sleep(time.Duration(iat) * time.Second)

				j++
			}
		}()
	}

	time.Sleep(30 * time.Second)
}
