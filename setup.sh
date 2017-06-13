#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root." 1>&2
   exit 1
fi


set -ex

mkdir -p /etc/docker
cat <<EOS > /etc/docker/daemon.json
{
  "live-restore": true,
  "storage-driver": "overlay2"
}
EOS

apt-get update -qq

apt-get install -y -qq --no-install-recommends \
    docker.io \


if [ -f "${PROMENADE_LOAD_IMAGE}" ]; then
  echo === Loading updated promenade image ===
  docker load -i "${PROMENADE_LOAD_IMAGE}"
fi

docker run --rm \
    -v /:/target \
    promenade:experimental \
    promenade \
        --hostname $(hostname) \
        --config-path /target/$1
