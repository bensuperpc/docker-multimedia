ARG DOCKER_IMAGE=archlinux:base
FROM ${DOCKER_IMAGE} AS base

RUN pacman-key --init && pacman -Sy archlinux-keyring --noconfirm && pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
#   ffmpeg and video tools
    ffmpeg \
#   AV1
    av1an \
    dav1d \
    rav1e \
    av1an \
    svt-av1 \
    libheif \
    libavif \
    aom \
#   Jpeg
    jpegoptim \
    libjpeg-turbo \
    openjpeg2 \    
    libjxl \
#   WebP
    libwebp \
    handbrake-cli \
    ladspa \
    frei0r-plugins \
    avisynthplus \
    opencv \
    imagemagick \
    libwmf \
    libopenraw \
    libraw \
    libpng \
    timidity++ \    
    mencoder \
    devtools \
#   MPEG2
    twolame \
    # HDR    
    libultrahdr \
    # Sound    
    sox \    
    vorbis-tools \
    # PDF   
    ghostscript \   
    exiv2 \
# Utils
    mediainfo \    
    ffmpegthumbnailer \    
    mkvtoolnix-cli \
#   Compress tools
    xz \
    gzip \
    bzip2 \
    tar \    
    zstd \
#   Drivers intel
    intel-media-sdk \
    onevpl-intel-gpu \
    libva-intel-driver \
    intel-compute-runtime \
#   Drivers AMD
    libva-mesa-driver \
#   Drivers Nvidia
    && pacman -Scc --noconfirm
  
#    nvidia-utils

FROM base AS final

ARG BUILD_DATE=""
ARG VCS_REF=""
ARG VCS_URL="https://github.com/bensuperpc/docker-multimedia"
ARG PROJECT_NAME=""
ARG AUTHOR="Bensuperpc"
ARG URL="https://github.com/bensuperpc"

ARG IMAGE_VERSION="1.0.0"
ENV IMAGE_VERSION=${IMAGE_VERSION}

ENV TERM=xterm-256color

LABEL maintainer="Bensuperpc"
LABEL author="Bensuperpc"
LABEL description="Docker image with qt"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name=${PROJECT_NAME} \
      org.label-schema.description="qt" \
      org.label-schema.version=${IMAGE_VERSION} \
      org.label-schema.vendor=${AUTHOR} \
      org.label-schema.url=${URL} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd=""

VOLUME [ "/work" ]
WORKDIR /work

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/bin/bash" ]
