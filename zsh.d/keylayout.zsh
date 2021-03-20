#!/usr/bin/env zsh

function setjis() {
  setxkbmap -rules evdev -model jp106 -layout jp
  xmodmap "$HOME/.xmodmap"
  echo jis > "$HOME/.keylayout"
}

function setus() {
  setxkbmap -rules evdev -model us -layout us
  xmodmap "$HOME/.xmodmap"
  echo us > "$HOME/.keylayout"
}


if [[ -f "$HOME/.keylayout" ]]
then
  if [[ "$(cat "$HOME/.keylayout")" = "us" ]]
  then
    setus
  else
    setjis
  fi
fi
