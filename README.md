# flashcards.sh

A POSIX-compliant shell script for learning with flashcards

# Prerequisites
Make the script executable: e.g. `chmod a+x flashcards.sh`. See [example.txt](example.txt) for how the flashcards files are structured.

# Usage (not up to date)
Run the script with or without options and the path of the flashcards file you want to use. e.g. `./flashcards.sh example.txt` which will show the fist page of the cards first or `./flashcards.sh example.txt -m2 -c5` which will show the second page of the cards first and only show five cards


>OPTIONS (without spaces)
>
>help: -h or --help to show help
>
>mode: -m1 normal | -m2 show 2nd | ... | -m0 show all
>
>cards: -c[INTEGER] - how many cards to print

>CONTROLS
>
>next page with ENTER
>
>save and exit with q ENTER, exit with control-C
