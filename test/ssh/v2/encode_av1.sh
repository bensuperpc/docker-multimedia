#!/usr/bin/env bash
set -euo pipefail

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_av1 {
    local input_file="$1"

    local output_file="${input_file%.*}.mkv"

    ffmpeg -i "$input_file" -y -loglevel warning -hide_banner -threads 0 -c:v libsvtav1 -preset 4 -crf 18 -svtav1-params tune=0:enable-qm=1:qm-min=0:qm-max=8 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

    touch -r "$input_file" "$output_file"

    echo "Converted $input_file to $output_file successfully."
}


export -f convert_to_av1

if [ $# -eq 0 ]; then
    echo "No input files provided. Exiting." >&2
    exit 1
fi

convert_to_av1 "$1"
