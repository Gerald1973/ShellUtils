#!/bin/bash -x
MORE<<end_of_text
Example:
========
transcript_from_vdo fr myvideo date
end_of_text
CURRENT_PATH=$(pwd)
WHISPER_VENV=~/git/whisper/venv
ffmpeg -i ${2} -f mp3 ${2}.mp3
${WHISPER_VENV}/bin/whisper --language ${1} --model medium ${2}.mp3
TSTAMP=$(date +%s)
REQUEST="${CURRENT_PATH}/request_${TSTAMP}.request.text"
TRANSCRIPTED_FILE="$(basename ${2}).txt"
echo ${REQUEST}
echo "Rédige les minutes de la conversation suivante qui porte sur 'Amazon Web Service' en étant très poli, précis et structuré." >  ${REQUEST}
echo "L'heure de début est 15:00" >> ${REQUEST}
echo "la date de la réunion est ${3}" >> ${REQUEST}
cat "${CURRENT_PATH}/${TRANSCRIPTED_FILE}" >> ${REQUEST}
cat ${REQUEST} | xclip -selection clipboard
echo "Now the result is in the clipboard."
