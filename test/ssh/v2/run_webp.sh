#!/usr/bin/env bash
set -euo pipefail

readonly serverfile=${1:-"servers.txt"}
readonly jobs=${2:-7}
readonly scriptfile=${3:-"encode_cwebp.sh"}
readonly inputext=${4:-"png"}
readonly outputext=${5:-"webp"}

find . -iname "*.$outputext" -type f -delete

find . -type f -iname "*.$inputext" -print0 | \
    parallel --jobs "$jobs" --halt now,fail=1 --null --sshloginfile "$serverfile" \
    --transfer --return "{= s/\.$inputext$/.${outputext}/ =}" --cleanup \
    --basefile "$scriptfile" --workdir /tmp \
    "bash $scriptfile {}"

