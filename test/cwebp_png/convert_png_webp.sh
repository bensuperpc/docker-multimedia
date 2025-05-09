#!/usr/bin/env bash
set -euo pipefail

readonly z=${1:-9}
readonly threads=${2:-$(nproc --all)}

echo "Convert PNG to WebP with z=$z using $threads threads"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_webp {
    local input_file="$1"
    #local output_file="${input_file%.*}_z${z}_lossless.webp"
    local output_file="${input_file%.*}.webp"

    if [ -f "$output_file" ]; then
        echo "File $output_file already exists. Skipping." >&2
        check_image_diff "$input_file" "$output_file"
        return
    fi

    # Convert the image to WebP format -mt -q "$q"
    cwebp -quiet -metadata all -lossless -exact -z "$z" "$input_file" -o "$output_file"

    touch -r "$input_file" "$output_file"

    # Already done by -metadata all
    #exiftool -TagsFromFile "$input_file" "$output_file"

    check_image_diff "$input_file" "$output_file"
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
export z threads

# --progress --line-buffer --bar --halt now,fail=1
find . -iname "*.png" -type f -print0 | parallel --jobs "$threads" --null convert_to_webp "{}"

