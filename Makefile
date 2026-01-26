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

# ==============================================================================
# Preset detection
# ==============================================================================
PRESET_DIR       ?= presets

# # Find all preset.mk files in presets/ subfolders
PRESET_FILES := $(shell find $(PRESET_DIR) -name "preset.mk")
# # Transform 'presets/debian/bookworm/preset.mk' into 'debian/bookworm'
ALL_PRESETS  := $(patsubst $(PRESET_DIR)/%/preset.mk,%,$(PRESET_FILES))

CURRENT_TARGET_NAME := $(firstword $(MAKECMDGOALS))

POSSIBLE_PRESET := $(basename $(CURRENT_TARGET_NAME))

ifneq ($(wildcard $(PRESET_DIR)/$(POSSIBLE_PRESET)/preset.mk),)
    include $(PRESET_DIR)/$(POSSIBLE_PRESET)/preset.mk
    PRESET_PATH := $(PRESET_DIR)/$(POSSIBLE_PRESET)
endif

# ==============================================================================
# Main config Makefile for Docker SDK Images
# ==============================================================================
AUTHOR         ?= bensuperpc
WEB_SITE       ?= bensuperpc.org

# Registries
BASE_IMAGE_REGISTRY   ?= docker.io
BASE_IMAGE_PATH       ?=
OUTPUT_IMAGE_REGISTRY ?= docker.io
OUTPUT_IMAGE_PATH     ?= bensuperpc
OUTPUT_IMAGE_VERSION  ?= 1.0.0

# Docker Config
DOCKER_EXEC      ?= docker
PROGRESS_OUTPUT  ?= plain
# CI need docker-container-builder
CI ?= false
ifeq ($(CI),true)
	DOCKER_DRIVER := --push
	BUILD_IMAGE_ARGS += --sbom=true --provenance=true
	BUILD_IMAGE_ARGS += --cache-from=type=registry,ref=$(OUTPUT_IMAGE_FINAL):cache
	BUILD_IMAGE_ARGS += --cache-to=type=registry,ref=$(OUTPUT_IMAGE_FINAL):cache,mode=max
else
	DOCKER_DRIVER := --load
endif
ARCH_LIST        ?= linux/amd64
PLATFORMS        ?= $(subst $(space),$(comma),$(strip $(ARCH_LIST)))
TMPFS_SIZE       ?= 4g

# Build Resources
BUILD_MEMORY     ?= 16GB
BUILD_CPU_SHARES ?= 1024

# Folders
COMMON_DIR       ?= common

# Tagging flags
TAG_WITH_BASE_NAME ?= yes
TAG_WITH_DATE      ?= yes
TAG_WITH_GIT_SHA   ?= yes
TAG_LATEST        ?= yes

DOCKER_COMPOSITE_SOURCES = common.label-and-env common.entrypoint common.user \
    common.debian common.gosu common.archlinux common.alpine common.old.debian

# RUN/TEST
TEST_IMAGE_CMD  ?= ls
TEST_IMAGE_ARGS ?=
RUN_IMAGE_CMD   ?= ls
RUN_IMAGE_ARGS  ?=

# Ressources Run/Test
MEMORY		  ?= 16GB
MEMORY_RESERVATION ?= 1GB
CPUS		  ?= 8.0
CPU_SHARES	  ?= 1024

BIND_HOST_DIR := $(shell pwd)
BIND_CONTAINER_DIR ?= /work
WORKDIR ?= /work

ROOT_PROJECT := $(shell pwd)

# Automatic variables
CURRENT_USER = $(shell whoami)
UID = $(shell id -u ${CURRENT_USER})
GID = $(shell id -g ${CURRENT_USER})
DATE           = $(shell date -u +"%Y%m%d")
GIT_SHA = $(shell git rev-parse --short HEAD 2>/dev/null || echo nogit)
GIT_ORIGIN = $(shell git config --get remote.origin.url 2>/dev/null || echo unknown)
UUID           = $(shell uuidgen)

TRIVY_IMAGE    ?= aquasec/trivy:0.68.2
HADOLINT_IMAGE ?= hadolint/hadolint:v2.14.0

# Initialize variables for the current preset
comma := ,
space := $(subst ,, )

