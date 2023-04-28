#!/bin/sh
set -e

# Start Docker daemon
/usr/bin/dockerd &

# Run the command provided as argument
exec "$@"
