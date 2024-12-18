#!/bin/sh -eu

base_dir="$(cd $(dirname $0); pwd)"

. "$base_dir/code-server-proxy.env"

$OAUTH2_PROXY_PATH \
    --https-address="0.0.0.0:18000" \
    --tls-cert-file="/etc/nginx/ssl/server.crt" \
    --tls-key-file="/etc/nginx/ssl/server.key" \
    --upstream="http://127.0.0.1:18001/" \
    --email-domain="*" \
    --provider="github" \
    --github-user="$GITHUB_USERS" \
    --redirect-url="https://b1pro:18000/oauth2/callback" \
    --client-id="$CLIENT_ID" \
    --client-secret="$CLIENT_SECRET" \
    --cookie-secret="$COOKIE_SECRET" \
    --cookie-secure=true \
    --cookie-name="_oauth2_proxy_code_server"
