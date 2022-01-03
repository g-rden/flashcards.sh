#!/bin/sh
#
# flashcards.sh
# a POSIX complient and almost fully POSIX shell flashcards learning script
#

# USAGE:
#    [OPTIONS]... ./flashcards.sh [FILE]
# OPTIONS:
#    modes: m=[n] - show nth page of cards
#    typing: t=[n] - enable typing check for nth page
#    cards: c=[n] - how many cards to print
#    permanent savefiles: p=[n] - 1 for saving in current directory
# CONTROLS:
#    next page with ENTER
#    save and exit with q ENTER, exit with control-C
# INPUT FILE REQUIREMENTS:
#    last line is an empty new line
#    no other empty or unused lines

# supress errors
exec 2>/dev/null

# show help
! (: "${1:?}" ) && n=1 && while [ "$n" -le 19 ]; do read -r l
	[ "$n" -ge 7 ] && a="$a\n$l"; n=$((n+1)); done < "$0" && printf '%s'"$a\n" && exit

# file doesn't exist
if [ -e "$1" ]; then i="$1"
else printf '%s\n' "$0: cannot access '$1': No such file"; exit; fi

# parsed arguments
! (: "${t:?}" ) && t=0 && m="${m:-1}" || m="${m:-2}"; mc="$t" p="${p:-0}"

# for greater enviornment support e.g. termux
[ "$p" = 1 ] && savefile='tmp-'"${i##*/}" || savefile="${TMPDIR:-/tmp}"'/tmp-'"${i##*/}"

# declare variables if not loaded from a savefile
declarenew() {
	card=1 crt=0 n=0 voc="$(shuf "$i")" # shuf is here
	# AFAIK it is not possible to get random/pseudo random numbers in POSIX shell.
	# if it is somehow possible please let me know.
	# for now it's shuf. if it is not available change it to 'sort -R' or something else.
	# in the worst case compile one of the many shuf clones from the web.
	! (: "${voc:?}" ) && printf "cannot execute shuf! install shuf or replace it in code. sry\n" && exit
	while read -r line; do n=$((n+1)); done < "$i";	total="${c:-$n}"
}

# parse savefile
if read -r line < "$savefile" && [ "$line" = "$m|$c" ]; then
	# load variables from savefile
	n=1
	while read -r l; do
		case "$n" in
			2) card="$l";; 3) total="$l";; 4) crt="$l";; ??*) voc="$voc
$l";;
		esac; n=$((n+1))
	done < "$savefile"
	# remove first line of $voc, which is just a newline
	voc="${voc#*
}"; printf '%s'"$card/$total\nresume (*) or not (n): "
	read -r REPLY; [ "$REPLY" = n ] && declarenew
else declarenew; fi

# print selected page
printsel() {
	printf '\033[2J\033[H%s'"$card/$total"; [ "$t" -ge 1 ] && printf '%s'" - correct: $crt"
	x=1 part="$line"
	while [ "$x" -lt "$m" ]; do
		[ "$x" -le "$m" ] && part="${part#* = }"; x=$((x+1))
	done
	printf '\n%s\n' "${part%% = *}"; read -r REPLY
}

# print whole card
printnext() {
	printf '\n%s\n' "$line"
	# delete top line from $voc
	voc="${voc#*
}"; read -r REPLY; card=$((card+1))
	# save and exit if input
	[ "$REPLY" = q ] && [ "$card" -le "$total" ] &&
		printf '%s'"$m|$c\n$card\n$total\n$crt\n\n\n\n\n\n$voc\n" > "$savefile" && exit
}

# main loop
if [ "$t" -ge 1 ]; then # typing check
	while [ "$card" -le "$total" ]; do
		# set line to the top line of $voc
		line="${voc%%
*}"
		printsel
		# prepare compare with selected page
		x=1 part="$line"
		while [ "$x" -lt "$mc" ]; do
			[ "$x" -le "$mc" ] && part="${part#* = }"; x=$((x+1))
		done
		# compare typed input with page
		[ "$REPLY" = "${part%% = *}" ] &&
			# 2 is green, 1 is red
			printf '\033[9%sm\ncorrect\033[0m' 2 && crt=$((crt+1)) ||
			printf '\033[9%sm\nincorrect\033[0m' 1; printnext; done
	printf '\033[2J\033[H%s\n' "correct: $crt/$total or $((200*crt/total%2+100*crt/total))%"
else # no typing check
	while [ "$card" -le "$total" ]; do
		# set line to the top line of $voc
		line="${voc%%
*}"
		[ "$m" -gt 0 ] && printsel
		printf '\033[2J\033[H%s' "$card/$total"; printnext
	done
fi

# delete savefile
[ -e "$savefile" ] && rm "$savefile"
