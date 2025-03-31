#!/usr/bin/env bash
set -euo pipefail

readonly preset=${1:-4}
readonly crf=${2:-18}
readonly option=${3:-}
readonly threads=${4:-1}

echo "Convert to AV1 with preset: $preset, crf: $crf, option: $option, threads: $threads"

trap 'echo "An error occurred. Exiting." >&2; exit 1' ERR

function convert_to_av1 {
    local input_file="$1"
    local output_file="${input_file%.*}_preset${preset}_crf${crf}_option${option}.mkv"

    ffmpeg -i "$input_file" -y -loglevel warning -hide_banner -c:v libsvtav1 -preset "$preset" -crf "$crf" -svtav1-params "$option" -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 "$output_file"

    touch -r "$input_file" "$output_file"

    # Already done by -map_metadata 0)
    #exiftool -TagsFromFile "$input_file" "$output_file"

    ffmpeg -i "$output_file" -i "$input_file" -lavfi ssim -f null –

    ffmpeg -i "$output_file" -i "$input_file" -lavfi psnr -f null –

    ffmpeg -i "$output_file" -i "$input_file" -lavfi libvmaf -f null –
}

export -f convert_to_av1
export preset crf option threads

# --progress --line-buffer --bar --halt now,fail=1
find . \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mvk" -o -iname "*.webm" \) -type f -print0 | parallel --jobs "$threads" --null convert_to_av1 "{}"
