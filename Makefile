#//////////////////////////////////////////////////////////////
#//   ____                                                   //
#//  | __ )  ___ _ __  ___ _   _ _ __   ___ _ __ _ __   ___  //
#//  |  _ \ / _ \ '_ \/ __| | | | '_ \ / _ \ '__| '_ \ / __| //
#//  | |_) |  __/ | | \__ \ |_| | |_) |  __/ |  | |_) | (__  //
#//  |____/ \___|_| |_|___/\__,_| .__/ \___|_|  | .__/ \___| //
#//                             |_|             |_|          //
#//////////////////////////////////////////////////////////////
#//                                                          //
#//  docker-multimedia, 2023                                      //
#//  Created: 4 February, 2023                               //
#//  Modified: 01 October, 2023                              //
#//  file: -                                                 //
#//  -                                                       //
#//  Source:                                                 //
#//  OS: ALL                                                 //
#//  CPU: ALL                                                //
#//                                                          //
#//////////////////////////////////////////////////////////////

# Base image
BASE_IMAGE_REGISTRY := docker.io
BASE_IMAGE_NAME := archlinux
BASE_IMAGE_TAGS := base base-devel

# Output docker image
PROJECT_NAME := multimedia
AUTHOR := bensuperpc
REGISTRY := docker.io
WEB_SITE := bensuperpc.org

IMAGE_VERSION := 1.0.0

USER_NAME := bedem
# USER_NAME := $(shell whoami)
USER_UID := $(shell id -u ${USER})
USER_GID := $(shell id -g ${USER})

# Max CPU and memory
CPUS := 1.0
MEMORY := 16GB
MEMORY_RESERVATION := 4GB
TMPFS_SIZE := 2G

TEST_CMD := ls

PROGRESS_OUTPUT := plain

ARCH_LIST := linux/amd64
# linux/amd64,linux/amd64/v3, linux/arm64, linux/riscv64, linux/ppc64
comma:= ,
PLATFORMS := $(subst $() $(),$(comma),$(ARCH_LIST))

IMAGE_NAME := $(PROJECT_NAME)
OUTPUT_IMAGE := $(AUTHOR)/$(IMAGE_NAME)

# Docker config
DOCKERFILE := Dockerfile
DOCKER_EXEC := docker
DOCKER_DRIVER := --load
# --push

# Git config
GIT_SHA := $(shell git rev-parse HEAD)
GIT_ORIGIN := $(shell git config --get remote.origin.url) 

DATE := $(shell date -u +"%Y%m%d")
UUID := $(shell uuidgen)

.PHONY: all test push pull run

all: $(BASE_IMAGE_TAGS)

test: $(addsuffix .test,$(BASE_IMAGE_TAGS))

push: $(addsuffix .push,$(BASE_IMAGE_TAGS))

pull: $(addsuffix .pull,$(BASE_IMAGE_TAGS))

run: $(addsuffix .run,$(BASE_IMAGE_TAGS))

.PHONY: $(BASE_IMAGE_TAGS)
$(BASE_IMAGE_TAGS): $(Dockerfile)
	$(DOCKER_EXEC) buildx build . --file $(DOCKERFILE) \
		--platform $(PLATFORMS) --progress $(PROGRESS_OUTPUT) \
		--tag $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$@-$(IMAGE_VERSION)-$(DATE)-$(GIT_SHA) \
		--tag $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$@-$(IMAGE_VERSION)-$(DATE) \
		--tag $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$@-$(IMAGE_VERSION) \
		--tag $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$@ \
		--build-arg BUILD_DATE=$(DATE) --build-arg DOCKER_IMAGE=$(BASE_IMAGE_REGISTRY)/$(BASE_IMAGE_NAME):$@ \
		--build-arg IMAGE_VERSION=$(IMAGE_VERSION) --build-arg PROJECT_NAME=$(PROJECT_NAME) \
		--build-arg VCS_REF=$(GIT_SHA) --build-arg VCS_URL=$(GIT_ORIGIN) \
		--build-arg AUTHOR=$(AUTHOR) --build-arg URL=$(WEB_SITE) \
		--build-arg USER_NAME=$(USER_NAME) --build-arg USER_UID=$(USER_UID) --build-arg USER_GID=$(USER_GID) \
		$(DOCKER_DRIVER)

#  --cap-drop ALL --cap-add SYS_PTRACE	  --device=/dev/kvm

