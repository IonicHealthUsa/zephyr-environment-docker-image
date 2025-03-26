GIT_TAG := $(shell git describe --tags --always --abbrev=7 --dirty='*' | sed 's/^\(.*\)-g\([0-9a-f]\{7\}\)/\1-\2/')

DOCKER_HUB := djuniorionichealth/zephyr-environment-image
IMAGE := $(DOCKER_HUB):$(GIT_TAG)

.PHONY: build
build:
	@echo "Building..."
	@echo "IMAGE: $(IMAGE)"
	@docker build -f ./Dockerfile -t $(IMAGE) .


.PHONY: push
push:
	@echo "Pushing..."
	@docker push $(IMAGE)
