
mainf() {
if pgrep -x cmus >/dev/null
then
printf "  "
else
printf " "
fi
}

mainf