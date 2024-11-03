#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Wrong number of parameters: ${#}, expected 2 parameters: <preset> <compression>"
    exit 1
fi

readonly preset="$1"
readonly compression="$2"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_jxl {
    local file="$1"
    local output_file="${file%.*}_${preset}_c${compression}.jxl"

    # Convert the JPEG to JPEG XL with lossless JPEG mode
    cjxl --quiet --num_threads 1 --brotli_effort 11 --lossless_jpeg 1  "$file" "$output_file"

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

    # Copy metadata from the original file
    exiftool -TagsFromFile "$file" "$output_file"

    # Check if the images are identical
    if ! compare -metric AE "$file" "$output_file" null: >/dev/null 2>&1; then
        echo "Error: images differ (compare) for file $file" >&2
        exit 1
    fi
    if ! diff -q <(magick "$file" ppm:-) <(magick "$output_file" ppm:-) >/dev/null 2>&1; then
        echo "Error: images differ (diff) for file $file" >&2
        exit 1
    fi
}

export -f convert_to_jxl
export preset compression

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.jpg" -type f -print0 | parallel --null convert_to_jxl "{}"
