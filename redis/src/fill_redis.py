import redis

max_memory = 1 * 1024 * 1024 # todo: mudar pra 4GB -> diminuir 10%

r = redis.Redis(host="localhost", port=6380)
r.flushdb()
r.config_set('maxmemory', max_memory)

try:
    count = 0
    
    while True:
        key = f"key{count}"
        value = f"value{count}"
        r.set(key, value)

        used_memory = r.info('memory')['used_memory']
        if used_memory >= max_memory:
            print(f"Limite de memória atingido: {used_memory} bytes")
            break
        
        count += 1
      
except redis.exceptions.ResponseError as e:
    print(f"Erro: {e}")
