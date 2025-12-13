APP := $(shell basename $(shell git remote get-url origin))

GITREPOSITORY := KseniiaEvans
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

REGISTRY ?= kseniiaevans
TARGETOS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
TARGETARCH ?= $(shell dpkg --print-architecture)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
	go build -v -o $(APP) -ldflags="-X="github.com/$(GITREPOSITORY)/$(APP)/cmd.appVersion=$(VERSION)-$(TARGETOS)-$(TARGETARCH)

image:
	docker build . \
		-t ${REGISTRY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) \
		--no-cache \
		--platform $(TARGETOS)/$(TARGETARCH)

run:
	docker run \
		--rm --env-file .env \
		$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

push:
	docker push ${REGISTRY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

linux: TARGETOS=linux
linux: image

windows: TARGETOS=windows
windows: image

# Docker containers run only on linux/windows
# Hence either use Docker Desktop with linux/windows container 
# OR build go binary file for MacOS
macos: build

arm: TARGETARCH=arm64
arm: image


clean:
	rm -rf ${APP}
	rm -f ${APP}-*.tgz
	@docker image inspect ${REGISTRY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) >/dev/null 2>&1 && \
		docker rmi ${REGISTRY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) || \
		echo "Image not found locally, skipping removal"