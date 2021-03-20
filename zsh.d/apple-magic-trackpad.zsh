#!/usr/bin/env zsh

DEVICE_NAME="Apple Inc. Magic Trackpad 2"
xinput --list-props "$DEVICE_NAME" > /dev/null 2>&1
if [[ "$status" -eq 0 ]]
then
  xinput --set-prop "$DEVICE_NAME" "libinput Accel Speed" 0.75
fi
