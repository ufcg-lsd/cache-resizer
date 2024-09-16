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
        r.rpush(key, *list_value) # TODO: Erro: command not allowed when used memory > 'maxmemory'.

        used_memory = r.info('memory')['used_memory']
        if used_memory >= max_memory: # Verificação desnecessária
            print(f"Limite de memória atingido: {used_memory} bytes")
            break
        
        count += 1
      
except redis.exceptions.ResponseError as e:
    used_memory = r.info('memory')['used_memory']
    print(f"Limite de memória atingido: {used_memory} bytes")
    print(f"Erro: {e}")
