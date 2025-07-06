#!/bin/bash

# Chemin vers DOSBox-X (à adapter si nécessaire)
DOSBOX_X="/usr/bin/dosbox-x"

# Chemin du lecteur C à monter
DRIVE_C="${HOME}/games/dosboxx/c"

# Chemin relatif du jeu dans le lecteur C
GAME_PATH="GAMES/Ultima7"
GAME_EXEC="ULTIMA7.COM"

# Vérification que DOSBox-X est installé
if ! command -v "$DOSBOX_X" &> /dev/null; then
    echo "Erreur : DOSBox-X n'est pas installé ou introuvable à $DOSBOX_X."
    exit 1
fi

# Vérification que le répertoire du jeu existe
if [ ! -d "$DRIVE_C/$GAME_PATH" ]; then
    echo "Erreur : Le répertoire du jeu $DRIVE_C/$GAME_PATH n'existe pas."
    exit 1
fi

# Vérification que l'exécutable du jeu existe
if [ ! -f "$DRIVE_C/$GAME_PATH/$GAME_EXEC" ]; then
    echo "Erreur : L'exécutable $GAME_EXEC n'est pas trouvé dans $DRIVE_C/$GAME_PATH."
    exit 1
fi

# Lancement de DOSBox-X avec les paramètres
"$DOSBOX_X" \
    -c "MOUNT C $DRIVE_C" \
    -c "C:" \
    -c "CD $GAME_PATH" \
    -c "SET EMS=FALSE" \
    -c "$GAME_EXEC" \
    -c "EXIT" \
    -machine vga \
    -noconsole \
    -fastlaunch

# Vérification du code de sortie
if [ $? -eq 0 ]; then
    echo "Ultima VII a été lancé avec succès."
else
    echo "Une erreur s'est produite lors du lancement de DOSBox-X."
fi