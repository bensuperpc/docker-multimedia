#!/usr/bin/env bash
set -euo pipefail

readonly ARG1=${1:-z_png_webp.txt}
readonly INSTANCE_COUNT=${2:-1}
readonly DOCKER_SCRIPT=docker-multimedia.sh
readonly CONVERT_SCRIPT=convert_png_webp.sh

if [ ! -f "${ARG1}" ]; then
    echo "Error: ${ARG1} does not exist" >&2
    exit 1
fi

TOTAL_CORES=$(nproc --all)
export THREADS_PER_INSTANCE=$(( TOTAL_CORES / INSTANCE_COUNT ))

if [ "$THREADS_PER_INSTANCE" -lt 1 ]; then
    export THREADS_PER_INSTANCE=1
fi

echo "Launch with $INSTANCE_COUNT Docker instances ($THREADS_PER_INSTANCE threads/instance)"

# --line-buffer
parallel --jobs "$INSTANCE_COUNT" \
    "./$DOCKER_SCRIPT" "./$CONVERT_SCRIPT" {1} "$THREADS_PER_INSTANCE" \
    :::: "$ARG1"