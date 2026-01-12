FROM ghcr.io/vaskozl/bootc:1.12.0

RUN apk add --no-cache \
  systemd-default-network
