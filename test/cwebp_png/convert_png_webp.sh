#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Wrong number of parameters: ${#}, expected 2 parameters: <preset> <z>"
    exit 1
fi

readonly preset="$1"
readonly z="$2"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_webp {
    local file="$1"
    local output_file="${file%.*}_${preset}_z${z}_lossless.webp"

    # Convert the image to WebP format -alpha_filter best -hint picture -low_memory
    cwebp -quiet -preset "$preset" -metadata all -lossless -exact -z "$z" "$file" -o "$output_file"

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

export -f convert_to_webp
export preset z

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.png" -type f -print0 | parallel --null convert_to_webp "{}"
