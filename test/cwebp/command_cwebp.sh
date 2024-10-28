#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters: ${#}"
    exit 1
fi

function convert_to_webp {
    local file="${1}"
    local preset="${2}"
    local z="${3}"
    cwebp -quiet -preset "${preset}" -metadata all -lossless -exact -z "${z}" "${file}" -o "${file%.*}_${preset}_z${z}.webp"
    touch -r "${file}" "${file%.*}_${preset}_z${z}.webp"
    compare -metric AE "${file}" "${file%.*}_${preset}_z${z}.webp" null: || { echo "Error: images are different"; exit 1; }
    diff -q <(magick "${file}" ppm:-) <(magick "${file%.*}_${preset}_z${z}.webp" ppm:-) || { echo "Error: images are different"; exit 1; }
}

export -f convert_to_webp

find . -name "*.png" -print0 | parallel -0 -eta convert_to_webp "{}" "${1}" "${2}"

# Disable -mt -progress
# Convert to webp and keep exact same image bit by bit, error if not
#find . -name "*.png" -print0 | parallel -0 -eta cwebp -quiet -preset ${1} -metadata all -lossless -exact -z ${2} "{}" -o "{.}_${1}_z${2}.webp"

# Keep the same timestamp as the original image
#find . -name "*.png" -exec sh -c 'touch -r "${0%.*}.png" "${0%.*}_${1}_z${2}.webp"' "{}" ${1} ${2} \;

# Compare the original image with the webp image (compare)
#find . -name "*.png" -exec sh -c 'compare -metric AE "${0%.*}.png" "${0%.*}_${1}_z${2}.webp" null: || { echo "Error: images are different"; exit 1; }' "{}" ${1} ${2} \;

# Compare the original image with the webp image (diff)
#find . -name "*.png" -exec sh -c 'diff -q <(magick "${0%.*}.png" ppm:-) <(magick "${0%.*}_${1}_z${2}.webp" ppm:-) || { echo "Error: images are different"; exit 1; }' "{}" ${1} ${2} \;
