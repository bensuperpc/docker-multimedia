#!/bin/bash
set -euo pipefail

# Check if multimedia tools are installed

ffmpeg -version
echo "ffmpeg OK"

HandBrakeCLI --version
echo "HandBrakeCLI OK"

# Check image encoders/decoders/tools
cwebp -version
echo "cwebp OK"

avifenc --version
echo "avifenc OK"

cjxl --version
echo "cjxl OK"

magick -version
echo "magick OK"

# Check video encoders/decoders/tools
SvtAv1EncApp --version
echo "SvtAv1EncApp OK"

rav1e --version
echo "rav1e OK"

x265 --version
echo "x265 OK"

x264 --version
echo "x264 OK"

# Check audio encoders/decoders/tools
melt -version
echo "melt OK"

opusenc --version
echo "opusenc OK"

lame --version
echo "lame OK"