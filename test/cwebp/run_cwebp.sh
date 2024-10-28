#!/bin/bash
set -euo pipefail

ARG1=${1:-preset_cwebp.txt}
ARG2=${2:-z_webp.txt}
CPU_CORES=${3:-1}

parallel -j ${CPU_CORES} ./docker-multimedia.sh ./command_cwebp.sh {1} {2} :::: ${ARG1} ${ARG2}
