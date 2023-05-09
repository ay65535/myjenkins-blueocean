#!/bin/sh

# Run the original ENTRYPOINT script from docker:dind
/usr/local/bin/dockerd-entrypoint.sh --storage-driver overlay2 &

# Run the original ENTRYPOINT script from jenkins/ssh-agent:alpine
/usr/local/bin/setup-sshd "$@"
