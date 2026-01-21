ARG BASE_IMAGE=alpine:3.22
FROM ${BASE_IMAGE} AS base

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG

### @INCLUDE common.alpine ###
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v${BASE_IMAGE_TAG}/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v${BASE_IMAGE_TAG}/community" >> /etc/apk/repositories && \
    apk update && apk upgrade

RUN apk add --no-cache \
    # --- General tools ---
    gvfs \
    openmpi \
    hdf5 \
    libzip \
    # --- Image tools ---
    imagemagick \
    opencv \
    djvulibre \
    libwmf \
    libraw \
    libpng \
    exiv2 \
#    img2pdf \
    libwebp-tools \
    gifsicle \
    libavif-apps \
    libjxl-tools \
    # --- Multimedia converters ---
    ffmpeg \
    mkvtoolnix \
#    multimon-ng \
    handbrake \
    x265 \
    x264-dev \
    libvpx \
    # --- Codecs and AV1 tools ---
    dav1d \
    rav1e \
    aom \
    svt-av1 \
    # --- JPEG/WebP tools ---
    jpegoptim \
    libjpeg-turbo \
    openjpeg \
    libwebp \
    libheif \
    libavif \
    # --- Audio tools ---
    sox \
    vorbis-tools \
    flac \
    opus-tools \
    lame \
#    timidity++ \
    # --- Effects and plugins ---
#    ladspa-sdk \
#    frei0r \
    # --- Multimedia utilities ---
    mediainfo \
    ffmpegthumbnailer \
    yt-dlp \
    aria2 \
    rtmpdump \
    # --- Python tools ---
    py3-mutagen \
#    py3-cryptodome \
#    py3-cryptodomex \
    py3-websockets \
#    py3-xattr \
    # --- DVD / MPEG2 ---
    libdvdcss \
#    twolame \
    # --- Compress tools ---
    xz \
    gzip \
    bzip2 \
    tar \
    zstd \
    bash-completion \
    curl \
    gnupg \
    # --- useradd/groupadd ---
    shadow
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
