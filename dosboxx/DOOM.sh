#!/bin/bash

GAME_DIR="${HOME}/games/dosboxx/c"

# Check if DOSBox-X is installed
if ! command -v dosbox-x &> /dev/null; then
    echo "Error: DOSBox-X is not installed. Please install it from https://dosbox-x.com/"
    exit 1
fi

dosbox-x -fullscreen \
         -c "mount c $GAME_DIR" \
         -c "c:" \
         -c "mixer SB 100" \
         -c "cd GAMES" \
         -c "cd DOOM" \
         -c "DOOM.EXE" \
         -c "exit" \
         -conf <(echo -e "[sdl]\nfullscreen=false\n[sound]\nsbtype=sb16\nmididevice=mt32\noplrate=49716\n[midi]\nmpu401=intelligent\n[dos]\ncycles=4000")
