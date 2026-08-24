#!/bin/sh

PREV=$(echo '')
mainf() {
if pgrep -x cmus >/dev/null
then
printf "$PREV"
else
printf " "
fi
}

mainf
