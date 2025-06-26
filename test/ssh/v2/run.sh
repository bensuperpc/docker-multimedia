#!/usr/bin/env bash
set -euo pipefail

readonly serverfile=${1:-servers.txt}
readonly jobs=${2:-4}
readonly scriptfile=./encode_cwebp.sh

find . -iname "*.png" -type f -print0 | \
    parallel --jobs "$jobs" --null --sshloginfile "$serverfile" --transferfile {} --return {.}.webp --cleanup --basefile "$scriptfile" --workdir /tmp "$scriptfile" {}
