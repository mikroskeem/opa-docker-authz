FROM --platform=$BUILDPLATFORM golang:1.18-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

RUN apk add --no-cache git

WORKDIR $GOPATH/src/github.com/mikroskeem/opa-docker-authz

# Download dependencies
COPY go.* .
RUN CGO_ENABLED=0 go mod download

# Build app
COPY . .
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build \
    -ldflags="-w -s" \
    -o /opa-docker-authz .

FROM --platform=$TARGETPLATFORM scratch
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/cert.pem
COPY --from=builder /opa-docker-authz /opa-docker-authz

ENTRYPOINT ["/opa-docker-authz"]
