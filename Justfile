selinux_mount := if path_exists("/sys/fs/selinux") == "true" { "-v /sys/fs/selinux:/sys/fs/selinux:Z" } else { "" }

run *ARGS:
    podman run \
        --rm --privileged --pid=host \
        -it \
        {{selinux_mount}} \
        -v /etc/containers:/etc/containers \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v $PWD:/data \
        --security-opt label=type:unconfined_t \
        --entrypoint /usr/bin/env \
        ghcr.io/vaskozl/niri:latest {{ARGS}}

bootc *ARGS:
    just run bootc {{ARGS}}

image:
    #!/usr/bin/env bash
    if [ ! -e "./bootable.img" ] ; then
        just run fallocate -l 20G /data/bootable.img
    fi
    just bootc install to-disk --composefs-backend --via-loopback /data/bootable.img --filesystem ext4 --wipe --bootloader systemd

flash DEVICE:
    just bootc install to-disk --composefs-backend --filesystem ext4 --wipe --bootloader systemd {{DEVICE}}

flash-encrypted DEVICE:
    #!/usr/bin/env bash
    set -euo pipefail
    just flash {{DEVICE}}
    root=$(lsblk -nrpo NAME,PARTTYPE {{DEVICE}} | awk '$2=="4f68bce3-e8cd-4db1-96e7-fbcaf984b709" {print $1}')
    e2fsck -f -p "$root"
    # Shrink by 32M to make room for the LUKS2 header; resize2fs isn't in the image.
    podman run --rm --privileged -v /dev:/dev cgr.dev/chainguard/wolfi-base \
        sh -c "apk add -q e2fsprogs-extra && resize2fs $root $(( $(cat /sys/class/block/${root##*/}/size) - 65536 ))s"
    cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32M "$root"

vfkit *ARGS:
    vfkit \
    --cpus 2 --memory 2048 \
    --bootloader efi,variable-store=efi-variable-store,create \
    --device virtio-blk,path=bootable.img \
    --device virtio-serial,stdio \
    --device virtio-net,nat {{ARGS}}

vfkit-gui:
    just vfkit \
    --device virtio-input,keyboard \
    --device virtio-input,pointing \
    --device virtio-gpu,width=1920,height=1080 \
    --gui
