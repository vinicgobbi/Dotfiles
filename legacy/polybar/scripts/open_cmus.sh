#!/bin/sh

mainf() {
if pgrep -x cmus >/dev/null
then
printf " "    
else
alacritty --command cmus
fi
}

mainf
