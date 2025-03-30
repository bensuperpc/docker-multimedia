#!/bin/bash
set -euo pipefail

readonly MACHINES_FILE=${1:-machines.txt}
readonly ARGS_FILE=${2:-args.txt}
readonly LOCAL_SCRIPT=${3:-"script.sh"}
readonly CPU_CORES=${4:-1}

if [ ! -f "${MACHINES_FILE}" ]; then
    echo "Error: ${MACHINES_FILE} does not exist"
    exit 1
fi

if [ ! -f "${ARGS_FILE}" ]; then
    echo "Error: ${ARGS_FILE} does not exist"
    exit 1
fi

if [ ! -f "${LOCAL_SCRIPT}" ]; then
    echo "Error: ${LOCAL_SCRIPT} does not exist"
    exit 1
fi

parallel --jobs "$CPU_CORES" --xapply "ssh {1} 'bash -s -- {2}' < ${LOCAL_SCRIPT}" :::: "${MACHINES_FILE}" :::: "${ARGS_FILE}"
