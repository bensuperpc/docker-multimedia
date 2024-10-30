#!/bin/bash
set -euo pipefail

ARG1=${1:-preset_png_webp.txt}
ARG2=${2:-e_png_webp.txt}
CPU_CORES=${3:-1}

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
parallel --jobs ${CPU_CORES} ./docker-multimedia.sh ./command_png_webp.sh {1} {2} :::: ${ARG1} ${ARG2}
