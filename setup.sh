#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/

# Create a bridge network in Docker
docker network create jenkins

# Build a new docker image
docker compose build

# Run your own myjenkins-blueocean image as a container in Docker
docker compose up -d

# Accessing the Docker container
#docker exec -it jenkins-blueocean bash

# Accessing the Docker logs
#docker logs jenkins-docker
#docker logs jenkins-blueocean

# Accessing the Jenkins home directory
