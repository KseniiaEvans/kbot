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
RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}

FROM scratch AS bin
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["./kbot", "start"]