.SECONDEXPANSION:
$(addsuffix .test,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	$(DOCKER_EXEC) run --rm \
		--security-opt no-new-privileges --read-only \
		--mount type=bind,source=$(shell pwd),target=/work --workdir /work \
		--mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$(TMPFS_SIZE) \
		--platform $(PLATFORMS) \
		--cpus $(CPUS) --memory $(MEMORY) --memory-reservation $(MEMORY_RESERVATION) \
		--name $(IMAGE_NAME)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)-$(UUID) \
		$(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)-$(GIT_SHA) \
		$(TEST_CMD)
#--user $(shell id -u ${USER}):$(shell id -g ${USER})

.SECONDEXPANSION:
$(addsuffix .run,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	$(DOCKER_EXEC) run -it \
		--security-opt no-new-privileges \
		--mount type=bind,source=$(shell pwd),target=/work --workdir /work \
		--mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$(TMPFS_SIZE) \
		--platform $(PLATFORMS) \
		--cpus $(CPUS) --memory $(MEMORY) --memory-reservation $(MEMORY_RESERVATION) \
		--name $(IMAGE_NAME)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)-$(UUID) \
		$(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)-$(GIT_SHA)


.SECONDEXPANSION:
$(addsuffix .push,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Pushing $(REGISTRY)/$(OUTPUT_IMAGE)"
	$(DOCKER_EXEC) push $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)
	$(DOCKER_EXEC) push $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)
	$(DOCKER_EXEC) push $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)
	$(DOCKER_EXEC) push $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)-$(GIT_SHA)
#   $(DOCKER_EXEC) push $(REGISTRY)/$(OUTPUT_IMAGE) --all-tags

.SECONDEXPANSION:
$(addsuffix .pull,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Pulling $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)" 
	$(DOCKER_EXEC) pull $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)
	$(DOCKER_EXEC) pull $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)
	$(DOCKER_EXEC) pull $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)
	$(DOCKER_EXEC) pull $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION)-$(DATE)-$(GIT_SHA)

.SECONDEXPANSION:
$(addsuffix .save,$(BASE_IMAGE_TAGS)): $$(basename $$@)
#	docker save $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION) | xz -e7 -v -T0 > $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION).tar.xz

#   Bash version
#	DOCKER_IMAGE=ben/ben:ben; install -Dv /dev/null "$DOCKER_IMAGE".tar.xz && docker pull "$DOCKER_IMAGE" && docker save "$DOCKER_IMAGE" | xz -e7 -v -T0 > "$DOCKER_IMAGE".tar.xz

.SECONDEXPANSION:
$(addsuffix .load,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Not implemented yet"
#	xz -v -d -k < $(REGISTRY)/$(OUTPUT_IMAGE):$(BASE_IMAGE_NAME)-$(basename $@)-$(IMAGE_VERSION).tar.xz | docker load

.PHONY: clean
clean:
	@echo "Clean all untagged images"
	$(DOCKER_EXEC) image prune --force --filter="dangling=true"

.PHONY: purge
purge: clean
	@echo "Remove all $(OUTPUT_IMAGE) images and tags"
	$(DOCKER_EXEC) images --filter='reference=$(OUTPUT_IMAGE)' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER_EXEC) rmi -f

.PHONY: update
update:
#   Update all submodules to latest
#   git submodule update --init --recursive
#	git pull --recurse-submodules --all --progress --jobs=0

	git submodule foreach --recursive git clean -xfd
	git submodule foreach --recursive git reset --hard
	git submodule update --init --recursive
#	git submodule update --recursive --remote --force --rebase
	git submodule update --recursive --init --remote --force

#   Update all docker image
	$(foreach tag,$(BASE_IMAGE_TAGS),$(DOCKER_EXEC) pull $(BASE_IMAGE_NAME):$(tag);)
# All docker-compose things
#   docker compose down  2>/dev/null || true
#   docker rmi -f $(docker images -f "dangling=true" -q) 2>/dev/null || true

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
qemu:
	export DOCKER_CLI_EXPERIMENTAL=enabled
	$(DOCKER_EXEC) run --rm --privileged multiarch/qemu-user-static --reset -p yes
	$(DOCKER_EXEC) buildx create --name qemu_builder --driver docker-container --use
	$(DOCKER_EXEC) buildx inspect --bootstrap