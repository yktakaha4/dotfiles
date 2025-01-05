#!/bin/sh -eu

mailpit \
    --database /var/lib/mailpit/mailpit.db \
    --webroot mailpit \
    --listen 127.0.0.1:38025 \
    --smtp 127.0.0.1:31025 \
    --smtp-auth-accept-any \
    --smtp-auth-allow-insecure \
    --verbose
