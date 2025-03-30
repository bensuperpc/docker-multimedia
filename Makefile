#//////////////////////////////////////////////////////////////
#//                                                          //
#//  docker-multimedia, 2025                                 //
#//  Created: 30, May, 2021                                  //
#//  Modified: 30 March, 2025                                //
#//  file: -                                                 //
#//  -                                                       //
#//  Source:                                                 //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

SUBDIRS ?= debian ubuntu fedora archlinux

# Output docker image
PROJECT_NAME ?= multimedia
AUTHOR ?= bensuperpc
REGISTRY ?= docker.io
BASE_IMAGE_REGISTRY ?= docker.io
WEB_SITE ?= bensuperpc.org

IMAGE_VERSION ?= 1.0.0
IMAGE_NAME ?= $(PROJECT_NAME)

# Max CPU and memory
CPUS ?= 8.0
CPU_SHARES ?= 1024
MEMORY ?= 16GB
MEMORY_RESERVATION ?= 2GB
TMPFS_SIZE ?= 4GB
BUILD_IMAGE_CPU_SHARES ?= 1024
BUILD_IMAGE_MEMORY ?= 16GB

TEST_IMAGE_CMD ?= ./test/test.sh
RUN_IMAGE_CMD ?=

include template/DockerImages.mk
