# Redis Resize
- This project aims to understand the impact on Redis performance caused by its resizing mechanisms.

## Requirements

Before running the script, ensure that you have the following dependencies installed and properly configured:

1. **Docker**
  - Docker is required to build and run the Redis container. You can install Docker by following the instructions [Install Docker on Linux](https://docs.sevenbridges.com/docs/install-docker-on-linux).

2. **Python 3**
  - Python 3 is needed to execute the `fill_redis.py` and `resize.py` scripts. You can install Python 3 from the [official Python website](https://www.python.org/downloads/).
  - Ensure that `pip` is installed to manage Python packages.
  - Run the following:
  ```sh
    sudo apt install python3
    sudo apt install python3-pip
    pip install -r requirements.txt
  ```

3. **Go Programming Language**
  - Go is required to compile and run the `client.go` script. You can install Go from the [official Go website](https://go.dev/doc/install).go
  - After that, install the dependencies:
   ```sh
   go mod download
   ```


4. **Redis CLI (Optional)**
  - If you need to interact with the Redis server directly for debugging or inspection, having the Redis CLI tool installed could be useful.
  ```sh
  sudo apt install redis
  ```

Once these dependencies are installed, you should be able to run the script without any issues.

## Running the experiment
In the `/redis/bin` directory, run:
```sh
bash load-resize.sh <qtd_clients> <iat> <execution_time>
```
- Example:
  ```sh
  bash load-resize.sh 3 5 5s
  ```
