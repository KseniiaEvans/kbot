# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.24 AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

ARG APP
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
RUN echo "OS: $TARGETOS, ARCH: $TARGETARCH" > /log


WORKDIR /go/src/app
COPY . .
RUN export GOPATH=/go
RUN go get -d -v .
RUN gofmt -s -w ./

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -v -o kbot \ 
    -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${VERSION}-$(echo -n ${APP_BUILD_INFO}|cut -c1-7)-${TARGETARCH}


FROM scratch AS bin
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["./kbot", "start"]