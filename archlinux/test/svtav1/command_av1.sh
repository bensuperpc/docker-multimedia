#!/bin/bash
set -euo pipefail

readonly preset=${1:-4}
readonly crf=${2:-18}

readonly input_file="input.mkv"
readonly output_file="output_preset_${preset}_crf_${crf}.mkv"

ffmpeg -i "$input_file" -y -c:v libsvtav1 -preset "$preset" -crf "$crf" -svtav1-params tune=0 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

