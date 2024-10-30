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
    local output_file="${file%.*}_${preset}_c${compression}_lossless.jxl"

    # Convert the image to JPEG XL format with lossless compression --lossless_jpeg=0
    cjxl "$file" "$output_file" --effort "$compression" --distance 0.0 --brotli_effort 11

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

    # Check if the images are identical
    if ! compare -metric AE "$file" "$output_file" null: >/dev/null 2>&1; then
        echo "Error: images differ for file $file" >&2
        exit 1
    fi
}

export -f convert_to_jxl
export preset compression

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.png" -type f -print0 | parallel --null convert_to_jxl "{}"
