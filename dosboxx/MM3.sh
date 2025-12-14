#!/bin/bash

GAME_DIR="${HOME}/games/dosboxx/c"

# Check if DOSBox-X is installed
if ! command -v dosbox-x &> /dev/null; then
    echo "Error: DOSBox-X is not installed. Please install it from https://dosbox-x.com/"
    exit 1
fi

# Check if game directory exists
if [ ! -d "$GAME_DIR" ]; then
    echo "Error: Game directory $GAME_DIR does not exist."
    exit 1
fi

# Check if Might & Magic III executable exists
if [ ! -f "${GAME_DIR}/GAMES/MM3/MM3.EXE" ]; then
    echo "Error: Might & Magic III not found in $GAME_DIR."
    exit 1
fi

# Run DOSBox-X with the game, Roland MT-32, and max Sound Blaster volume
dosbox-x -fullscreen \
         -c "mount c $GAME_DIR" \
         -c "c:" \
         -c "mixer SB 100" \
         -c "cd GAMES" \
         -c "cd MM3" \
         -c "MM3.EXE" \
         -c "exit" \
         -conf <(echo -e "[sdl]\nfullscreen=false\n[sound]\nsbtype=sb16\nmididevice=mt32\noplrate=49716\n[midi]\nmpu401=intelligent\n[dos]\ncycles=4000")

# Check if DOSBox-X exited successfully
if [ $? -eq 0 ]; then
    echo "Might & Magic III has exited."
else
    echo "Error: DOSBox-X encountered an issue while running the game."
    exit 1
fi
