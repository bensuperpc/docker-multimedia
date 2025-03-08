ARG BASE_IMAGE=archlinux:base
FROM ${BASE_IMAGE} AS base

RUN pacman-key --init && pacman -Sy archlinux-keyring --noconfirm && pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
#   ffmpeg and video tools
    ffmpeg \
    mlt \
    libexif \
    rtaudio \
    multimon-ng \
    nageru \
#   AV1
    av1an \
    dav1d \
    rav1e \
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
    webp-pixbuf-loader \
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
    sdl \
    devil \
    hdf5 \
    libzip \
    djvulibre \
    wavpack \
    openmpi \
    gvfs \
    mat2 \
    ffms2 \
    dsp \
    a2jmidid \
    libffado \
    menyoki \
#   DVD
    libdvdcss \
#   MPEG2
    twolame \
    # HDR    
    libultrahdr \
    # Sound    
    sox \
    vorbis-tools \
    flac \
    opus-tools \
    # PDF   
    ghostscript \ 
    exiv2 \
    img2pdf \
# Utils
    mediainfo \    
    ffmpegthumbnailer \    
    mkvtoolnix-cli \
#   yt-dlp
    yt-dlp \
    atomicparsley \
    aria2 \
    python-mutagen \
    python-pycryptodome \
    python-pycryptodomex \
    python-pyxattr \
    python-secretstorage \
    python-websockets \
    python-xattr \
    rtmpdump \
#   Compress tools
    xz \
    gzip \
    bzip2 \
    tar \    
    zstd \
    bash-completion \
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

ARG BUILD_DATE=${BUILD_DATE}
ARG VCS_REF=""
ARG VCS_URL="https://github.com/bensuperpc/docker-multimedia"
ARG OUTPUT_IMAGE_NAME=${OUTPUT_IMAGE_NAME}
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

COPY --from=root-project common/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh && chown root:root /entrypoint.sh

#ARG USERNAME=user
#RUN useradd -m "${USERNAME}"
# Add color to bash
#RUN echo PS1="'\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '" >> "/home/${USERNAME}/.bashrc"
#USER ${USERNAME}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "-l"]
