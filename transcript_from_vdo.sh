#!/bin/bash
MORE<<end_of_text
Example:
========
transcript_from_vdo fr myvideo.mp4
end_of_text
ffmpeg -i ${2} -f mp3 ${2}.mp3
whisper --language ${1} --model medium ${2}.mp3