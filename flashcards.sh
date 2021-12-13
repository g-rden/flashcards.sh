#!/bin/sh
#
#	./flashcards.sh [OPTION]... [FILE]
#		OPTIONS: (without spaces!!!)
#		mode: -m1 normal | -m2 show 2nd | ... | -m0 show all
#		cards: -c[INTEGER] - how many cards to print
#		CONTROLS:
#		next page with ENTER
#		save and exit with q ENTER, exit with control-C

showhelp() {
	awk 'NR>=3 && NR<=9' "$0"; exit
}

if [ -z "$1" ]; then showhelp; fi
if [ "$#" -gt "3" ]; then printf "Too many arguments\n\n"; showhelp; fi

m="1"
c="0"

for a in "$@"; do
	case "$a" in
		-h | --help) showhelp;;
		-m*)         m="$(echo "$a" | awk '{print substr($1, 3)}')";;
		-c*)         c="$(echo "$a" | awk '{print substr($1, 3)}')";;
		*) if [ -e "$a" ]; then file="$a"; else echo "No such file"; exit; fi;;
	esac
done

declarenew() {
	card="1"; voc="$(shuf "$file")"; total="$(awk 'END{print NR}' "$file")"
	if [ "$c" -gt 0 ] && [ "$c" -lt "$total" ]; then total="$c"; fi
}

tmpfile="/$(mktemp -u | awk -F'/' 'BEGIN{OFS=FS} {$NF=""; print}')/$file-tmp"

if [ -e "$tmpfile" ] && [ "$(awk 'NR<=2' "$tmpfile")" = "$(printf "%s$m\n%s$c")" ]; then
	printf "%s$(awk 'NR==3' "$tmpfile")/$(awk 'NR==4' "$tmpfile")\ncontinue (y) or start a new one (n) "
	read -r REPLY
	if [ "$REPLY" = "y" ]; then
		card="$(awk 'NR==3' "$tmpfile")"
		total="$(awk 'NR==4' "$tmpfile")"
		voc="$(awk 'NR>=5' "$tmpfile")"
	else declarenew
	fi
else declarenew
fi

savequit() {
	printf "%s$m\n%s$c\n%s$card\n%s$total\n%s$voc" > "$tmpfile"
	exit
}

while [ "$card" -le "$total" ]; do
	if [ "$m" -ne "0" ]; then
		clear; echo "$card/$total"; echo "$voc" | \
		awk -v k="$card" -v m="$m" -F'= ' '{if(NR==k) {print $m}}'
		read -r REPLY; if [ "$REPLY" = "q" ]; then savequit; fi
	fi
	clear; printf "%s$card/%s$total\n%s$voc" | \
	awk -v k="$((card+1))" 'NR==1 || NR==k'
	read -r REPLY; card=$((card+1)); if [ "$REPLY" = "q" ]; then savequit; fi
done

if [ -e "$tmpfile" ]; then rm "$tmpfile"; fi
