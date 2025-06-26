#!/usr/bin/env bash
set -euo pipefail

readonly serverfile=${1:-"servers.txt"}
readonly jobs=${2:-6}
readonly scriptfile=${3:-"encode_av1.sh"}
readonly inputext=${4:-"mp4"}
readonly outputext=${5:-"mkv"}

find . -iname "*.$outputext" -type f -delete

find . -iname "*.$inputext" -type f -print0 | \
    parallel --jobs "$jobs" --null --sshloginfile "$serverfile" --transferfile "{}" --return "{.}.$outputext" --cleanup --basefile "$scriptfile" --workdir /tmp "./$scriptfile" "{}"