# ==============================================================================
# Presets logic
# ==============================================================================

PRESET_TARGETS := all help build test push pull generate scan lint update clean run inspect sbom
.PHONY: $(ALL_PRESETS)

define BIND_PRESET_DEPENDENCIES
  $(1).generate: $(1).guard $(1).clean
  $(1).build:    $(1).generate
  $(1).test:     $(1).build
  $(1).run:      $(1).build
  $(1).push:     $(1).test
  $(1).scan:     $(1).build
  $(1).lint:     $(1).generate
  $(1).sbom:     $(1).build
  $(1).inspect:  $(1).build
  $(1).history:  $(1).build
endef

$(foreach p,$(ALL_PRESETS),$(eval $(call BIND_PRESET_DEPENDENCIES,$(p))))

# Generate final image names
ifeq ($(strip $(BASE_IMAGE_PATH)),)
    BASE_IMAGE_FINAL := $(BASE_IMAGE_REGISTRY)/$(BASE_IMAGE_NAME)
else
    BASE_IMAGE_FINAL := $(BASE_IMAGE_REGISTRY)/$(BASE_IMAGE_PATH)/$(BASE_IMAGE_NAME)
endif

OUTPUT_IMAGE_FINAL := $(OUTPUT_IMAGE_REGISTRY)/$(OUTPUT_IMAGE_PATH)/$(OUTPUT_IMAGE_NAME)

# ==============================================================================
# Mandatory variables check
# ==============================================================================
MANDATORY_VARS = BASE_IMAGE_NAME BASE_IMAGE_TAG OUTPUT_IMAGE_NAME OUTPUT_IMAGE_REGISTRY \
	OUTPUT_IMAGE_PATH BASE_IMAGE_REGISTRY

# ==============================================================================
# Useful functions
# ==============================================================================
define docker-tags
	$(if $(filter yes,$(TAG_LATEST)),$(OUTPUT_IMAGE_FINAL):latest) \
	$(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME) \
	$(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG) \
	$(if $(filter yes,$(TAG_WITH_BASE_NAME)),$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)) \
	$(if $(filter yes,$(TAG_WITH_BASE_NAME)),$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)) \
	$(if $(filter yes,$(TAG_WITH_DATE)),$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)-$(DATE)) \
	$(if $(filter yes,$(TAG_WITH_GIT_SHA)),$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)-$(DATE)-$(GIT_SHA))
endef

define docker-run-cmd
	$(DOCKER_EXEC) run --rm $(1) \
		--security-opt no-new-privileges \
		--mount type=bind,source=$(BIND_HOST_DIR),target=$(BIND_CONTAINER_DIR) \
		--workdir $(WORKDIR) \
		--mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$(TMPFS_SIZE) \
		--platform $(ARCH_LIST) \
		--memory $(MEMORY) --memory-reservation $(MEMORY_RESERVATION) \
		--cpus $(CPUS) --cpu-shares $(CPU_SHARES) \
		--name $(OUTPUT_IMAGE_NAME)-$(BASE_IMAGE_TAG)-$(UUID) \
		$(2) \
		$(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG) $(3)
endef

# ==============================================================================
# Preset targets
# ==============================================================================

.PHONY: %.all %.generate %.build %.test %.run %.push %.pull %.scan %.clean %.prune %.update %.lint %.inspect %.sbom

$(ALL_PRESETS): %: %.build

%.all: %.update %.generate %.build %.test %.check %.push ;

.PHONY: %.guard
%.guard:
	$(foreach v,$(MANDATORY_VARS), \
	  $(if $(strip $($(v))),, \
	    $(error Missing mandatory var: $(v))))

%.generate: %.guard %.clean
	@echo ">>> Generating Dockerfile for $*"
	@sed $(foreach f,$(DOCKER_COMPOSITE_SOURCES),\
		-e '/^### @INCLUDE $(f) ###$$/ r $(COMMON_DIR)/$(f)') \
		$(PRESET_DIR)/$*/Dockerfile.in > $(PRESET_DIR)/$*/Dockerfile

