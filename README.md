# flashcards.sh
A POSIX complient and almost fully POSIX shell flashcards learning script

# Prerequisites
Make the script executable: e.g. `chmod +x flashcards.sh`.

# Usage
   `[OPTIONS]... ./flashcards.sh [FILE]`
   
   e.g. `t=1 ./flashcards.sh example.txt`
   
# Options
   modes: `m=[n]` - show nth page of cards
   
   typing: `t=[n]` - enable typing check for nth page
   
   cards: `c=[n]` - how many cards to print
   
   permanent savefiles: `p=[n]` - 1 for saving in current directory
   
# Controls
   next page with `ENTER`
   
   save and exit with `q ENTER`, exit with `control-C`
   
# Input file requirements
   separate pages with `' = '`, see [example.txt](example.txt)
   
   last line is an empty new line
   
   no other empty or unused lines
   
# Dependencies
   `shell` - any POSIX complient shell
   
   `awk` is the only needed non shell, but still POSIX command
   
   optional
   `rm` for deleting temp files
