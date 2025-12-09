FROM ghcr.io/vaskozl/bootc:1.11.0

RUN apk add --no-cache \
  systemd-default-network \
  nori-user
