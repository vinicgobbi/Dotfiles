#!/bin/sh

poly_shuffle() {
SHUFFLE=$(cmus-remote -Q | grep 'shuffle' | awk '{print $3}')
if [ "$SHUFFLE" = "true" ]; then
printf ""
else
printf ""
fi
}

mainf() {
if pgrep -x cmus >/dev/null
then
poly_shuffle    
else
printf " "
fi
}

mainf
