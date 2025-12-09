# wolfi-bootc

A bootable wolfi linux container.

The `Dockerfile` in this repo can be used to customize the install, the base image used [can be found in my containers repo](https://github.com/vaskozl/containers/blob/main/bootc.yaml). It is built completely declaratively with [apko](https://github.com/chainguard-dev/apko) and is comprised solely of files packaged with [melange](https://github.com/chainguard-dev/melange). This repo provides a baseline example for using it.


## Usage

```bash
just build
just image
```
You can then use `bootable.img` with a VM or even flash to a disk.

The username and password is `nori`.
