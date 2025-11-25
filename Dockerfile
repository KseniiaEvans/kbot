# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.24 AS builder

ARG TARGETOS
ARG TARGETARCH
RUN echo "TARGET OS: ${TARGETOS}, TARGET ARCH: ${TARGETARCH}"

WORKDIR /go/src/app
COPY . .

RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}

FROM alpine:latest AS certs
RUN apk add --no-cache ca-certificates

FROM scratch AS bin
WORKDIR /

COPY --from=builder /go/src/app/kbot .
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080
ENTRYPOINT ["./kbot", "start"]
