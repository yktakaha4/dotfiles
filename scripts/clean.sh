#!/usr/bin/env sh

echo "--- prune docker image ---"
docker image prune -f

echo "--- prune docker container ---"
docker container prune -f --filter "until=720h"

echo "--- prune docker volume ---"
docker volume prune -f

echo "--- clean apt packages ---"
apt clean
