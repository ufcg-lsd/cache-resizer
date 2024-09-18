import redis
import time

r = redis.Redis(host="localhost", port=6380)
new_maxmemory = int(int(r.config_get('maxmemory')['maxmemory']) * 0.1)
# default maxmemory policy is noeviction
r.config_set('maxmemory-policy', 'allkeys-lru')

print(">> Redis maxmemory will be resized")
r.config_set('maxmemory', new_maxmemory)
time.sleep(1)

print(">> Redis maxmemory is resized")