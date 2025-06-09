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

# =====================
# USER DEFINED VARIABLES
# =====================

AUTHOR ?= bensuperpc
WEB_SITE ?= bensuperpc.org

# Base docker image
BASE_IMAGE_REGISTRY ?= docker.io
BASE_IMAGE_PATH ?= 
BASE_IMAGE_NAME ?= archlinux
BASE_IMAGE_TAGS ?= base
ifeq ($(strip $(BASE_IMAGE_PATH)),)
	BASE_IMAGE_FINAL := $(BASE_IMAGE_REGISTRY)/$(BASE_IMAGE_NAME)
else
	BASE_IMAGE_FINAL := $(BASE_IMAGE_REGISTRY)/$(BASE_IMAGE_PATH)/$(BASE_IMAGE_NAME)
endif

# Output docker image
OUTPUT_IMAGE_REGISTRY ?= docker.io
OUTPUT_IMAGE_PATH ?= bensuperpc
OUTPUT_IMAGE_NAME ?= multimedia
OUTPUT_IMAGE_VERSION ?= 1.0.0
ifeq ($(strip $(OUTPUT_IMAGE_PATH)),)
	OUTPUT_IMAGE_FINAL := $(OUTPUT_IMAGE_REGISTRY)/$(OUTPUT_IMAGE_NAME)
else
	OUTPUT_IMAGE_FINAL := $(OUTPUT_IMAGE_REGISTRY)/$(OUTPUT_IMAGE_PATH)/$(OUTPUT_IMAGE_NAME)
endif

# --cap-drop ALL
# --cap-add SYS_PTRACE
# --device=/dev/kvm
# --read-only
# --user $(UID):$(GID)
TEST_IMAGE_CMD ?= ls
TEST_IMAGE_ARGS ?= -e PUID=$(UID) -e PGID=$(GID) -e USERNAME=bensuperpc

RUN_IMAGE_CMD ?= ls
RUN_IMAGE_ARGS ?= -e PUID=$(UID) -e PGID=$(GID) -e USERNAME=bensuperpc

# Docker config
DOCKERFILE ?= Dockerfile
DOCKER_EXEC ?= docker
PROGRESS_OUTPUT ?= plain
BUILD_CONTEXT ?= $(shell pwd)

WORKDIR ?= /work

BIND_HOST_DIR ?= $(shell pwd)
BIND_CONTAINER_DIR ?= /work

ARCH_LIST ?= linux/amd64

# --push
DOCKER_DRIVER ?= --load

DOCKER_COMPOSITE_SOURCES ?= common.label-and-env common.entrypoint common.user

DOCKER_COMPOSITE_FOLDER_PATH ?= common/
DOCKER_COMPOSITE_PATH ?= $(addprefix $(DOCKER_COMPOSITE_FOLDER_PATH),$(DOCKER_COMPOSITE_SOURCES))

# Max CPU and memory
CPUS ?= 8.0
CPU_SHARES ?= 1024
MEMORY ?= 16GB
MEMORY_RESERVATION ?= 2GB
TMPFS_SIZE ?= 4GB
BUILD_CPU_SHARES ?= 1024
BUILD_MEMORY ?= 16GB

# =====================
# TARGETS
# =====================

.PHONY: all
all: $(addsuffix .test,$(BASE_IMAGE_TAGS))

.PHONY: generate
generate: Dockerfile

Dockerfile: Dockerfile.in $(DOCKER_COMPOSITE_PATH)
	rm -f $@
	sed $(foreach f,$(DOCKER_COMPOSITE_SOURCES),-e '/$(f)/ r $(DOCKER_COMPOSITE_FOLDER_PATH)$(f)') $< > $@

# --no-cache  $(Dockerfile)
.PHONY: $(BASE_IMAGE_TAGS)
$(BASE_IMAGE_TAGS): Dockerfile
	$(DOCKER_EXEC) buildx build . --build-context root-project=$(BUILD_CONTEXT) --file $(DOCKERFILE) \
		--platform $(PLATFORMS) --progress $(PROGRESS_OUTPUT) \
		--tag $(OUTPUT_IMAGE_FINAL) \
		--tag $(OUTPUT_IMAGE_FINAL):latest \
		--tag $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION) \
		--tag $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME) \
		--tag $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$@ \
		--tag $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$@-$(DATE) \
		--tag $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$@-$(DATE)-$(GIT_SHA) \
		--memory $(BUILD_IMAGE_MEMORY) --cpu-shares $(BUILD_IMAGE_CPU_SHARES) --compress \
		--build-arg BUILD_DATE=$(DATE) --build-arg BASE_IMAGE=$(BASE_IMAGE_FINAL):$@ \
		--build-arg OUTPUT_IMAGE_VERSION=$(OUTPUT_IMAGE_VERSION) --build-arg OUTPUT_IMAGE_NAME=$(OUTPUT_IMAGE_NAME) \
		--build-arg VCS_REF=$(GIT_SHA) --build-arg VCS_URL=$(GIT_ORIGIN) \
		--build-arg AUTHOR=$(AUTHOR) --build-arg URL=$(WEB_SITE) \
		$(BUILD_IMAGE_ARGS) $(DOCKER_DRIVER)


.PHONY: build
build: $(BASE_IMAGE_TAGS)

.PHONY: test
test: $(addsuffix .test,$(BASE_IMAGE_TAGS))

