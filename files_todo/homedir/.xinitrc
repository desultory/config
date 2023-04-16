#!/bin/sh

xrandr --output DisplayPort-0 --primary --mode 3440x1440 --pos 2560x287 --rotate normal --output DisplayPort-1 --mode 2560x1440 --pos 0x287 --rotate normal --output DisplayPort-2 --mode 1920x1080 --pos 6000x0 --rotate left --output HDMI-A-0 --off --output HDMI-A-1-1 --off --output DisplayPort-1-3 --off --output DisplayPort-1-4 --off --output DisplayPort-1-5 --off

xset dpms 0 0 900

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

exec dbus-launch --exit-with-session i3


