import redis

new_max_memory = (1 * 1024 * 1024) // 2

r = redis.Redis(host="localhost", port=6380)
r.config_set('maxmemory', new_max_memory)
print("Redis maxmemory is resized.")