#!/usr/bin/env zsh

if [ $(uname) != "Linux" ]; then
    return
fi

if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    return
fi

# env
export BROWSER="wslview"
export DISPLAY=`hostname`.mshome.net:0.0
export GH_BROWSER='wslview'

# wslu
which wslview >/dev/null || (
  # https://wslutiliti.es/wslu/install.html
  sudo add-apt-repository ppa:wslutilities/wslu
  sudo apt update
  sudo apt install wslu
)

alias open='explorer.exe'
alias pbcopy='clip.exe'
alias pbpaste="powershell.exe -command 'Get-Clipboard'"
alias shutdown='shutdown.exe /s /f /t 0'
alias reboot='shutdown.exe /r /f /t 0'
