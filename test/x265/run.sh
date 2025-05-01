#!/usr/bin/env bash
set -euo pipefail

readonly ARG1=${1:-preset_x265.txt}
readonly ARG2=${2:-crf_x265.txt}
readonly ARG3=${3:-option_x265.txt}
readonly INSTANCE_COUNT=${4:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_x265.sh

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
parallel --jobs "$INSTANCE_COUNT" time "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} {2} {3} :::: "$ARG1" "$ARG2" "$ARG3"
