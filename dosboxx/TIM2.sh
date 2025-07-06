#!/bin/bash

# Chemin du répertoire contenant le jeu
GAME_DIR="${HOME}/games/dosboxx/c"

# Vérifier si DOSBox-X est installé
if ! command -v dosbox-x &> /dev/null; then
    echo "DOSBox-X n'est pas installé. Veuillez l'installer."
    exit 1
fi

# Vérifier si le répertoire du jeu existe
if [ ! -d "$GAME_DIR" ]; then
    echo "Le répertoire $GAME_DIR n'existe pas."
    exit 1
fi

# Lancer DOSBox-X avec les commandes nécessaires
dosbox-x -c "mount c $GAME_DIR" \
    -fullscreen \
    -c "c:" \
    -c "cd GAMES\TIM_02" \
    -c  "tim.exe" \ 
    -c "exit"