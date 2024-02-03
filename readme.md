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

### Convert video with ffmpeg (h264 to h265)

```bash
ffmpeg -threads 0 -i video-h264.mp4 -c:v libx265 -vtag hvc1 -bf 4 -map_metadata 0 -map 0 -crf 18 -preset slow -c:a copy -c:s copy video-h265.mkv
```

More FFMPeg options [here](https://trac.ffmpeg.org/wiki/Encode/H.265)

```bash
-maxrate 1M -bufsize 2M -profile:v main10
```

## Update submodules and base archlinux image

```bash
make update
```

## Useful links

## License

MIT
