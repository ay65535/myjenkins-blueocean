#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/

# Build a new docker image
docker compose build

## for debug
# docker stop jenkins-tmp
# docker container ls -a
# . .env
# docker run -d -u root --rm \
#   --name jenkins-tmp \
#   -e PROXY=$PROXY \
#   -e NO_PROXY=$NO_PROXY \
#   -e TRUST_HOST=$TRUST_HOST \
#   jenkins/jenkins:2.387.2 sleep infinity
# docker cp conf/my_proxy.crt jenkins-tmp:/usr/local/share/ca-certificates/my_proxy.crt
# docker cp conf/plugins.txt jenkins-tmp:/usr/share/jenkins/ref/plugins.txt
# docker cp scripts/setenv.sh jenkins-tmp:/usr/local/bin/setenv.sh
# docker cp scripts/update-cacert.sh jenkins-tmp:/usr/local/bin/update-cacert.sh
# docker cp scripts/install-cert.sh jenkins-tmp:/usr/local/bin/install-cert.sh
# docker cp scripts/entrypoint.sh jenkins-tmp:/entrypoint.sh
# docker exec -it jenkins-tmp sh
