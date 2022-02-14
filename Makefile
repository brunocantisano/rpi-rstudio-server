.PHONY: default build remove rebuild save load tag push publish pull run test

DOCKER_IMAGE_VERSION=1.1.463-stretch
IMAGE_NAME=rpi-rstudio-server
OWNER=brunocantisano
PORT=9413
NEXUS_REPO=$(OWNER):$(PORT)
TAG=$(IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_IMAGE_NAME=$(OWNER)/$(IMAGE_NAME)
DOCKER_IMAGE_TAGNAME=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
FILE_TAR = ./$(IMAGE_NAME).tar
FILE_GZ = $(FILE_TAR).gz

UNAME_S        := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    APP_HOST   := localhost
endif
ifeq ($(UNAME_S),Darwin)
    APP_HOST   := $(shell docker-machine ip default)
endif

default:
	build
build:
	docker build -t $(DOCKER_IMAGE_TAGNAME) .
remove:
	docker rmi -f $(DOCKER_IMAGE_TAGNAME)
rebuild: remove build

save:
	docker image save $(DOCKER_IMAGE_TAGNAME) > $(FILE_TAR)
	@[ -f $(FILE_TAR) ] && gzip $(FILE_TAR) || true
load:
	@[ -f $(FILE_GZ) ] && gunzip $(FILE_GZ) || true
	@[ -f $(FILE_TAR) ] && docker load -i $(FILE_TAR) && gzip $(FILE_TAR) || true
tag:
	docker tag $(DOCKER_IMAGE_TAGNAME) $(NEXUS_REPO)/$(TAG)
push:
	docker push $(NEXUS_REPO)/$(TAG)
publish: tag push

pull:
	docker pull $(NEXUS_REPO)/$(TAG)
run:
	docker run -d --rm --name $(IMAGE_NAME) -v ${PWD}/library:/home/myuser/R/arm-unknown-linux-gnueabihf-library/3.3 -v ${PWD}:/home/myuser -p 80:8787 $(DOCKER_IMAGE_TAGNAME)
stop:
	docker stop $(IMAGE_NAME)
test:
	docker run --rm $(NEXUS_REPO)/$(TAG) /bin/echo "Success."
