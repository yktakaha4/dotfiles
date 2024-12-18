#!/bin/sh -eu

base_dir="$(cd $(dirname $0); pwd)"

. "$base_dir/code-server-proxy.env"

$OAUTH2_PROXY_PATH \
    --http-address="127.0.0.1:18002" \
    --upstream="http://127.0.0.1:18001/code/" \
    --proxy-prefix="/code/oauth2" \
    --email-domain="*" \
    --provider="github" \
    --github-user="$GITHUB_USERS" \
    --redirect-url="$REDIRECT_URL" \
    --client-id="$CLIENT_ID" \
    --client-secret="$CLIENT_SECRET" \
    --cookie-secret="$COOKIE_SECRET" \
    --cookie-secure=true \
    --cookie-name="_oauth2_proxy_code_server" \
    --proxy-websockets=true \
    --reverse-proxy=true
