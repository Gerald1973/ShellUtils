# Guide d'installation des fichiers pour DOSBox-X

Ce document explique où placer les fichiers `.desktop` et `.sh` pour lancer des jeux comme *The Incredible Machine 2* et *Ultima VII* avec DOSBox-X sur un système Debian 12, pour un utilisateur local.

## Emplacement des fichiers

### Fichiers `.desktop`
Les fichiers `.desktop` doivent être placés dans le répertoire suivant pour un utilisateur local :
```
${HOME}/.local/share/applications/
```
- Pour l'utilisateur `louis`, cela correspond à :
  ```
  /home/louis/.local/share/applications/
  ```
- **Exemple** : Le fichier `TIM2.desktop` doit être placé dans `/home/louis/.local/share/applications/TIM2.desktop`.
- **Instructions** :
  1. Créez le répertoire s'il n'existe pas :
     ```bash
     mkdir -p /home/louis/.local/share/applications
     ```
  2. Copiez ou créez le fichier `.desktop` dans ce répertoire (par exemple, avec `nano` ou `cp`).
  3. Assurez-vous que les permissions sont correctes (lecture seule pour les autres) :
     ```bash
     chmod 644 /home/louis/.local/share/applications/TIM2.desktop
     ```

### Fichiers `.sh`
Les scripts Bash (`.sh`) associés aux fichiers `.desktop` doivent être placés dans le répertoire suivant pour un utilisateur local :
```
${HOME}/bin/
```
- Pour l'utilisateur `louis`, cela correspond à :
  ```
  /home/louis/bin/
  ```
- **Exemple** : Le fichier `TIM2.sh` doit être placé dans `/home/louis/bin/TIM2.sh`.
- **Instructions** :
  1. Créez le répertoire s'il n'existe pas :
     ```bash
     mkdir -p /home/louis/bin
     ```
  2. Copiez ou créez le fichier `.sh` dans ce répertoire.
  3. Rendez le script exécutable :
     ```bash
     chmod +x /home/louis/bin/TIM2.sh
     ```

## Configuration des fichiers

### Exemple de fichier `.desktop` : `TIM2.desktop`
Le fichier `TIM2.desktop` doit pointer vers le script correspondant. Voici un exemple de contenu :
```
[Desktop Entry]
Name=The Incredible Machine 2
Comment=Lancer le jeu The Incredible Machine 2 avec DOSBox-X
Exec=/home/louis/bin/TIM2.sh
Type=Application
Terminal=false
Icon=TIM2
Categories=Game;PuzzleGame;
Keywords=game;puzzle;retro;dos
```
- **Note** : Remplacez `Icon=TIM2` par le nom de votre icône PNG (sans extension) si vous utilisez une icône personnalisée placée dans `/home/louis/.local/share/icons/`.

### Exemple de fichier `.sh` : `TIM2.sh`
Le script `TIM2.sh` configure et lance DOSBox-X. Voici un exemple de contenu :
```
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
    -c "c:" \
    -c "cd GAMES\TIM_02" \
    -c "tim.exe" \
    -c "exit"
```
- Ajustez le chemin `GAME_DIR` si votre répertoire de jeu diffère.

## Ajout d'une icône personnalisée
- Placez une icône PNG (par exemple, `tim2.png`) dans :
  ```
  /home/louis/.local/share/icons/
  ```
- Mettez à jour le champ `Icon` dans `TIM2.desktop` avec le nom de l'icône (par exemple, `Icon=tim2`).
- Assurez-vous que les permissions sont correctes :
  ```bash
  chmod 644 /home/louis/.local/share/icons/tim2.png
  ```

## Mise à jour du système
Après avoir placé les fichiers, mettez à jour le cache des applications pour que l'icône apparaisse dans le menu :
```bash
update-desktop-database /home/louis/.local/share/applications
```
Redémarrez votre session graphique si nécessaire :
```bash
systemctl --user restart graphical-session.target
```

## Vérification
- Testez le lancement du jeu avec :
  ```bash
  gtk-launch /home/louis/.local/share/applications/TIM2.desktop
  ```
- Vérifiez que l'icône apparaît dans le menu des applications (catégorie "Jeux" ou via une recherche).

## Remarques
- Assurez-vous que DOSBox-X est installé (`sudo apt install dosbox-x`).
- Vérifiez que le répertoire du jeu (`${HOME}/games/dosboxx/c/GAMES/TIM_02`) contient `tim.exe`.
- Pour d'autres jeux comme *Ultima VII*, répétez le processus en adaptant les chemins et les exécutables dans les fichiers `.sh` et `.desktop`.