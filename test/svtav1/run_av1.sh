#!/bin/bash
set -euo pipefail

ARG1=${1:-preset_av1.txt}
ARG2=${2:-crf_av1.txt}

parallel ./docker-multimedia.sh ./command_av1.sh {1} {2} :::: ${ARG1} ${ARG2}
