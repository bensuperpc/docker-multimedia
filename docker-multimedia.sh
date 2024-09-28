#!/bin/bash
set -euo pipefail

# Run the docker container
# --device=/dev/dri \

docker run --rm -it \
        --security-opt no-new-privileges --read-only --cap-drop SYS_ADMIN --user 1000:1000 \
        --mount type=bind,source=$(pwd),target=/work --workdir /work \
        --mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=4GB \
        --platform linux/amd64 \
        --cpus 8.0 --cpu-shares 1024 --memory 16GB --memory-reservation 2GB \
        --name qt-multimedia \
        docker.io/bensuperpc/multimedia:archlinux-base \
        "$@"
