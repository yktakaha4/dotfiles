#!/bin/sh -eu

code serve-web \
    --host "127.0.0.1" \
    --port "18001" \
    --server-base-path "/code" \
    --without-connection-token \
    --accept-server-license-terms
