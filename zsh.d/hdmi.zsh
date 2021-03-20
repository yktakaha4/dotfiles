#!/usr/bin/env zsh

function conhdmi() {
  if [[ "$(printenv DISPLAY)" != "" ]]
  then
    xset dpms force off
    xset dpms force on
  fi

  xrandr \
    --output eDP-1-1 --mode 1920x1080 --pos 0x1080 --rate 59.98 \
    --output HDMI-0 --mode 3840x2160 --pos 1920x0 --rate 60.00
}

function disconhdmi() {
  xrandr \
    --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rate 59.98 \
    --output HDMI-0 --off
}
