#!/bin/bash
set -euo pipefail

readonly z=${1:-9}
readonly q=${2:-100}

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_webp {
    local input_file="$1"
    local output_file="${input_file%.*}_z${z}_q${q}_lossless.webp"

    # Convert the image to WebP format -mt
    cwebp -quiet -metadata all -lossless -exact -z "$z" -q "$q" "$input_file" -o "$output_file"

    # Copy the timestamp from the original file
    touch -r "$input_file" "$output_file"

    # Copy metadata from the original file (already copied with -metadata all)
    #exiftool -TagsFromFile "$input_file" "$output_file"

    # Check if the images are identical
    if ! compare -metric AE "$input_file" "$output_file" null: >/dev/null 2>&1; then
        echo "Error: images differ for file $input_file" >&2
        exit 1
    fi
    if ! diff -q <(magick "$input_file" ppm:-) <(magick "$output_file" ppm:-) >/dev/null 2>&1; then
        echo "Error: images differ for file $input_file" >&2
        exit 1
    fi
    if ! [ "$(ffmpeg -hide_banner -loglevel error -i "$input_file" -f image2pipe -pix_fmt rgba -vcodec rawvideo - | sha256sum)" \
            = "$(ffmpeg -hide_banner -loglevel error -i "$output_file" -f image2pipe -pix_fmt rgba -vcodec rawvideo - | sha256sum)" ] 2>&1; then
        echo "Error: images differ for file $input_file" >&2
        exit 1
    fi
}

export -f convert_to_webp
export z q

# --progress --line-buffer --bar --halt now,fail=1
find . -name "*.png" -type f -print0 | parallel --null convert_to_webp "{}"
