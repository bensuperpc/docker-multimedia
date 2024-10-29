#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Wrong number of parameters: ${#}, expected 2 parameters: <preset> <z>"
    exit 1
fi

function convert_to_webp {
    local file="${1}"
    local preset="${2}"
    local z="${3}"

    # Convert the image to WebP format
    cwebp -quiet -preset "${preset}" -metadata all -lossless -exact -z "${z}" "${file}" -o "${file%.*}_${preset}_z${z}.webp"
    # Copy the timestamp from the original file
    touch -r "${file}" "${file%.*}_${preset}_z${z}.webp"
    # Check if the images are different
    compare -metric AE "${file}" "${file%.*}_${preset}_z${z}.webp" null: || { echo "Error: images differ after compare check"; exit 1; }
    diff -q <(magick "${file}" ppm:-) <(magick "${file%.*}_${preset}_z${z}.webp" ppm:-) || { echo "Error: images differ after diff check"; exit 1; }
}

export -f convert_to_webp

# --progress --line-buffer --bar
find . -name "*.png" -type f -print0 | parallel -0 convert_to_webp "{}" "${1}" "${2}"
