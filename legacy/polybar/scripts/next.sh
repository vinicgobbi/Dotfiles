#!/bin/sh

NEXT=$(echo '')

mainf() {
if pgrep -x cmus >/dev/null
then
printf "$NEXT"
else
printf " "
fi
}

mainf
