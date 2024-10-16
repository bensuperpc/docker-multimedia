# docker-multimedia

## _Multimedia apps in docker_

All multimedia apps (FFMPEG, ImageMagick, AV1 encoders ect...) in a docker container.

## Features

- FFMPEG

## Requirements

### Software requirements

| Software | Minimum | Recommended |
| ------ | ------ | ------ |
| Linux | Any | Any |
| Docker | 19.x | 20.x |
| Make | 4.x | 4.x |

### Hardware requirements

| Hardware | Minimum | Recommended |
| ------ | ------ | ------ |
| CPU | 1 cores | 4 cores |
| Instruction set (x86) | x86-64-v1 | x86-64-v3 |
| Instruction set (ARM) | armv8 | armv8 |
| RAM | 1 GB | 16 GB |
| GPU | - | Hardware acceleration |
| Disk space | 1 GB | 10 GB |
| Internet | 10 Mbps | 100 Mbps |


## How to use docker-multimedia

Clone this repository

```bash
git clone https://github.com/bensuperpc/docker-multimedia.git
```

### Build with docker

```bash
make base
```

Test the container

```bash
make base.test
```

## Start the container

Now you can start the container, it will mount the current directory in the container.

### Convert video with ffmpeg to AV1 CRF (SVT-AV1)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v libsvtav1 -preset 4 -crf 18 -svtav1-params tune=0 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

Optional: 
- Add `-vf scale=1920:-1` to downscale the video to 1080p
- Add `-g 240` to set the keyframe interval to 240 frames (every 4 seconds at 60fps)
- Add `:film-grain=8` in svtav1-params to add film grain to the video (lower value for animation, higher value for live action with more grain)
- Add `-pix_fmt yuv420p10le` to set the pixel format to 10 bits or `-pix_fmt yuv420p` to set the pixel format to 8 bits

With **AV1AN** (WIP):

```bash
./docker-multimedia.sh av1an -i input.mkv --encoder svt-av1 --video-params "--rc 0 --crf 18 --preset 4 --tune 0 --keyint 300" --audio-params "-c:a copy" -o output.mkv
```

### Convert video with ffmpeg to AV1 CRF(AOM)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -c:v libaom-av1 -crf 18 -cpu-used 3 -row-mt 1 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video with ffmpeg to AV1 CRF (Rav1e)

```bash
./docker-multimedia.sh ffmpeg -i input.mkv -y -c:v librav1e -crf 18 -speed 3 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video with ffmpeg to h265 CRF (x265)

```bash
ffmpeg -i input.mkv -y -c:v libx265 -crf 18 -preset slow -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Convert video with ffmpeg to h265 ABR 2 pass and down to 720p (x265)

```bash
ffmpeg -i input.mkv -y -c:v libx265 -preset medium -vf scale=1280:-1 -b:v 2000k -minrate 500k -maxrate 4000k -bufsize 8000k -pass 1 -an -f null /dev/null && ffmpeg -i input.mkv -preset medium -vf scale=1280:-1 -c:v libx265 -b:v 2000k -minrate 500k -maxrate 4000k -bufsize 8000k -pass 2 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mkv
```

### Get SSIM with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi ssim -f null –
```

### Get PSNR with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi psnr -f null –
```

### Get VMAF with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i output.mkv -i input.mkv -lavfi libvmaf -f null –
```

### Cut video with ffmpeg withou re-encoding

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -ss 125 -t 75 -map_metadata 0 -vcodec copy -acodec copy out.mkv
```

### Convert images png to webp (lossless)

```bash
./docker-multimedia.sh find . -name "*.png" | parallel -eta cwebp -metadata all -lossless -exact -z 7 "{}" -o "{.}.webp" && find . -name "*.png" -exec sh -c 'touch -r "${0%.*}.png" "${0%.*}.webp"' "{}" ';'
```

### Convert images png to avif (lossless)

```bash
./docker-multimedia.sh find . -name "*.png" | parallel -eta heif-enc --avif --lossless "{}" -o "{.}.avif" && find . -name "*.png" -exec sh -c 'touch -r "${0%.*}.png" "${0%.*}.avif"' "{}" ';'
```

### Get difference between two images

```bash
compare -metric AE input1.png input2.webp null:
```

## Update submodules and base archlinux image

```bash
make update
```

## Useful links

## License

MIT
