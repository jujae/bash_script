#!/bin/bash

intern=LVDS1
extern=HDMI1
wallpaper=`cat /home/januz/.config/i3/config | grep feh | awk '{print $5}' |cut -d "'" -f 2`

if xrandr | grep "$extern disconnected"; then
	xrandr --output "$extern" --off --output "$intern" --auto
else
	xrandr --output "$intern" --mode 1366x768 --pos 1920x312 --output "$extern" --mode 1920x1080 --pos 0x0 --primary && feh --bg-scale "$wallpaper"
fi
