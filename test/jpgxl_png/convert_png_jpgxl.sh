#!/usr/bin/env bash
set -euo pipefail

readonly compression=${1:-9}
readonly threads=${2:-$(nproc --all)}
readonly benchmark_file=${3:-webp_benchmark.txt}

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

    local start_time=$(date +%s)
    # --quality 100 = --distance 0.0
    cjxl --quiet --num_threads 1 --effort "$compression" --distance 0.0 --brotli_effort 11 "$input_file" "$output_file"
    local end_time=$(date +%s)

    touch -r "$input_file" "$output_file"

    exiftool -m -TagsFromFile "$input_file" -All:All --CreatorTool --MetadataDate -XMPToolkit= "$output_file" &>/dev/null

    check_image_diff "$input_file" "$output_file"

    #benchmark "$input_file" "$output_file" "$start_time" "$end_time" "$benchmark_file"
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

function benchmark {
    local input_file="$1"
    local output_file="$2"
    local start_time="$3"
    local end_time="$4"
    local output_benchmark_file="$5"

    if [ -f "$output_file" ]; then
        local input_file_size=$(stat -c %s "$input_file")
        local output_file_size=$(stat -c %s "$output_file")
        local time_taken=$(((end_time - start_time) + 1))

        local output_benchmark_result="Input file name: $input_file\n"
        output_benchmark_result+="Input file size: $input_file_size bytes\n"
        output_benchmark_result+="Output file name: $output_file\n"
        output_benchmark_result+="Output file size: $output_file_size bytes\n"
        output_benchmark_result+="Time taken: $time_taken seconds\n"
        echo -e "$output_benchmark_result" >> "$output_benchmark_file"
    else
        echo "Error: Failed to create output file $output_file" >&2
        return
    fi

    rm -f "$output_file"
}

export -f convert_to_jxl check_image_diff benchmark
export compression threads benchmark_file

# --progress --line-buffer --bar --halt now,fail=1
find . -iname "*.png" -type f -print0 | parallel --jobs "$threads" --null convert_to_jxl "{}"
