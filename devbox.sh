#!/usr/bin/env bash

docker-compose down
docker-compose build
docker run --rm -it devbox bash
