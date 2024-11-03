#!/bin/bash
set -euo pipefail

# Check if multimedia tools are installed

ffmpeg -version
echo "ffmpeg OK"

magick -version
echo "magick OK"

HandBrakeCLI --version
echo "HandBrakeCLI OK"

# Check image encoders/decoders
cwebp -version
echo "cwebp OK"

avifenc --version
echo "avifenc OK"

cjxl --version
echo "cjxl OK"

# Check video encoders/decoders
SvtAv1EncApp --version
echo "SvtAv1EncApp OK"

x265 --version
echo "x265 OK"

x264 --version
echo "x264 OK"
