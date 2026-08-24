
mainf() {
if pgrep -x cmus >/dev/null
then
VOLUME=$(cmus-remote -Q | grep 'vol_left' | awk '{print $3}')
printf "  $VOLUME%%"
else
printf " "
fi
}

mainf