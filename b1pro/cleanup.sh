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
docker system prune --filter "until=$((24 * 35))h" -af

echo "=== delete temp files ==="
rm -rvf /usr/share/nginx/html/shared/uploads/*

echo "=== after ==="
df -m

echo "=== finish cleanup ==="
date
id
