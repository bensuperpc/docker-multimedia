# docker-multimedia

## _Multimedia apps in docker_

You can convert your video with ffmpeg and handbrake in docker, image based on archlinux.

## Features

- FFMPEG
- Handbrake
- ImageMagick

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
| CPU | 2 cores | 8 cores |
| GPU | - | - |
| Disk space | HDD | SSD |
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

### Start the container

Now you can start the container, it will mount the current directory in the container.

```bash
make base.run
```

### Convert video with ffmpeg H264 to AV1 (SVT-AV1)

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -c:v libsvtav1 -preset 3 -crf 18 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mp4
```

### Convert video with ffmpeg H264 to AV1 (SVT-AV1)

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -c:v libaom-av1 -crf 18 -cpu-used 3 -row-mt 1 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mp4
```

### Convert video with ffmpeg H264 to AV1 (Rav1e)

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -y -c:v librav1e -crf 18 -speed 3 -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 output.mp4
```

### Convert video with ffmpeg (h264 to h265)

```bash
ffmpeg -i video-h264.mp4 -y -c:v libx265 -crf 18 -preset slow -c:a copy -c:s copy -map 0 -map_metadata 0 -map_chapters 0 video-h265.mkv
```

### Get SSIM with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -i ref_video.mp4 -filter_complex "ssim" -f null /dev/null 
```

### Get PSNR with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -i ref_video.mp4 -filter_complex "psnr" -f null /dev/null 
```


### Get VMAF with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -i ref_video.mp4 -filter_complex "[0:v][1:v]libvmaf" -f null /dev/null 
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
