#!/usr/bin/env bash
set -euo pipefail

readonly ARG1=${1:-e_png_jpgxl.txt}
readonly CPU_CORES=${2:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_png_jpgxl.sh

if [ ! -f "${ARG1}" ]; then
    echo "Error: ${ARG1} does not exist"
    exit 1
fi

# --line-buffer
parallel --jobs "$CPU_CORES" time "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} :::: "$ARG1"
