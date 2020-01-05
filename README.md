# devbox 📦

## Docker

```shell
# Normal
docker build -t devbox .
docker run --rm -it devbox bash

# With X server (privileged, less secure)
docker build -t devbox . --build-arg RUNX=true
docker run --privileged --rm -it devbox bash
```

## Docker-compose

```shell
docker-compose up -d
docker exec -it devbox bash
```
