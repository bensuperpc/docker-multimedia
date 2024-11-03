#!/bin/bash
set -euo pipefail

REGISTRY="docker.io"
IMAGE="bensuperpc/multimedia"
TAG="archlinux-base"

DOCKER_IMAGE="multimedia-$(uuidgen)"

CPUS="$(nproc --all)"
CPU_SHARES="1024"
RES_RAM="2GB"
MAX_RAM="16GB"
TMP_RAM="4GB"

PUID="$(id -u)"
PGID="$(id -g)"

docker run --rm -it \
        --security-opt no-new-privileges --read-only --cap-drop SYS_ADMIN --user "$PUID:$PGID" \
        --mount type=bind,source=$(pwd),target=/work --workdir /work \
        --mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$TMP_RAM \
        --platform linux/amd64 \
        --cpus "$CPUS" --cpu-shares "$CPU_SHARES" --memory-reservation "$RES_RAM" --memory "$MAX_RAM" \
        --name "$DOCKER_IMAGE" \
        "$REGISTRY/$IMAGE:$TAG" \
        "$@"


# Run the docker container
# --device=/dev/dri \
