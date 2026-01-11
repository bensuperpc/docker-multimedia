#//////////////////////////////////////////////////////////////
#//                                                          //
#//  Generic docker images, 2025                             //
#//  Created: 30, May, 2021                                  //
#//  Modified: 21 September, 2025                            //
#//  file: -                                                 //
#//  -                                                       //
#//  Source:                                                 //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

# =====================
# AUTOMATED VARIABLES
# =====================
GIT_SHA ?= $(shell git rev-parse HEAD)
GIT_ORIGIN ?= $(shell git config --get remote.origin.url) 

DATE ?= $(shell date -u +"%Y%m%d")
UUID ?= $(shell uuidgen)

CURRENT_USER ?= $(shell whoami)
UID ?= $(shell id -u ${CURRENT_USER})
GID ?= $(shell id -g ${CURRENT_USER})

# =====================
# USER DEFINED VARIABLES
# =====================

SUBDIRS ?= archlinux debian ubuntu

DOCKER_COMPOSITE_SOURCES ?= common.label-and-env common.entrypoint common.user common.locales

DOCKER_COMPOSITE_FOLDER_PATH ?= common/
DOCKER_COMPOSITE_PATH ?= $(addprefix $(DOCKER_COMPOSITE_FOLDER_PATH),$(DOCKER_COMPOSITE_SOURCES))

AUTHOR ?= bensuperpc
WEB_SITE ?= bensuperpc.org

# Base docker image
BASE_IMAGE_REGISTRY ?= docker.io
BASE_IMAGE_PATH ?= 
BASE_IMAGE_NAME ?= archlinux
BASE_IMAGE_TAGS ?= base

# Output docker image
OUTPUT_IMAGE_REGISTRY ?= docker.io
OUTPUT_IMAGE_PATH ?= bensuperpc
OUTPUT_IMAGE_NAME ?= multimedia
OUTPUT_IMAGE_VERSION ?= 1.0.0

TEST_IMAGE_CMD ?= ./test/test.sh
TEST_IMAGE_ARGS ?= --user $(UID):$(GID)
RUN_IMAGE_CMD ?=
RUN_IMAGE_ARGS ?= --user $(UID):$(GID)

BUILD_IMAGE_ARGS ?=

# Docker config
DOCKERFILE ?= Dockerfile
DOCKER_EXEC ?= docker
PROGRESS_OUTPUT ?= plain
BUILD_CONTEXT ?= $(shell pwd)

BIND_HOST_DIR ?= $(shell pwd)
BIND_CONTAINER_DIR ?= /work

# --push
DOCKER_DRIVER ?= --load
ARCH_LIST ?= linux/amd64
comma?= ,
PLATFORMS ?= $(subst $() $(),$(comma),$(ARCH_LIST))

# Max CPU and memory
CPUS ?= 8.0
CPU_SHARES ?= 1024
MEMORY ?= 16GB
MEMORY_RESERVATION ?= 2GB
TMPFS_SIZE ?= 4g
BUILD_IMAGE_CPU_SHARES ?= 1024
BUILD_IMAGE_MEMORY ?= 16GB

TAG_WITH_BASE_IMAGE_NAME ?= yes

# All images have same parameters
ALL_SAME_BASE_IMAGE_REGISTRY ?= yes
ALL_SAME_BASE_IMAGE_PATH ?= yes
# ALL_SAME_BASE_IMAGE_NAME ?= yes
ALL_SAME_TAG_WITH_BASE_IMAGE_NAME ?= yes
ALL_SAME_OUTPUT_IMAGE_REGISTRY ?= yes
ALL_SAME_OUTPUT_IMAGE_PATH ?= yes
ALL_SAME_OUTPUT_IMAGE_NAME ?= yes
ALL_SAME_OUTPUT_IMAGE_VERSION ?= yes
ALL_SAME_BUILD_ARGS ?= yes

# Custom targets
CUSTOM_TARGET ?= help

TARGETS := all build test run clean purge update push pull version generate ${CUSTOM_TARGET}

