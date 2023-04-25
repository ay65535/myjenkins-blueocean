#!/bin/bash

# docker compose config

lowercase_hostname=$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')
lowercase_hostname=$(echo "$HOSTNAME.$USERDNSDOMAIN" | tr '[:upper:]' '[:lower:]')
export JENKINS_URL="http://${lowercase_hostname}:8080"

# Run your own myjenkins-blueocean image as a container in Docker
echo "$JENKINS_URL"
docker compose up -d

docker compose ps -a
# docker compose logs -f jenkins-blueocean

# Cleanup the Docker container and volume
# docker compose down --remove-orphans --volumes
