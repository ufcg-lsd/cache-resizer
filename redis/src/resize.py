import redis
import time

r = redis.Redis(host="localhost", port=6380)
new_maxmemory = int(int(r.config_get('maxmemory')['maxmemory']) * 0.1)
r.config_set('maxmemory-policy', 'allkeys-lru') # default is noeviction
print(f"Number of keys before resize:{r.dbsize()}") 

# Do resize
r.config_set('maxmemory', new_maxmemory)

time.sleep(5)

print(f"Number of keys after resize:{r.dbsize()}") 


print("Redis maxmemory is resized.")