# Override sub-makefile variables
MAKEFILE_VARS ?= AUTHOR="$(AUTHOR)" PLATFORMS="$(PLATFORMS)" \
	CPUS="$(CPUS)" CPU_SHARES="$(CPU_SHARES)" MEMORY="$(MEMORY)" MEMORY_RESERVATION="$(MEMORY_RESERVATION)" \
	BUILD_IMAGE_CPU_SHARES="$(BUILD_IMAGE_CPU_SHARES)" BUILD_IMAGE_MEMORY="$(BUILD_IMAGE_MEMORY)" WEB_SITE="$(WEB_SITE)" BIND_HOST_DIR="$(BIND_HOST_DIR)" \
	DOCKERFILE="$(DOCKERFILE)" DOCKER_EXEC="$(DOCKER_EXEC)" DOCKER_DRIVER="$(DOCKER_DRIVER)" BUILD_CONTEXT="$(BUILD_CONTEXT)" \
	GIT_SHA="$(GIT_SHA)" GIT_ORIGIN="$(GIT_ORIGIN)" DATE="$(DATE)" UUID="$(UUID)" \
	UID="$(UID)" GID="$(GID)" TMPFS_SIZE="$(TMPFS_SIZE)" BIND_CONTAINER_DIR="$(BIND_CONTAINER_DIR)" \
	TEST_IMAGE_CMD="$(TEST_IMAGE_CMD)" RUN_IMAGE_CMD="$(RUN_IMAGE_CMD)" PROGRESS_OUTPUT="$(PROGRESS_OUTPUT)" \
	DOCKER_COMPOSITE_FOLDER_PATH="$(DOCKER_COMPOSITE_FOLDER_PATH)" \
	DOCKER_COMPOSITE_SOURCES="$(DOCKER_COMPOSITE_SOURCES)" \
	DOCKER_COMPOSITE_PATH="$(DOCKER_COMPOSITE_PATH)"

ifeq ($(strip $(ALL_SAME_BASE_IMAGE_REGISTRY)),yes)
	MAKEFILE_VARS += BASE_IMAGE_REGISTRY="$(BASE_IMAGE_REGISTRY)"
endif
ifeq ($(strip $(ALL_SAME_BASE_IMAGE_PATH)),yes)
	MAKEFILE_VARS += BASE_IMAGE_PATH="$(BASE_IMAGE_PATH)"
endif
# ifeq ($(strip $(ALL_SAME_BASE_IMAGE_NAME)),yes)
# 	MAKEFILE_VARS += BASE_IMAGE_NAME="$(BASE_IMAGE_NAME)"
# endif
ifeq ($(strip $(ALL_SAME_OUTPUT_IMAGE_REGISTRY)),yes)
	MAKEFILE_VARS += OUTPUT_IMAGE_REGISTRY="$(OUTPUT_IMAGE_REGISTRY)"
endif
ifeq ($(strip $(ALL_SAME_OUTPUT_IMAGE_PATH)),yes)
	MAKEFILE_VARS += OUTPUT_IMAGE_PATH="$(OUTPUT_IMAGE_PATH)"
endif
ifeq ($(strip $(ALL_SAME_OUTPUT_IMAGE_NAME)),yes)
	MAKEFILE_VARS += OUTPUT_IMAGE_NAME="$(OUTPUT_IMAGE_NAME)"
endif
ifeq ($(strip $(ALL_SAME_OUTPUT_IMAGE_VERSION)),yes)
	MAKEFILE_VARS += OUTPUT_IMAGE_VERSION="$(OUTPUT_IMAGE_VERSION)"
endif
ifeq ($(strip $(ALL_SAME_BUILD_ARGS)),yes)
	MAKEFILE_VARS += BUILD_IMAGE_ARGS="$(BUILD_IMAGE_ARGS)"
endif
ifeq ($(strip $(ALL_SAME_TAG_WITH_BASE_IMAGE_NAME)),yes)
	MAKEFILE_VARS += TAG_WITH_BASE_IMAGE_NAME="$(TAG_WITH_BASE_IMAGE_NAME)"
endif

.PHONY: default
default: $(addsuffix .test, $(SUBDIRS))

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	rm -rf $@/common/
	cp -r $(DOCKER_COMPOSITE_FOLDER_PATH) $@/common/

.PHONY: $(TARGETS)
$(TARGETS): %: $(addsuffix .%,$(SUBDIRS))

.SECONDEXPANSION:
$(foreach t,$(TARGETS),$(addsuffix .$(t),$(SUBDIRS))): $$(basename $$@)
	$(MAKE) $(MAKEFILE_VARS) -C $(basename $@) $(subst .,,$(suffix $@))

.SECONDEXPANSION:
$(foreach d,$(SUBDIRS),$(d).%): $(subst $(firstword $(subst ., ,$@)).,,$@)
	@version_action=$(subst $(firstword $(subst ., ,$@)).,,$@); \
	echo ">>> Copying for $(firstword $(subst ., ,$@))"; \
	rm -rf $(firstword $(subst ., ,$@))/common/; \
	cp -r $(DOCKER_COMPOSITE_FOLDER_PATH) $(firstword $(subst ., ,$@))/common/; \
	echo ">>> Executing in $(firstword $(subst ., ,$@)): $$version_action"; \
	$(MAKE) $(MAKEFILE_VARS) -C $(firstword $(subst ., ,$@)) $$version_action
