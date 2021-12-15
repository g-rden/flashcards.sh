#!/bin/sh
#
#	./flashcards.sh [OPTION]... [FILE]
#		OPTIONS:
#		mode: -m1 normal | -m2 show 2nd | ... | -m0 show all (training)
#		cards: -c[INTEGER] - how many cards to print
#		typing: -t - enable typing the words (normal mode)
#		permanent savefiles: -p - saves in current directory
#		CONTROLS:
#		next page with ENTER
#		save and exit with q ENTER, exit with control-C

showhelp() { awk 'NR>=3 && NR<=11' "$0"; exit; }

if [ -z "$1" ]; then showhelp; fi

m="1"; c="0"; t="0"; p="0"

for arg in "$@"; do
	case "$arg" in
		-h | --help) showhelp;;
		-m*)         m="$(echo "$arg" | awk '{print substr($1, 3)}')";; #mode
		-c*)         c="$(echo "$arg" | awk '{print substr($1, 3)}')";; #cards
		-t)          t="1"; m="2";;                                     #typing
		-p)          p="1";;                                            #permasave
		*) if [ -e "$arg" ]; then file="$arg"; else echo "No such file"; exit; fi;;
	esac
done

declarenew() {
	card="1"; voc="$(shuf "$file")"; total="$(awk 'END{print NR}' "$file")"; crt="0"
	if [ "$c" -gt 0 ] && [ "$c" -lt "$total" ]; then total="$c"; fi
}

if [ "$p" = "1" ]; then
	savefile="tmp-$file"
else
	savefile="$(mktemp -u | awk -F'/' 'BEGIN{OFS=FS} {$NF=""; print}')tmp-$file"
fi

if [ -e "$savefile" ] && [ "$(awk 'NR==1' "$savefile")" = "$m|$c" ]; then
	printf '%s'"$(awk 'NR==2' "$savefile")/$(awk 'NR==3' "$savefile")\ncontinue (y) or start a new one (n) "
	read -r REPLY
	if [ "$REPLY" = "y" ]; then
		card="$(awk 'NR==2' "$savefile")"
		total="$(awk 'NR==3' "$savefile")"
		crt="$(awk 'NR==4' "$savefile")"
		voc="$(awk 'NR>=5' "$savefile")"
	else declarenew; fi
else declarenew; fi

printsel() {
	clear; echo "$card/$total"
	echo "$voc" | awk -v k="$card" -v m="$m" -F' = ' '{if(NR==k) {print $m}}'
	read -r REPLY
}

printnext() {
	echo "$voc" | awk -v k="$card" 'NR==k'; read -r REPLY; card="$((card+1))"
	if [ "$REPLY" = "q" ] && [ "$card" -le "$total" ]; then
		printf '%s'"$m|$c\n$card\n$total\n$crt\n$voc" > "$savefile"; exit
	fi
}

if [ "$t" = "0" ]; then
	while [ "$card" -le "$total" ]; do
		if [ "$m" != "0" ]; then printsel; fi
		clear; echo "$card/$total"; printnext
	done
else
	while [ "$card" -le "$total" ]; do
		printsel
		if [ "$REPLY" = "$(echo "$voc" | \
			awk -v k="$card" -v m="1" -F' = ' '{if(NR==k) {print $m}}')" ]; then
			printf "\ncorrect\n"; crt="$((crt+1))"
		else printf "incorrect\n"; fi
		printnext
	done
	clear; echo "correct: $crt/$total"
fi

if [ -e "$savefile" ]; then rm "$savefile"; fi
