#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/

# プロキシ証明書を取得し、 conf/my_proxy.crt として保存しておく。 (取得元パスは修正必要)
cp ~/.local/share/ca-certificates/my_proxy.crt conf/my_proxy.crt

# Build a new docker image
docker-compose build

docker image ls

# -a, --all             Remove all unused images, not just dangling ones
# docker image prune --force --all
# docker image prune --force
