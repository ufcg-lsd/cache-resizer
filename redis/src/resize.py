import redis

r = redis.Redis(host="localhost", port=6380)
new_maxmemory = int(r.config_get('maxmemory')['maxmemory']) * 0.1

r.config_set('maxmemory-policy', 'allkeys-lfu') # default is noeviction
r.config_set('maxmemory', int(new_maxmemory))

print("Redis maxmemory is resized.")