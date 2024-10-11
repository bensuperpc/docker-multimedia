#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

exec ./docker-multimedia.sh ffmpeg -i input.mkv -y -c:v libsvtav1 -preset ${1} -crf ${2} -svtav1-params tune=0 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output_preset_${1}_crf_${2}.mkv
