#!/bin/sh -eu

mailpit \
    -d /var/lib/mailpit/mailpit.db \
    --webroot mailpit \
    --listen 127.0.0.1:1026 \
    --verbose
