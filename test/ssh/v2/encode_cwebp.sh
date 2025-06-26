#!/usr/bin/env bash
set -euo pipefail

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_webp {
    local input_file="$1"

    local output_file="${input_file%.*}.webp"

    # Convert the image to WebP format -q "$q"
    cwebp -quiet -metadata all -lossless -exact -mt -z 9 "$input_file" -o "$output_file"

    touch -r "$input_file" "$output_file"

    check_image_diff "$input_file" "$output_file"

    echo "Converted $input_file to $output_file successfully."
}

function check_image_diff {
    local input_file="$1"
    local output_file="$2"

    if ! compare -metric AE "$input_file" "$output_file" null: >/dev/null 2>&1; then
        echo "Error: images differ for file $input_file" >&2
        rm -f "$output_file"
        return
    fi
    if ! diff -q <(magick "$input_file" ppm:-) <(magick "$output_file" ppm:-) >/dev/null 2>&1; then
        echo "Error: images differ for file $input_file" >&2
        rm -f "$output_file"
        return
    fi
    if ! [ "$(ffmpeg -hide_banner -loglevel error -i "$input_file" -f image2pipe -pix_fmt rgba -vcodec rawvideo - | sha256sum 2>/dev/null)" \
            = "$(ffmpeg -hide_banner -loglevel error -i "$output_file" -f image2pipe -pix_fmt rgba -vcodec rawvideo - | sha256sum 2>/dev/null)" ]; then
        echo "Error: images differ for file $input_file" >&2
        rm -f "$output_file"
        return
    fi
}

export -f convert_to_webp check_image_diff

if [ $# -eq 0 ]; then
    echo "No input files provided. Exiting." >&2
    exit 1
fi

convert_to_webp "$1"
