#!/bin/sh -eu


echo "=== start cleanup ==="
date
id

echo "=== before ==="
df -m

echo "=== apt autoremove ==="
apt autoremove

echo "=== apt clean ==="
apt clean

echo "=== docker system prune ==="
docker system prune -af

echo "=== after ==="
df -m

echo "=== finish cleanup ==="
date
id
