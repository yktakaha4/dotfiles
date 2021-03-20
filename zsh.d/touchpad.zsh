#!/usr/bin/env zsh

DEVICE_NAME='UNIW0001:00 093A:1336 Touchpad'
DEVICE_ID="$(xinput list --id-only "$DEVICE_NAME" 2>/dev/null)"

if [[ "$DEVICE_ID" != "" ]]
then
  xinput set-button-map "$DEVICE_ID" 1 1 3 4 5 6 7
fi
