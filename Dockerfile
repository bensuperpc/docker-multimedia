ARG DOCKER_IMAGE=archlinux:base
FROM ${DOCKER_IMAGE} as base

RUN pacman-key --init && pacman -Sy archlinux-keyring --noconfirm && pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    ffmpeg \
    av1an \
    dav1d \
    rav1e \
    av1an \
    ladspa \
    frei0r-plugins \
    avisynthplus \
    opencv \
    imagemagick \
    libwebp \
    libheif \
    libavif \
    libwmf \
    libopenraw \
    libraw \
    handbrake-cli \
    bash \
    && pacman -Scc --noconfirm

#    onevpl-intel-gpu intel-media-sdk
#    nvidia-utils

#FROM base as builder

FROM base as final
# COPY --from=builder / /

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL="https://github.com/bensuperpc/docker-multimedia"
ARG PROJECT_NAME=""
ARG AUTHOR="Bensuperpc"
ARG URL="https://github.com/bensuperpc"

ARG IMAGE_VERSION="1.0.0"
ENV IMAGE_VERSION=${IMAGE_VERSION}

LABEL maintainer="Bensuperpc <bensuperpc@gmail.com>"
LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL description="A multimedia docker image for building multimedia project"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name=${PROJECT_NAME} \
      org.label-schema.description="multimedia" \
      org.label-schema.version=${IMAGE_VERSION} \
      org.label-schema.vendor=${AUTHOR} \
      org.label-schema.url=${URL} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd="docker build -t bensuperpc/multimedia:latest -f Dockerfile ."


ARG USER_NAME=testuser
ENV HOME=/home/$USER_NAME
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd -g $USER_GID -o $USER_NAME
RUN useradd -m -u $USER_UID -g $USER_GID -o -s /bin/bash $USER_NAME
USER $USER_NAME

WORKDIR /work

CMD ["/bin/bash", "-l"]

