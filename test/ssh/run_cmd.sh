#!/bin/bash
set -euo pipefail

readonly MACHINES_FILE=${1:-machines.txt}
readonly ARGS_FILE=${2:-args.txt}
readonly REMOTE_CMD=${3:-"uname"}
readonly CPU_CORES=${4:-1}

if [ ! -f "${MACHINES_FILE}" ]; then
    echo "Error: ${MACHINES_FILE} does not exist"
    exit 1
fi

if [ ! -f "${ARGS_FILE}" ]; then
    echo "Error: ${ARGS_FILE} does not exist"
    exit 1
fi

parallel --jobs "$CPU_CORES" --xapply ssh {1} ${REMOTE_CMD} {2} :::: "${MACHINES_FILE}" :::: "${ARGS_FILE}"
