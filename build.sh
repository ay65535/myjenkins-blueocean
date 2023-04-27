#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/

# プロキシ証明書を取得し、 ./usr/local/share/ca-certificates/ 下に保存しておく。
mkdir -p ./usr/local/share/ca-certificates/
find /usr/share/ca-certificates /usr/local/share/ca-certificates -type f -name '*.crt' -exec \
  cp {} ./usr/local/share/ca-certificates/ \;
ls -la ./usr/local/share/ca-certificates/

# Build a new docker image
docker-compose build

docker image ls

# -a, --all             Remove all unused images, not just dangling ones
# docker image prune --force --all
# docker image prune --force
