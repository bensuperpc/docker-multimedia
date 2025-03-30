#!/bin/bash
set -euo pipefail

readonly codec=${1:-aom}
readonly z=${2:-10}

echo "Convert PNG to AVIF with codec=$codec and z=$z"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_avif {
    local input_file="$1"
    local output_file="${input_file%.*}_${codec}_z${z}_lossless.avif"

    if [ -f "$output_file" ]; then
        echo "File $output_file already exists. Skipping." >&2
        check_image_diff "$input_file" "$output_file"
        return
    fi

    # Convert the image to AVIF format with lossless settings
    avifenc --jobs 1 --lossless --speed "$z" --codec "$codec" "$input_file" --output "$output_file"

    # Copy the timestamp from the input_file
    touch -r "$input_file" "$output_file"
    
    # Copy metadata from the original input_file
    exiftool -m -TagsFromFile "$input_file" -All:All --CreatorTool --MetadataDate -XMPToolkit= "$output_file" &>/dev/null

    # Check if the images are identical
    check_image_diff "$input_file" "$output_file"
}

function check_image_diff {
    local input_file="$1"
    local output_file="$2"

    # Check if the images are identical
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

export -f convert_to_avif check_image_diff
export codec z

# --progress --line-buffer --bar --halt now,fail=1
find . -iname "*.png" -type f -print0 | parallel --null convert_to_avif "{}"

# No lossless for now
# rav1e
# svt
