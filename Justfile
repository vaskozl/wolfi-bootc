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
    just bootc install to-disk --composefs-backend --block-setup tpm2-luks --filesystem ext4 --wipe --bootloader systemd {{DEVICE}}

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
