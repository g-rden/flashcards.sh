#!/bin/sh
#
#	./flashcards.sh [OPTION]... [FILE]...
#	OPTIONS: 1 normal | 2 show 2nd | ... | 0 show all

line=1; voc="$(shuf "$2")"; total="$(awk 'END{print NR}' "$2")"

while [ "$line" -le "$total" ]; do
	clear; printf "%s$line/%s$total\n"
	echo "$voc" | awk -v l="$line" -v f="$1" -F'=' '{if(NR==l)print $f}'
	read -r REPLY; clear; printf "%s$line/%s$total\n"
	echo "$voc" | awk -v l="$line" 'NR==l'
	read -r REPLY; line=$((line+1))
done
