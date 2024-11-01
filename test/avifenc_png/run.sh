#!/bin/bash
set -euo pipefail

readonly ARG1=${1:-codec_png_avif.txt}
readonly ARG2=${2:-z_png_avif.txt}
readonly CPU_CORES=${3:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_png_avif.sh

# Check if the files exist

if [ ! -f "${ARG1}" ]; then
    echo "Error: ${ARG1} does not exist"
    exit 1
fi

if [ ! -f "${ARG2}" ]; then
    echo "Error: ${ARG2} does not exist"
    exit 1
fi

# --line-buffer
parallel --jobs "$CPU_CORES" time "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} {2} :::: "$ARG1" "$ARG2"
