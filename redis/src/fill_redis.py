import redis

max_memory = 4 * 1024 * 1024 * 1024 # 4GB

r = redis.Redis(host="localhost", port=6380)
r.flushdb()
r.config_set('maxmemory', max_memory)
print("Filling Redis...")

try:
    count = 0
    
    while True:
        key = f"key{count}"
        list_value = ["v" * 1024 for _ in range(100)]
        r.rpush(key, *list_value)

        count += 1
      
except redis.exceptions.ResponseError as e:
    if "command not allowed when used memory > 'maxmemory'" in str(e):
        print(f"Limite de memória atingido: {r.info('memory')['used_memory']} bytes")
    else:
        print(f"Erro: {e}")
