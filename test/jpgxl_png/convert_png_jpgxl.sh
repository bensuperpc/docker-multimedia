#!/usr/bin/env bash
set -euo pipefail

readonly compression=${1:-9}
readonly threads=${2:-$(nproc --all)}

echo "Convert PNG to JPEG XL with compression=$compression and threads=$threads"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_jxl {
    local input_file="$1"
    local output_file="${input_file%.*}_c${compression}_lossless.jxl"

    if [ -f "$output_file" ]; then
        echo "File $output_file already exists. Skipping." >&2
        check_image_diff "$input_file" "$output_file"
        return
    fi

    # --quality 100 = --distance 0.0
    cjxl --quiet --num_threads 1 --effort "$compression" --distance 0.0 --brotli_effort 11 "$input_file" "$output_file"

    touch -r "$input_file" "$output_file"

    exiftool -m -TagsFromFile "$input_file" -All:All --CreatorTool --MetadataDate -XMPToolkit= "$output_file" &>/dev/null

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

export -f convert_to_jxl check_image_diff
export compression

# --progress --line-buffer --bar --halt now,fail=1
find . -iname "*.png" -type f -print0 | parallel --jobs "$threads" --null convert_to_jxl "{}"
