#!/usr/bin/env bash
set -euo pipefail

readonly MACHINES_FILE=${1:-machines.txt}
readonly ARGS_FILE1=${2:-args1.txt}
readonly ARGS_FILE2=${2:-args2.txt}
readonly LOCAL_SCRIPT=${3:-"script.sh"}
readonly CPU_CORES=${4:-1}

if [ ! -f "${MACHINES_FILE}" ]; then
    echo "Error: ${MACHINES_FILE} does not exist"
    exit 1
fi

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

ARGS_FULL=$(mktemp)
parallel echo "{1} {2}" :::: "${ARGS_FILE1}" :::: "${ARGS_FILE2}" > "$ARGS_FULL"

parallel --jobs "$CPU_CORES" --xapply "ssh {1} 'bash -s -- {2}' < ${LOCAL_SCRIPT}" :::: "${MACHINES_FILE}" :::: "${ARGS_FULL}"

rm "$ARGS_FULL"
