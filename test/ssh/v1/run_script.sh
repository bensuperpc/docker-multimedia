#!/usr/bin/env bash
set -euo pipefail

readonly MACHINES_FILE=${1:-machines.txt}
readonly ARGS_FILE1=${2:-args1.txt}
readonly ARGS_FILE2=${3:-args2.txt}
readonly LOCAL_SCRIPT=${4:-"script.sh"}
readonly CPU_CORES=${5:-4}
readonly SSH_PORT=${6:-22}

if [ ! -f "${MACHINES_FILE}" ]; then
    echo "Error: ${MACHINES_FILE} does not exist"
    exit 1
fi

if [ ! -f "${ARGS_FILE1}" ]; then
    echo "Error: ${ARGS_FILE1} does not exist"
    exit 1
fi

if [ ! -f "${ARGS_FILE2}" ]; then
    echo "Error: ${ARGS_FILE2} does not exist"
    exit 1
fi

if [ ! -f "${LOCAL_SCRIPT}" ]; then
    echo "Error: ${LOCAL_SCRIPT} does not exist"
    exit 1
fi

ARGS_FULL=$(mktemp --tmpdir "args_full.XXXXXX")
trap 'rm -f "$ARGS_FULL"' EXIT

parallel echo "{1} {2}" :::: "${ARGS_FILE1}" :::: "${ARGS_FILE2}" > "$ARGS_FULL"

parallel --jobs "$CPU_CORES" --xapply "ssh -p ${SSH_PORT} {1} 'bash -s -- {2}' < ${LOCAL_SCRIPT}" :::: "${MACHINES_FILE}" :::: "${ARGS_FULL}"

rm "$ARGS_FULL"
