#!/usr/bin/env bash
set -euo pipefail
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Script, 2020                                            //
#//  Author: Bensuperpc                                      //
#//  Created: 21, November, 2020                             //
#//  Modified: 08, October, 2023                             //
#//  file: -                                                 //
#//                                                          //
#//  Source: -                                               //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

if (( $# ==  0)); then
    echo "Usage: ${0##*/} <docker image>"
    exit 1
fi

DOCKER_IMAGE="$1"
OUTPUT_PATH="${DOCKER_IMAGE}.tar.xz"
mkdir -p "$(dirname "$OUTPUT_PATH")"
docker pull "$DOCKER_IMAGE"
TMP_FILE=$(mktemp "${OUTPUT_PATH}.XXXXXX")
docker save "$DOCKER_IMAGE" | xz -9e -v -T0 > "$TMP_FILE"
mv "$TMP_FILE" "$OUTPUT_PATH"
