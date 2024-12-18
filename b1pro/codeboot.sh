#!/bin/sh
code serve-web \
	--without-connection-token \
	--accept-server-license-terms \
	--host "$(tailscale ip -4)" \
	--port 18000
