#!/usr/bin/env bash
set -euo pipefail

aomenc --help || true
aomdec --help || true

#twolame -version
#echo "twolame OK"

# Check multimedia tools
ffmpeg -version
HandBrakeCLI --version
mkvmerge --version
mediainfo --version

# Check image encoders/decoders
cwebp -version
avifenc --version
cjxl --version
if command -v magick > /dev/null; then
    magick -version
else
    convert -version
fi
gifsicle --version || true

# Check video encoders/decoders
SvtAv1EncApp --version
rav1e --version
dav1d --version
x265 --version
x264 --version

# Check audio tools
#melt -version
flac -version
lame --version
sox --version

# Check PDF tools
#pdftotext -v && echo "pdftotext (Poppler) OK"

# Check utilities
yt-dlp --version
