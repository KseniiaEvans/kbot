APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := kseniiaevans
GITREPOSITORY := KseniiaEvans
VERSION=$(shell git rev-parse --short HEAD)

TARGETOS ?= linux
ARCH ?= arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(ARCH) \
	go build -v -o $(APP) -ldflags="-X github.com/$(GITREPOSITORY)/$(APP)/cmd.appVersion=$(VERSION)"

image:
	docker build . \
		-t $(APP):$(VERSION)-$(TARGETOS)-$(ARCH) \
		--no-cache \
		--platform $(TARGETOS)/$(ARCH) \
		--build-arg APP=${APP} \
		--build-arg VERSION=${VERSION} \

run:
	docker run \
		--rm --env-file .env \
		$(APP):$(VERSION)-$(TARGETOS)-$(ARCH)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${ARCH}

linux: TARGETOS=linux
linux: image


windows: TARGETOS=windows
windows: image

macos: TARGETOS=darwin
macos: image


clean:
	rm -rf kbot
	rm -f ${APP}-*.tgz
