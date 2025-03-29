#!/bin/bash
set -euo pipefail

readonly ARG1=${1:-preset_svtav1.txt}
readonly ARG2=${2:-crf_svtav1.txt}
readonly ARG3=${3:-option_svtav1.txt}
readonly CPU_CORES=${3:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_svtav1.sh

if [ ! -f "${ARG1}" ]; then
    echo "Error: ${ARG1} does not exist"
    exit 1
fi

if [ ! -f "${ARG2}" ]; then
    echo "Error: ${ARG2} does not exist"
    exit 1
fi

if [ ! -f "${ARG3}" ]; then
    echo "Error: ${ARG3} does not exist"
    exit 1
fi

# --line-buffer
parallel --jobs "$CPU_CORES" time "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} {2} {3} :::: "$ARG1" "$ARG2" "$ARG3"
