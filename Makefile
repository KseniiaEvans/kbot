APP := $(shell basename $(shell git remote get-url origin))

GCPREPOSITORY := europe-central2-docker.pkg.dev/devops-intensive/core-services
GITREPOSITORY := KseniiaEvans
VERSION=$(shell git rev-parse --short HEAD)

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
		-t $(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) \
		--no-cache \
		--platform $(TARGETOS)/$(TARGETARCH) \

run:
	docker run \
		--rm --env-file .env \
		$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

push:
	docker tag $(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH) ${GCPREPOSITORY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
	docker push ${GCPREPOSITORY}/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)


linux: TARGETOS=linux
linux: image

windows: TARGETOS=windows
windows: image

macos: TARGETOS=darwin
macos: image

arm: TARGETARCH=arm64
arm: image

clean:
	rm -rf kbot
	rm -f ${APP}-*.tgz
	docker rmi $(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
