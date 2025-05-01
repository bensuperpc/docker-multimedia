#!/usr/bin/env bash
set -euo pipefail

#aomenc --help
#aomdec --help
#echo "aom OK"

#twolame -version
#echo "twolame OK"

# Check multimedia tools
ffmpeg -version && echo "ffmpeg OK"
HandBrakeCLI --version && echo "HandBrakeCLI OK"
mkvmerge --version && echo "mkvtoolnix-cli OK"
mediainfo --version && echo "mediainfo OK"

# Check image encoders/decoders
cwebp -version && echo "cwebp OK"
avifenc --version && echo "avifenc OK"
cjxl --version && echo "cjxl OK"
if command -v magick > /dev/null; then
    magick -version && echo "magick OK"
else
    convert -version && echo "convert OK"
fi
gifsicle --version && echo "gifsicle OK"

# Check video encoders/decoders
SvtAv1EncApp --version && echo "SvtAv1EncApp OK"
rav1e --version && echo "rav1e OK"
dav1d --version && echo "dav1d OK"
x265 --version && echo "x265 OK"
x264 --version && echo "x264 OK"

# Check audio tools
melt -version && echo "melt OK"
flac -version && echo "flac OK"
lame --version && echo "lame OK"
sox --version && echo "sox OK"

# Check PDF tools
#pdftotext -v && echo "pdftotext (Poppler) OK"

# Check utilities
yt-dlp --version && echo "yt-dlp OK"
