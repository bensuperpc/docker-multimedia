#!/bin/bash
set -euo pipefail

readonly preset=${1:-4}
readonly crf=${2:-18}

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_mkv {
    local file="$1"
    local output_file="${file%.*}_preset${preset}_crf${crf}.mkv"

    ffmpeg -i "$file" -y -c:v libsvtav1 -preset "$preset" -crf "$crf" -svtav1-params tune=0 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

    # Copy metadata from the original file (already copied with -metadata all)
    #exiftool -TagsFromFile "$file" "$output_file"

    # Check if the images are identical
    #if ! compare -metric AE "$file" "$output_file" null: >/dev/null 2>&1; then
    #    echo "Error: images differ for file $file" >&2
    #    exit 1
    #fi
    #if ! diff -q <(magick "$file" ppm:-) <(magick "$output_file" ppm:-) >/dev/null 2>&1; then
    #    echo "Error: images differ for file $file" >&2
    #    exit 1
    #fi
}

export -f convert_to_mkv
export preset crf

# --progress --line-buffer --bar --halt now,fail=1
find . \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) -type f -print0 | parallel --null convert_to_mkv "{}"
