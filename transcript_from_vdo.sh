#!/bin/bash
set -euo pipefail

WHISPER_VENV="$HOME/git/whisper/venv"
WHISPER="$WHISPER_VENV/bin/whisper"

LANGUAGE="${1:-fr}"
VIDEO="$2"
MEETING_DATE="${3:-$(date +%F)}"

CURRENT_PATH="$(pwd)"

if [[ ! -f "$VIDEO" ]]; then
    echo "Erreur : fichier introuvable : $VIDEO" >&2
    exit 1
fi

if [[ ! -x "$WHISPER" ]]; then
    echo "Erreur : Whisper introuvable : $WHISPER" >&2
    exit 1
fi

VIDEO_BASENAME="$(basename "$VIDEO")"
VIDEO_STEM="${VIDEO_BASENAME%.*}"

TRANSCRIPTED_FILE="${CURRENT_PATH}/${VIDEO_STEM}.txt"

echo "=== Transcription Whisper ==="
echo "Fichier : $VIDEO"
echo "Langue  : $LANGUAGE"
echo "Modèle  : large-v3"
echo

"$WHISPER" "$VIDEO" \
    --language "$LANGUAGE" \
    --task transcribe \
    --model large-v3 \
    --fp16 True \
    --output_dir "$CURRENT_PATH" \
    --output_format txt \
    --initial_prompt "Réunion professionnelle hebdomadaire en français. Contexte informatique, systèmes Linux, Debian, DevOps, infrastructure, réseau, sécurité, logiciels et administration système. Conserver précisément les noms propres, acronymes, termes techniques, noms de produits et commandes."

if [[ ! -f "$TRANSCRIPTED_FILE" ]]; then
    echo "Erreur : transcription introuvable : $TRANSCRIPTED_FILE" >&2
    exit 1
fi

TSTAMP="$(date +%s)"
REQUEST="${CURRENT_PATH}/request_${TSTAMP}.request.text"

cat > "$REQUEST" <<EOF
Rédige, en français, les minutes du meeting hebdomadaire en étant très poli, précis et structuré.

L'heure de début est 11:00.
La date de la réunion est ${MEETING_DATE}.

Voici la transcription :

EOF

cat "$TRANSCRIPTED_FILE" >> "$REQUEST"

xclip -selection clipboard < "$REQUEST"

echo
echo "Transcription : $TRANSCRIPTED_FILE"
echo "Requête        : $REQUEST"
echo "La requête complète est maintenant dans le presse-papiers."