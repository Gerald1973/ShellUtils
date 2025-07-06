#!/bin/bash

# Check if a game name parameter is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a game name (e.g., MM3)"
    exit 1
fi

GAME_NAME="$1"
SCRIPT_SRC="${GAME_NAME}.sh"
DESKTOP_SRC="${GAME_NAME}.desktop"
ICON_SRC="${GAME_NAME}.png"
SCRIPT_DEST="${HOME}/games/dosboxx/${GAME_NAME}.sh"
DESKTOP_DEST="${HOME}/.local/share/applications/${GAME_NAME}.desktop"
ICON_DEST="${HOME}/.local/share/icons/${GAME_NAME}.png"

# Check if source files exist
for file in "$SCRIPT_SRC" "$DESKTOP_SRC" "$ICON_SRC"; do
    if [ ! -f "$file" ]; then
        echo "Error: Source file $file not found in current directory"
        exit 1
    fi
done

# Create destination directories if they don't exist
mkdir -p "${HOME}/games/dosboxx" "${HOME}/.local/share/applications" "${HOME}/.local/share/icons"

# Copy the script file and make it executable
cp "$SCRIPT_SRC" "$SCRIPT_DEST"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy $SCRIPT_SRC to $SCRIPT_DEST"
    exit 1
fi
chmod +x "$SCRIPT_DEST"
echo "Copied and made executable: $SCRIPT_DEST"

# Copy the desktop file and make it executable
cp "$DESKTOP_SRC" "$DESKTOP_DEST"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy $DESKTOP_SRC to $DESKTOP_DEST"
    exit 1
fi
chmod +x "$DESKTOP_DEST"
echo "Copied and made executable: $DESKTOP_DEST"

# Copy the icon file
cp "$ICON_SRC" "$ICON_DEST"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy $ICON_SRC to $ICON_DEST"
    exit 1
fi
echo "Copied: $ICON_DEST"

# Refresh GNOME application menu if running GNOME
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "gnome" ]; then
    if command -v gio >/dev/null 2>&1; then
        gio mime "application/x-desktop" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "GNOME application menu refreshed successfully"
        else
            echo "Warning: Failed to refresh GNOME application menu with gio"
        fi
    else
        echo "Warning: gio not found, GNOME menu may not refresh automatically"
        echo "You may need to log out and log back in or restart GNOME Shell"
    fi
else
    echo "Not running GNOME, skipping application menu refresh"
fi

echo "All files for $GAME_NAME installed successfully!"