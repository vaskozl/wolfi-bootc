FROM ghcr.io/vaskozl/bootc:1.10.0

# Necessary for general behavior expected by image-based systems
RUN rm -rf /boot /home /root /usr/local /srv && \
    mkdir -p /var /sysroot /boot /usr/lib/ostree /etc/default && \
    echo "HOME=/var/home" | tee -a "/etc/default/useradd" && \
    rm -rf /boot /home /root /usr/local /srv && \
    mkdir -p /var /sysroot /boot /usr/lib/ostree && \
    ln -s var/opt /opt && \
    ln -s var/roothome /root && \
    ln -s var/home /home && \
    ln -s sysroot/ostree /ostree && \
    printf "[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n" | tee "/usr/lib/ostree/prepare-root.conf"

RUN passwd -d root

COPY etc/. etc/

ENTRYPOINT []
