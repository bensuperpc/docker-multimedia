#!/bin/bash
set -euo pipefail

readonly preset=${1:-4}
readonly crf=${2:-18}
readonly option=${3:-}

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_h265 {
    local file="$1"
    local output_file="${file%.*}_preset${preset}_crf${crf}_option${option}.mkv"
    
    # -rc-lookahead:v 32
    ffmpeg -i "$file" -y -c:v libx265 -preset "$preset" -crf "$crf" -x265-params "$option" -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

    # Copy metadata from the original file (already copied with -map_metadata 0)
    #exiftool -TagsFromFile "$file" "$output_file"

    # Check the SSIM, PSNR, VMAF
}

export -f convert_to_h265
export preset crf option

# --progress --line-buffer --bar --halt now,fail=1
find . \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) -type f -print0 | parallel --null convert_to_h265 "{}"
