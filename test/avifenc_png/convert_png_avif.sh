#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Wrong number of parameters: ${#}, expected 2 parameters: <codec> <z>"
    exit 1
fi

readonly codec=${1:-aom}
readonly z=${2:-10}

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_avif {
    local file="$1"
    local output_file="${file%.*}_${codec}_z${z}_lossless.avif"

    # Convert the image to AVIF format with lossless settings
    avifenc --lossless --speed "$z" --jobs 1 --codec "$codec" "$file" --output "$output_file"

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

     # Check if the images are identical
    if ! compare -metric AE "$file" "$output_file" null: >/dev/null 2>&1; then
        echo "Error: images differ for file $file" >&2
        exit 1
    fi
    if ! diff -q <(magick "$file" ppm:-) <(magick "$output_file" ppm:-) >/dev/null 2>&1; then
        echo "Error: images differ for file $file" >&2
        exit 1
    fi
}

export -f convert_to_avif
export codec z

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.png" -type f -print0 | parallel --null convert_to_avif "{}"

# No lossless for now
# rav1e
# svt
