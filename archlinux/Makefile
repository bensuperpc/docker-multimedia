#//////////////////////////////////////////////////////////////
#//                                                          //
#//  docker-multimedia, 2024                                 //
#//  Created: 30, May, 2021                                  //
#//  Modified: 14 November, 2024                             //
#//  file: -                                                 //
#//  -                                                       //
#//  Source:                                                 //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

# Base image
BASE_IMAGE_NAME := archlinux
BASE_IMAGE_TAGS := base
BASE_IMAGE_REGISTRY := docker.io

# Output docker image
PROJECT_NAME := multimedia
AUTHOR := bensuperpc
REGISTRY := docker.io
IMAGE_VERSION := 1.0.0
WEB_SITE := bensuperpc.org

# Max CPU and memory
CPUS := 8.0
CPU_SHARES := 1024
MEMORY := 16GB
MEMORY_RESERVATION := 2GB
TMPFS_SIZE := 4GB
BUILD_CPU_SHARES := 1024
BUILD_MEMORY := 16GB

TEST_CMD := ./test/test.sh
RUN_CMD :=

include DockerImage.mk