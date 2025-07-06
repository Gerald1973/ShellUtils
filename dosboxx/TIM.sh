#!/bin/bash

# Script to run The Incredible Machine using DOSBox-X

# Game directory
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

# Check if TIM.EXE exists in the game directory
if [ ! -f "$GAME_DIR/GAMES/TIM/TIM.EXE" ]; then
    echo "Error: TIM.EXE not found in $GAME_DIR."
    exit 1
fi

# Run DOSBox-X with the game
dosbox-x -c "mount c $GAME_DIR" \
         -c "c:" \
         -c "cd GAMES" \
         -c "cd TIM" \
         -c "TIM.EXE" \
         -c "exit" \
         -conf <(echo -e "[sdl]\nfullscreen=false\n[sound]\nsbtype=sb16\n[dos]\ncycles=4000")

# Check if DOSBox-X exited successfully
if [ $? -eq 0 ]; then
    echo "The Incredible Machine has exited."
else
    echo "Error: DOSBox-X encountered an issue while running the game."
    exit 1
fi