#!/bin/sh -eu

base_path="$(cd "$(dirname "$0")"; pwd)"
public_path="${base_path}/public"
dest_path="/usr/share/nginx/html"

echo "=== deploy ==="
sudo cp -rfv "$public_path"/* "$dest_path/"
echo "=== done ==="
