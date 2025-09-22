#!/usr/bin/env bash
set -euo pipefail

REGISTRY="docker.io"
IMAGE="bensuperpc/multimedia"
TAG="1.0.0-archlinux"

DOCKER_IMAGE="multimedia-$(uuidgen)"

CPUS="6"
CPU_SHARES="1024"
RES_RAM="4GB"
MAX_RAM="16GB"
TMPFS_SIZE="4g"

PUID="$(id -u)"
PGID="$(id -g)"

docker run --rm \
        --security-opt no-new-privileges --cap-drop SYS_ADMIN -e PUID="$PUID" -e PGID="$PGID" \
        --mount type=bind,source=$(pwd),target=/work --workdir /work \
        --mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$TMPFS_SIZE \
        --platform linux/amd64 \
        --cpus "$CPUS" --cpu-shares "$CPU_SHARES" --memory-reservation "$RES_RAM" --memory "$MAX_RAM" \
        --name "$DOCKER_IMAGE" \
        "$REGISTRY/$IMAGE:$TAG" \
        "$@"
