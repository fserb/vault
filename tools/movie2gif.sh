#!/bin/bash

set -e

mplayer "$1" -noframedrop -ao null -ss 0:00:00 -vf scale=240:240,format=rgb32,scale -vo gif89a:fps=15:output=tmp.gif
gifsicle -O3 --colors 256 < tmp.gif > "$2"
# rm -f tmp.gif
