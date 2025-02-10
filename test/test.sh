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

#aomenc --help
#aomdec --help
#echo "aom OK"

cjxl --version
echo "cjxl OK"

magick -version || convert -version
echo "magick OK"

# Check video encoders/decoders/tools
SvtAv1EncApp --version
echo "SvtAv1EncApp OK"

rav1e --version
echo "rav1e OK"

dav1d --version
echo "dav1d OK"

x265 --version
echo "x265 OK"

x264 --version
echo "x264 OK"

#twolame -version
#echo "twolame OK"

# Check audio encoders/decoders/tools
melt -version
echo "melt OK"

flac -version
echo "flac OK"

#opusenc --version
#echo "opusenc OK"

lame --version
echo "lame OK"

#timidity -version
#echo "timidity OK"
