#!/bin/bash
set -euo pipefail

readonly ARG1=${2:-z_png_webp.txt}
readonly ARG2=${3:-q_png_webp.txt}
readonly CPU_CORES=${4:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_png_webp.sh

# Check if the files exist

if [ ! -f "${ARG1}" ]; then
    echo "Error: ${ARG1} does not exist"
    exit 1
fi

# --line-buffer
parallel --jobs "$CPU_CORES" time "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} {2} :::: "$ARG1" "$ARG2"
