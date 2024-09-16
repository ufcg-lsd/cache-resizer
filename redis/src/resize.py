import redis

r = redis.Redis(host="localhost", port=6380)
new_maxmemory = int(r.config_get('maxmemory')['maxmemory']) * 0.5
r.config_set('maxmemory', int(new_maxmemory))

print("Redis maxmemory is resized.")