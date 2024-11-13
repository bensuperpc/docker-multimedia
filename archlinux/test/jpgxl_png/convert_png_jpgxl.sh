#!/bin/bash
set -euo pipefail

readonly compression=${1:-9}

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_jxl {
    local file="$1"
    local output_file="${file%.*}_c${compression}_lossless.jxl"

    # Convert the image to JPEG XL format with lossless compression (--quality 100 = --distance 0.0)
    cjxl --quiet --num_threads 1 --effort "$compression" --distance 0.0 --brotli_effort 11 "$file" "$output_file"

    # Copy the timestamp from the original file
    touch -r "$file" "$output_file"

    # Copy metadata from the original file
    exiftool -m -TagsFromFile "$file"  -All:All --CreatorTool --MetadataDate -XMPToolkit= "$output_file"

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

export -f convert_to_jxl
export compression

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.png" -type f -print0 | parallel --null convert_to_jxl "{}"
