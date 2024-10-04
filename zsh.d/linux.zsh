#!/usr/bin/env zsh

if [ $(uname) != "Linux" ]; then
    return
fi

if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    return
fi

which xclip > /dev/null || sudo apt-get install -y xclip
which xdg-open > /dev/null || sudo apt-get install -y xdg-utils

alias open='xdg-open'
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'
alias shutdown='systemctl poweroff -i'
alias reboot='systemctl reboot -i'
