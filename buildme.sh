#!/usr/bin/bash
podman build -t dcos:latest $(dirname $0)
podman run --rm -it --privileged --ulimit=host --ipc=host --cgroups=disabled --name dcos --security-opt label=disable --userns=keep-id --hostname $(hostname) --mount type=tmpfs,tmpfs-size=20G,destination=/build -v $(pwd):/aosp-src -v $(dirname $0):/cathedra dcos:latest
