#!/bin/bash

name=`iwconfig wlp8s0 | grep ESSID | awk '{print $4}' | cut -d '"' -f 2`
quality=`iwconfig wlp8s0 |grep 'Link Quality'|cut -d '=' -f 2| awk '{print int($1 * 100 / 70) }'`

case $BLOCK_BUTTON in
    1) echo " $quality%" ;;
    *) echo " $name" ;;
esac
