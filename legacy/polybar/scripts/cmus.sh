#!/bin/sh

# Dependencies: cmus

poly_cmus () {
    if ps -C cmus > /dev/null; then
        ARTIST=$(cmus-remote -Q | grep -a '^tag artist' | awk '{gsub("tag artist ", "");print}')
        TRACK=$(cmus-remote -Q | grep -a '^tag title' | awk '{gsub("tag title ", "");print}')
        POSITION=$(cmus-remote -Q | grep -a '^position' | awk '{gsub("position ", "");print}')
        DURATION=$(cmus-remote -Q | grep -a '^duration' | awk '{gsub("duration ", "");print}')
        STATUS=$(cmus-remote -Q | grep -a '^status' | awk '{gsub("status ", "");print}')
        SHUFFLE=$(cmus-remote -Q | grep -a '^set shuffle' | awk '{gsub("set shuffle ", "");print}')


        
        printf "%s - %s" "$TRACK"
        printf "%0d:%02d" $((POSITION%3600/60)) $((POSITION%60))
        printf " / %0d:%02d" $((DURATION%3600/60)) $((DURATION%60))
        printf "%s%s\n"
    fi
}

mainf() {
if pgrep -x cmus >/dev/null
then
poly_cmus
else
echo -n No music playing
fi
}

mainf

