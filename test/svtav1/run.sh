#!/bin/bash
set -euo pipefail

ARG1=${1:-preset.txt}
ARG2=${2:-crf.txt}

parallel ./command.sh {1} {2} :::: ${ARG1} ${ARG2}
