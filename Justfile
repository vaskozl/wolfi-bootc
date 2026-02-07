build:
    podman manifest create ghcr.io/vaskozl/wolfi-bootc
    podman build \
        --platform linux/amd64,linux/arm64  \
        --squash-all \
        --manifest ghcr.io/vaskozl/wolfi-bootc .

run *ARGS:
    podman run \
        --rm --privileged --pid=host \
        -it \
        -v /sys/fs/selinux:/sys/fs/selinux:Z \
        -v /etc/containers:/etc/containers \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v $PWD:/data \
        --security-opt label=type:unconfined_t \
        ghcr.io/vaskozl/wolfi-bootc:latest {{ARGS}}

bootc *ARGS:
    just run bootc {{ARGS}}

image:
    #!/usr/bin/env bash
    if [ ! -e "./bootable.img" ] ; then
        just run fallocate -l 20G /data/bootable.img
    fi
    just bootc install to-disk --composefs-backend --via-loopback /data/bootable.img --filesystem ext4 --wipe --bootloader systemd

push:
    just build
    podman manifest push ghcr.io/vaskozl/wolfi-bootc

vfkit:
    vfkit \
    --cpus 2 --memory 2048 \
    --bootloader efi,variable-store=efi-variable-store,create \
    --device virtio-blk,path=bootable.img \
    --device virtio-serial,stdio \
    --device virtio-net,nat