%.build: %.generate
	$(DOCKER_EXEC) buildx build $(PRESET_DIR)/$* \
		--file $(PRESET_DIR)/$*/Dockerfile \
		--platform $(PLATFORMS) --progress $(PROGRESS_OUTPUT) \
		$(foreach tag,$(call docker-tags),--tag $(tag)) \
		--memory $(BUILD_MEMORY) --cpu-shares $(BUILD_CPU_SHARES) \
		--build-arg BUILD_DATE=$(DATE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE_FINAL):$(BASE_IMAGE_TAG) \
		--build-arg BASE_IMAGE_NAME=$(BASE_IMAGE_NAME) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg OUTPUT_IMAGE_VERSION=$(OUTPUT_IMAGE_VERSION) \
		--build-arg VCS_REF=$(GIT_SHA) \
		--build-arg AUTHOR=$(AUTHOR) \
		--build-arg URL=$(WEB_SITE) \
		--build-context root-project=$(ROOT_PROJECT) \
		$(BUILD_IMAGE_ARGS) $(DOCKER_DRIVER)


%.test: %.build
	$(call docker-run-cmd,,$(TEST_IMAGE_ARGS),$(TEST_IMAGE_CMD))

%.run: %.build
	$(call docker-run-cmd,-it,$(RUN_IMAGE_ARGS),$(RUN_IMAGE_CMD))

%.push: %.test
	$(foreach tag,$(call docker-tags),$(DOCKER_EXEC) push $(tag);)

%.pull:
	$(foreach tag,$(call docker-tags),$(DOCKER_EXEC) pull $(tag);)

%.update:
	@echo ">>> Updating base image for $*"
	$(DOCKER_EXEC) pull $(BASE_IMAGE_FINAL):$(BASE_IMAGE_TAG)

%.clean:
	@echo "Cleaning generated Dockerfile for $*"
	@rm -f $(PRESET_DIR)/$*/Dockerfile

%.prune: %.clean
	$(DOCKER_EXEC) builder prune -f --filter name=$(OUTPUT_IMAGE_FINAL)

%.inspect:
	$(DOCKER_EXEC) image inspect \
		$(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)

%.rebuild:
	$(MAKE) $*.clean
	$(MAKE) $*.build BUILD_IMAGE_ARGS="--no-cache"

%.history:
	$(DOCKER_EXEC) history \
	  $(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)

%.sbom:
	syft $(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG) -o spdx-json > $*.sbom.json

%.sign:
	cosign sign $(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)

%.scan:
	$(DOCKER_EXEC) run --rm \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  $(TRIVY_IMAGE) \
	  image --severity HIGH,CRITICAL \
	  $(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(BASE_IMAGE_TAG)

%.lint: %.generate
	$(DOCKER_EXEC) run --rm -i $(HADOLINT_IMAGE) < $(PRESET_DIR)/$*/Dockerfile

%.check: %.lint %.scan %.sbom

%.cache:
	$(DOCKER_EXEC) buildx imagetools inspect $(OUTPUT_IMAGE_FINAL):cache

# ==============================================================================
# Global targets
# ==============================================================================
.PHONY: $(PRESET_TARGETS)

%-all:
	@$(foreach p,$(ALL_PRESETS),$(MAKE) $(p).$* ;)

build-all: $(ALL_BUILDS)
test-all:  $(ALL_TESTS)

$(ALL_BUILDS) $(ALL_TESTS) $(ALL_PUSHES):
	@$(MAKE) $@

list:
	@echo "Presets disponibles :"
	@$(foreach p,$(ALL_PRESETS),echo " - $(p)";)

purge: clean
	$(DOCKER_EXEC) images --filter='reference=$(OUTPUT_IMAGE_FINAL)' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER_EXEC) rmi -f
	$(DOCKER_EXEC) builder prune -f
	$(DOCKER_EXEC) system prune -f

qemu:
	$(DOCKER_EXEC) run --rm --privileged multiarch/qemu-user-static --reset -p yes
	$(DOCKER_EXEC) buildx create --name qemu_builder --use || true

docker-container-builder:
	$(DOCKER_EXEC) buildx create --name mybuilder --use
	$(DOCKER_EXEC) buildx inspect --bootstrap
	$(DOCKER_EXEC) buildx inspect mybuilder

docker-default-builder:
	$(DOCKER_EXEC) buildx use default

