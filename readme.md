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

### Convert video with ffmpeg (H264 to AV1)

```bash
./docker-multimedia.sh ffmpeg -i input.mp4 -c:v libsvtav1 -preset 4 -crf 24 -b:v 0 -c:a copy -c:s copy -map_metadata 0 -map_chapters 0 output.mp4
```

### Get SSIM or PSNR with ffmpeg

```bash
./docker-multimedia.sh ffmpeg -i output_av1_p4_c24.mp4 -i desktop_2020.mp4 -filter_complex "ssim" -f null /dev/null 
```


## Update submodules and base archlinux image

```bash
make update
```

## Useful links

## License

MIT
