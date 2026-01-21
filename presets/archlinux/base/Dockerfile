ARG BASE_IMAGE=archlinux:base
FROM ${BASE_IMAGE} AS base

# ARG BASE_IMAGE_NAME
# ARG BASE_IMAGE_TAG

### @INCLUDE common.archlinux ###
RUN pacman-key --init && pacman -Sy archlinux-keyring --noconfirm && pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    # --- General tools ---
    devtools \
    sdl \
    gvfs \
    openmpi \
    hdf5 \
    libzip \
    # --- Image tools ---
    imagemagick \
    opencv \
    djvulibre \
    libwmf \
    libopenraw \
    libraw \
    libpng \
    exiv2 \
    img2pdf \
    # --- Multimedia converers ---
    ffmpeg \
    handbrake-cli \
    mkvtoolnix-cli \
    nageru \
    multimon-ng \
    # --- Codecs et encoder AV1 ---
    av1an \
    dav1d \
    rav1e \
    svt-av1 \
    aom \
    # --- Codecs and JPEG tools ---
    jpegoptim \
    libjpeg-turbo \
    openjpeg2 \
    libjxl \
    gifsicle \
    # --- Codecs and WebP/HEIF tools ---
    libwebp-utils \
    webp-pixbuf-loader \
    libheif \
    libavif \
    # --- HDR tools ---
    libultrahdr \
    # --- Audio ---
    rtaudio \
    sox \
    vorbis-tools \
    flac \
    opus-tools \
    lame \
    timidity++ \
    # --- Filters and effects ---
    ladspa \
    frei0r-plugins \
    avisynthplus \
    # --- Multimédia utilities ---
    mediainfo \
    ffmpegthumbnailer \
    yt-dlp \
    atomicparsley \
    aria2 \
    rtmpdump \
    # --- Python tools ---
    python-mutagen \
    python-pycryptodome \
    python-pycryptodomex \
    python-pyxattr \
    python-secretstorage \
    python-websockets \
    python-xattr \
    # --- DVD / MPEG2 ---
    libdvdcss \
    twolame \
#   Compress tools
    xz \
    gzip \
    bzip2 \
    tar \    
    zstd \
    bash-completion \
    curl \
    gnupg \
#   Drivers
#    intel-media-driver \
#    libvdpau-va-gl \
#    opencl-driver \
#    libvpl-tools \
#   intel-media-sdk \
#    onevpl-intel-gpu \
#    libva-intel-driver \
#    intel-compute-runtime \
#   Drivers AMD
#    libva-mesa-driver \
#   Drivers Nvidia
#    nvidia-utils \
    && pacman -Scc --noconfirm

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
