#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/

# Create a bridge network in Docker if not exists
if ! docker network ls | grep -q 'jenkins'; then
    docker network create jenkins
fi

# Build a new docker image
docker compose build

# Run your own myjenkins-blueocean image as a container in Docker
JENKINS_URL="http://$(hostname):8080" docker compose up -d
echo "$JENKINS_URL"

# Accessing the Docker container
#docker exec -it jenkins-blueocean bash

# Accessing the Docker logs
#docker compose logs -f

# Accessing the Jenkins home directory

# Cleanup the Docker container and volume
# docker compose down --remove-orphans --volumes