.PHONY: run
run: $(addsuffix .run,$(BASE_IMAGE_TAGS))

.PHONY: push
push: $(addsuffix .push,$(BASE_IMAGE_TAGS))

.PHONY: pull
pull: $(addsuffix .pull,$(BASE_IMAGE_TAGS))

.SECONDEXPANSION:
$(addsuffix .build,$(BASE_IMAGE_TAGS)): $$(basename $$@)

.SECONDEXPANSION:
$(addsuffix .test,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	$(DOCKER_EXEC) run --rm \
		--security-opt no-new-privileges \
		--mount type=bind,source=$(BIND_HOST_DIR),target=$(BIND_CONTAINER_DIR) --workdir $(WORKDIR) \
		--mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$(TMPFS_SIZE) --platform $(PLATFORMS) \
		--cpus $(CPUS) --cpu-shares $(CPU_SHARES) --memory $(MEMORY) --memory-reservation $(MEMORY_RESERVATION) \
		--name $(OUTPUT_IMAGE_NAME)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)-$(UUID) $(TEST_IMAGE_ARGS) \
		$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA) $(TEST_IMAGE_CMD)

.SECONDEXPANSION:
$(addsuffix .run,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	$(DOCKER_EXEC) run -it --rm \
		--security-opt no-new-privileges \
		--mount type=bind,source=$(BIND_HOST_DIR),target=$(BIND_CONTAINER_DIR) --workdir $(WORKDIR) \
		--mount type=tmpfs,target=/tmp,tmpfs-mode=1777,tmpfs-size=$(TMPFS_SIZE) --platform $(PLATFORMS) \
		--cpus $(CPUS) --cpu-shares $(CPU_SHARES) --memory $(MEMORY) --memory-reservation $(MEMORY_RESERVATION) \
		--name $(OUTPUT_IMAGE_NAME)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)-$(UUID) $(RUN_IMAGE_ARGS) \
		$(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA) $(RUN_IMAGE_CMD)

.SECONDEXPANSION:
$(addsuffix .push,$(BASE_IMAGE_TAGS)): $$(basename $$@).test
	@echo "Pushing $(OUTPUT_IMAGE_FINAL)"
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL)
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):latest
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)
	$(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)
#   $(DOCKER_EXEC) push $(OUTPUT_IMAGE_FINAL) --all-tags

.SECONDEXPANSION:
$(addsuffix .pull,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Pulling $(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(basename $@)"
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL)
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):latest
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)
	$(DOCKER_EXEC) pull $(OUTPUT_IMAGE_FINAL):$(OUTPUT_IMAGE_VERSION)-$(BASE_IMAGE_NAME)-$(basename $@)-$(DATE)-$(GIT_SHA)

.PHONY: clean
clean:
	@echo "Clean all untagged images"
	rm -rf Dockerfile $(DOCKER_COMPOSITE_FOLDER_PATH)
	$(DOCKER_EXEC) system prune -f
	$(DOCKER_EXEC) builder prune -f

.PHONY: purge
purge: clean
	@echo "Remove all $(OUTPUT_IMAGE_FINAL) images and tags"
	$(DOCKER_EXEC) images --filter='reference=$(OUTPUT_IMAGE_FINAL)' --format='{{.Repository}}:{{.Tag}}' | xargs -r $(DOCKER_EXEC) rmi -f
#   	docker rmi -f $(docker images -f "dangling=true" -q) 2>/dev/null || true

.PHONY: update
update:
	$(foreach tag,$(BASE_IMAGE_TAGS),$(DOCKER_EXEC) pull $(BASE_IMAGE_FINAL):$(tag);)

# https://github.com/linuxkit/linuxkit/tree/master/pkg/binfmt
.PHONY: qemu
qemu:
	export DOCKER_CLI_EXPERIMENTAL=enabled
	$(DOCKER_EXEC) run --rm --privileged multiarch/qemu-user-static --reset -p yes
	$(DOCKER_EXEC) buildx create --name qemu_builder --driver docker-container --use
	$(DOCKER_EXEC) buildx inspect --bootstrap

.PHONY: version
version:
	@echo "version: $(foreach tag,$(BASE_IMAGE_TAGS),$(OUTPUT_IMAGE_FINAL):$(BASE_IMAGE_NAME)-$(tag)-$(OUTPUT_IMAGE_VERSION)-$(DATE)-$(GIT_SHA))"

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all: Build and test all images"
	@echo "  build: Build all images"
	@echo "  test: Test all images"
	@echo "  push: Push all images"
	@echo "  pull: Pull all images"
	@echo "  clean: Clean all untagged images"
	@echo "  purge: Remove all images and tags"
	@echo "  update: Update all images and submodules"
	@echo "  qemu: Install qemu"
	@echo "  help: Show this help message"
	@echo ""
	@echo "  All images: $(BASE_IMAGE_TAGS)"
	@echo "  Sub targets: $(addsuffix .build,$(BASE_IMAGE_TAGS)) $(addsuffix .test,$(BASE_IMAGE_TAGS)) \
	$(addsuffix .push,$(BASE_IMAGE_TAGS)) $(addsuffix .pull,$(BASE_IMAGE_TAGS))"

.SECONDEXPANSION:
$(addsuffix .save,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Not implemented yet"

.SECONDEXPANSION:
$(addsuffix .load,$(BASE_IMAGE_TAGS)): $$(basename $$@)
	@echo "Not implemented yet"
