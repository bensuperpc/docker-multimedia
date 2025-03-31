#!/usr/bin/env bash
set -euo pipefail

readonly preset=${1:-4}
readonly crf=${2:-18}
readonly option=${3:-}

echo "Convert to h265 with preset $preset, crf $crf, option $option"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_h265 {
    local input_file="$1"
    local output_file="${input_file%.*}_preset${preset}_crf${crf}_option${option}.mkv"
    
    # -rc-lookahead:v 32
    ffmpeg -i "$input_file" -y -c:v libx265 -preset "$preset" -crf "$crf" -x265-params "$option" -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

    touch -r "$input_file" "$output_file"

    # Already done by -map_metadata 0
    #exiftool -TagsFromFile "$input_file" "$output_file"

    ffmpeg -i "$output_file" -i "$input_file" -lavfi ssim -f null –

    ffmpeg -i "$output_file" -i "$input_file" -lavfi psnr -f null –

    ffmpeg -i "$output_file" -i "$input_file" -lavfi libvmaf -f null –
}

export -f convert_to_h265
export preset crf option

# --progress --line-buffer --bar --halt now,fail=1
find . \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.webm" \) -type f -print0 | parallel --null convert_to_h265 "{}"
