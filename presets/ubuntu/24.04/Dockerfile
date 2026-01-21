ARG BASE_IMAGE=debian:13
FROM ${BASE_IMAGE} AS base

# ARG BASE_IMAGE_NAME
# ARG BASE_IMAGE_TAG

### @INCLUDE common.debian ###
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
# Core multimedia tools
    ffmpeg \
    x264 \
    x265 \
    melt \
    multimon-ng \
    nageru \
    libheif-plugin-aomenc \
# AV1
    dav1d \
    rav1e \
    svt-av1 \
    libheif-dev \
    libavif-dev \
    libavif-bin \
    libaom-dev \
# JPEG
    jpegoptim \
    libjpeg-dev \
    libopenjp2-7-dev \    
    libjxl-dev \
    libjxl-tools \
# WebP
    webp \
    webp-pixbuf-loader \
    handbrake-cli \
# Audio and Video Effects Plugins
    ladspa-sdk \
    frei0r-plugins-dev \
# Image and Video Processing
    libopencv-dev \
    imagemagick \
    libwmf-dev \
    libopenraw-dev \
    libraw-dev \
    libpng-dev \
# MIDI & Audio
    timidity \
    mencoder \
    sox \
    vorbis-tools \
    flac \
    lame \
    libopusenc-dev \
# Developer Tools
    build-essential \
    libdevil-dev \
    libhdf5-dev \
    libzip-dev \
    djvulibre-bin \
    wavpack \
    openmpi-bin \
# File and Metadata Management
    gvfs \
    mat2 \
    libffms2-dev \
# DVD & MPEG-2
    twolame \
# HDR
# PDF Tools
    ghostscript \
    exiv2 \
    img2pdf \
# Utilities
    mediainfo \
    ffmpegthumbnailer \
    mkvtoolnix \
    yt-dlp \
    atomicparsley \
    aria2 \
# Python Libraries
    python3-mutagen \
    python3-pycryptodome \
    python3-secretstorage \
    python3-websockets \
    python3-xattr \
# RTMP Streaming
    rtmpdump \
# Compression Tools
    xz-utils \
    gzip \
    bzip2 \
    tar \    
    zstd \
# Shell Enhancements
    bash-completion \
    && apt-get clean autoclean --yes \
    && apt-get autoremove --purge --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Not found: av1an libdvdcss dsp avisynthplus-dev libultrahdr-dev python3-pycryptodomex
# Conflicts: python3-pyxattr

FROM base AS final

### @INCLUDE common.label-and-env ###
ARG BUILD_DATE=${BUILD_DATE}
ARG VCS_REF=""
ARG VCS_URL="https://github.com/bensuperpc/docker-multimedia"
ARG OUTPUT_IMAGE_NAME="docker-multimedia"
ARG AUTHOR="Bensuperpc"
ARG URL="https://github.com/bensuperpc"

ARG IMAGE_VERSION="1.0.0"
ENV IMAGE_VERSION=${IMAGE_VERSION}

ENV TERM=xterm-256color

LABEL maintainer="Bensuperpc"
LABEL author="Bensuperpc"
LABEL description="Docker image with multimedia tools"

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name=${OUTPUT_IMAGE_NAME} \
      org.label-schema.description="multimedia tools" \
      org.label-schema.version=${IMAGE_VERSION} \
      org.label-schema.vendor=${AUTHOR} \
      org.label-schema.url=${URL} \
      org.label-schema.vcs-url=${VCS_URL} \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.docker.cmd=""

# Fix PATH for perl
ENV PATH="/usr/bin/vendor_perl:$PATH"

VOLUME [ "/work" ]
WORKDIR /work

### @INCLUDE common.entrypoint ###

#COPY --from=root-project  
CMD ["/bin/bash", "-l"]
